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
    @Published var activeCardNumber: String = ""
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let db = Firestore.firestore()
    private var currentUserId: String?
    private var cardsListener: ListenerRegistration?
    private var activeListener: ListenerRegistration?
    
    var activeCard: LoyaltyCard? {
        cards.first { $0.cardNumber == activeCardNumber && $0.hasAccessForCurrentUser }
    }
    
    var accessibleCards: [LoyaltyCard] {
        cards.filter { $0.hasAccessForCurrentUser }
    }
    
    func setUser(userId: String) {
        currentUserId = userId
        LoyaltyCard.currentUserId = userId
        setupListeners()
    }
    
    private func setupListeners() {
        guard let userId = currentUserId else { return }
        
        // Listen to user document (activeCard + accessibleCards)
        activeListener?.remove()
        activeListener = db.collection("users").document(userId)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                guard let data = snapshot?.data() else { return }
                
                // Update activeCard
                if let activeCardNum = data["activeCard"] as? String {
                    self.activeCardNumber = activeCardNum
                    LoyaltyCard.currentActiveCardNumber = activeCardNum
                } else {
                    self.activeCardNumber = ""
                }
                
                // Fetch accessibleCards on login
                if let accessibleCardNumbers = data["accessibleCards"] as? [String] {
                    Task {
                        await self.fetchAccessibleCards(accessibleCardNumbers)
                    }
                }
            }
        
        // Owned cards listener for real-time updates
        cardsListener?.remove()
        cardsListener = db.collection("loyalty_cards")
            .whereField("ownerId", isEqualTo: userId)
            .addSnapshotListener { [weak self] snapshot, error in
                self?.cards = snapshot?.documents.compactMap { try? $0.data(as: LoyaltyCard.self) } ?? []
            }
    }

    // Fetch all cards from accessibleCards array
    private func fetchAccessibleCards(_ cardNumbers: [String]) async {
        var allCards: [LoyaltyCard] = []
        
        for cardNumber in cardNumbers {
            do {
                let cardDoc = try await db.collection("loyalty_cards")
                    .document(cardNumber)
                    .getDocument()
                
                if let card = try? cardDoc.data(as: LoyaltyCard.self) {
                    allCards.append(card)
                }
            } catch {
                print("Failed to fetch card \(cardNumber): \(error)")
            }
        }
        
        await MainActor.run {
            self.cards = allCards
            self.cards.sort { $0.createdAt > $1.createdAt }
        }
    }
    
    func addCard(cardNumber: String) async throws {
        guard let userId = currentUserId else { throw CardError.userNotAuthenticated }
        
        let cleanCardNumber = cardNumber.replacingOccurrences(of: " ", with: "")
        let cardDoc = try await db.collection("loyalty_cards").document(cleanCardNumber).getDocument()
        
        guard let card = try? cardDoc.data(as: LoyaltyCard.self) else {
            throw CardError.invalidCardNumber
        }
        
        // Validate access
        if card.ownerId == userId {
            print("✅ Owner access granted")
        } else if card.sharedWith.contains(userId) {
            print("✅ Already shared")
        } else {
            throw CardError.noAccess
        }
        
        try await db.collection("users").document(userId).updateData([
            "accessibleCards": FieldValue.arrayUnion([cleanCardNumber])
        ])
        
        await fetchSharedCards()
        
        print("✅ Card added to accessibleCards: \(cleanCardNumber)")
    }
    
    private func fetchSharedCards() async {
        guard let userId = currentUserId else { return }
        
        do {
            let snapshot = try await db.collection("loyalty_cards")
                .whereField("sharedWith", arrayContains: userId)
                .getDocuments()
            
            let sharedCards = snapshot.documents.compactMap { try? $0.data(as: LoyaltyCard.self) }
            
            await MainActor.run {
                let ownedCardIds = Set(cards.map { $0.id ?? "" })
                let newSharedCards = sharedCards.filter { !ownedCardIds.contains($0.id ?? "") }
                self.cards.append(contentsOf: newSharedCards)
                self.cards.sort { $0.createdAt > $1.createdAt }
            }
        } catch {
            print("Shared cards fetch error: \(error)")
        }
    }
    
    func setActiveCard(_ card: LoyaltyCard) async throws {
        guard let userId = currentUserId, card.hasAccessForCurrentUser else {
            throw CardError.noAccess
        }
        
        isLoading = true
        defer { Task { @MainActor in isLoading = false } }
        
        try await db.collection("users").document(userId).updateData([
            "activeCard": card.cardNumber
        ])
    }
    
    func shareCard(_ card: LoyaltyCard, with userId: String) async throws {
        guard card.isOwnedByCurrentUser else {
            throw CardError.notOwner
        }
        
        try await db.collection("loyalty_cards").document(card.id ?? "").updateData([
            "sharedWith": FieldValue.arrayUnion([userId])
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
            "activeCards": cardNumber,
            "accessibleCards": [cardNumber],
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
