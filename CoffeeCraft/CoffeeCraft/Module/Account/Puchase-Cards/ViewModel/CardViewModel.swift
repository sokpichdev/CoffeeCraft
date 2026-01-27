//
//  CardViewModel.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 1/26/26.
//
import Foundation
import FirebaseFirestore
import SwiftUI

class CardViewModel: ObservableObject {
    @Published var cards: [LoyaltyCard] = []
    @Published var activeCardNumbers: Set<String> = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let db = Firestore.firestore()
    private var currentUserId: String?
    private var cardsListener: ListenerRegistration?
    private var activeListener: ListenerRegistration?
    
    // Computed properties
    var activeCard: LoyaltyCard? {
        cards.first { card in
            activeCardNumbers.contains(card.cardNumber) && card.hasAccessForCurrentUser
        }
    }
    
    var accessibleCards: [LoyaltyCard] {
        cards.filter { $0.hasAccessForCurrentUser }
    }
    
    func setUser(userId: String) {
        currentUserId = userId
        LoyaltyCard.currentUserId = userId
        setupListeners()
    }
    
//    private func setupListeners() {
//        guard let userId = currentUserId else { return }
//        
//        // Listen to user's active card (only 1)
//        activeListener?.remove()
//        activeListener = db.collection("users").document(userId)
//            .addSnapshotListener { [weak self] snapshot, error in
//                if let data = snapshot?.data(),
//                   let active = data["activeCards"] as? [String] {
//                    self?.activeCardNumbers = Set(active)
//                    LoyaltyCard.activeCardNumbers = Set(active)
//                }
//            }
//        
//        // Owned cards listener
//        cardsListener?.remove()
//        db.collection("loyalty_cards")
//            .whereField("ownerId", isEqualTo: userId)
//            .addSnapshotListener { [weak self] snapshot, error in
//                self?.handleOwnedCards(snapshot, error)
//            }
//        
//        // Shared cards listener
//        db.collection("loyalty_cards")
//            .whereField("sharedWith", arrayContains: userId)
//            .addSnapshotListener { [weak self] snapshot, error in
//                self?.handleSharedCards(snapshot, error)
//            }
//    }
    private func setupListeners() {
            guard let userId = currentUserId else { return }
            
            // ✅ 1. User's active card
            activeListener = db.collection("users").document(userId)
                .addSnapshotListener { [weak self] snapshot, error in
                    if let active = snapshot?.data()?["activeCards"] as? [String] {
                        self?.activeCardNumbers = Set(active)
                    }
                }
            
            // ✅ 2. ONLY owned cards listener (always works)
            cardsListener?.remove()
            cardsListener = db.collection("loyalty_cards")
                .whereField("ownerId", isEqualTo: userId)
                .addSnapshotListener { [weak self] snapshot, error in
                    self?.cards = snapshot?.documents.compactMap { try? $0.data(as: LoyaltyCard.self) } ?? []
                }
        }
    // ✅ 3. Manually fetch shared cards when adding
        func addCard(cardNumber: String) async throws {
            guard let userId = currentUserId else { throw CardError.userNotAuthenticated }
            
            let cleanCardNumber = cardNumber.replacingOccurrences(of: " ", with: "")
            let cardDoc = try await db.collection("loyalty_cards").document(cleanCardNumber).getDocument()
            
            guard let card = try? cardDoc.data(as: LoyaltyCard.self) else {
                throw CardError.invalidCardNumber
            }
            
            // ✅ Validate access BEFORE sharing
            if card.ownerId == userId {
                // Owner - auto-access
                print("✅ Owner access granted")
            } else if card.sharedWith.contains(userId) {
                // Already shared
                print("✅ Already shared")
            } else {
                // Not owner, not shared → throw error
                throw CardError.noAccess
            }
            
            // ✅ Card is accessible → refresh local list
            await fetchSharedCards()
            print("✅ Card added: \(cleanCardNumber)")
        }
        
        // ✅ Fetch shared cards manually
        private func fetchSharedCards() async {
            guard let userId = currentUserId else { return }
            
            do {
                let snapshot = try await db.collection("loyalty_cards")
                    .whereField("sharedWith", arrayContains: userId)
                    .getDocuments()
                
                let sharedCards = snapshot.documents.compactMap { try? $0.data(as: LoyaltyCard.self) }
                
                await MainActor.run {
                    // Merge with owned cards
                    let ownedCardIds = Set(cards.map { $0.id ?? "" })
                    let newSharedCards = sharedCards.filter { !ownedCardIds.contains($0.id ?? "") }
                    self.cards.append(contentsOf: newSharedCards)
                    self.cards.sort { $0.createdAt > $1.createdAt }
                }
            } catch {
                print("Shared cards fetch error: \(error)")
            }
        }
    
    // Handle owned cards
    private func handleOwnedCards(_ snapshot: QuerySnapshot?, _ error: Error?) {
        if let error = error {
            self.errorMessage = error.localizedDescription
            return
        }
        
        let ownedCards = snapshot?.documents.compactMap { try? $0.data(as: LoyaltyCard.self) } ?? []
        updateCards(with: ownedCards)
    }
    
    // Handle shared cards
    private func handleSharedCards(_ snapshot: QuerySnapshot?, _ error: Error?) {
        if let error = error {
            self.errorMessage = error.localizedDescription
            return
        }
        
        let sharedCards = snapshot?.documents.compactMap { try? $0.data(as: LoyaltyCard.self) } ?? []
        updateCards(with: sharedCards)
    }
    
    private func updateCards(with newCards: [LoyaltyCard]) {
        // Merge owned + shared cards, remove duplicates
        let existingIds = Set(cards.map { $0.id ?? "" })
        let filteredNewCards = newCards.filter { !existingIds.contains($0.id ?? "") }
        
        cards.append(contentsOf: filteredNewCards)
        cards.sort { $0.createdAt > $1.createdAt }
    }
    
    // Share card (owner only)
    func shareCard(_ card: LoyaltyCard, with userId: String) async throws {
        guard card.isOwnedByCurrentUser else {
            throw CardError.notOwner
        }
        
        try await db.collection("loyalty_cards").document(card.id ?? "").updateData([
            "sharedWith": FieldValue.arrayUnion([userId])
        ])
    }

    //  Set single active card
    func setActiveCard(_ card: LoyaltyCard) async throws {
        guard let userId = currentUserId, card.hasAccessForCurrentUser else {
            throw CardError.noAccess
        }
        await MainActor.run {
            isLoading = true
            do { isLoading = false }
        }
        
        try await db.collection("users").document(userId).updateData([
            "activeCards": [card.cardNumber]  // Only 1 active card
        ])
    }
    
    func addPoints(to card: LoyaltyCard, amount: Int) async throws {
        guard card.hasAccessForCurrentUser else { throw CardError.noAccess }
        try await db.collection("loyalty_cards").document(card.id ?? "").updateData([
            "points": FieldValue.increment(Int64(amount))
        ])
    }
    
    func createInitialCard(userId: String, userName: String) async throws {
        let cardNumber = generateCardNumber()
        try await db.collection("loyalty_cards").document(cardNumber).setData([
            "cardNumber": cardNumber,
            "ownerId": userId,
            "ownerName": userName,
            "memberSince": formatMemberSince(Date()),
            "points": 0,
            "createdAt": Timestamp(date: Date()),
            "sharedWith": [] as NSArray
        ])
        
        try await db.collection("users").document(userId).setData([
            "activeCards": [cardNumber],
            "updatedAt": Timestamp(date: Date())
        ], merge: true)
    }
    
    private func generateCardNumber() -> String {
        let numbers = (0..<16).map { _ in String(Int.random(in: 0...9)) }
        return numbers.joined()
    }
    
    private func formatMemberSince(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/yy"
        return formatter.string(from: date)
    }
}
