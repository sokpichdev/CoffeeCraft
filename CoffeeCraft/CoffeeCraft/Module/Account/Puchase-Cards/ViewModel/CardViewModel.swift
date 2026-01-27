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
    
    func setUser(userId: String) {
        currentUserId = userId
        LoyaltyCard.currentUserId = userId  // Update static context
        setupListeners()
    }
    
    private func setupListeners() {
        guard let userId = currentUserId else { return }
        
        // Listen to user's active cards array
        activeListener?.remove()
        activeListener = db.collection("users").document(userId)
            .addSnapshotListener { [weak self] snapshot, error in
                if let data = snapshot?.data(),
                   let active = data["activeCards"] as? [String] {
                    self?.activeCardNumbers = Set(active)
                    LoyaltyCard.activeCardNumbers = Set(active)  // Update static
                } else {
                    self?.activeCardNumbers = []
                    LoyaltyCard.activeCardNumbers = []
                }
            }
        
        // Listen to OWNED cards first
        cardsListener?.remove()
        cardsListener = db.collection("loyalty_cards")
            .whereField("ownerId", isEqualTo: userId)
            .addSnapshotListener { [weak self] snapshot, error in
                self?.handleCardsSnapshot(snapshot, error)
            }
    }
    
    private func handleCardsSnapshot(_ snapshot: QuerySnapshot?, _ error: Error?) {
        if let error = error {
            errorMessage = error.localizedDescription
            return
        }
        
        cards = snapshot?.documents.compactMap { document in
            try? document.data(as: LoyaltyCard.self)
        } ?? []
        
        // To get shared cards too, add another listener or use OR query:
        fetchSharedCards()
    }
    
    private func fetchSharedCards() {
        guard let userId = currentUserId else { return }
        
        db.collection("loyalty_cards")
            .whereField("sharedWith", arrayContains: userId)
            .getDocuments { [weak self] snapshot, error in
                guard let documents = snapshot?.documents else { return }
                let sharedCards = documents.compactMap { try? $0.data(as: LoyaltyCard.self) }
                DispatchQueue.main.async {
                    self?.cards.append(contentsOf: sharedCards)
                    self?.cards.sort { $0.createdAt > $1.createdAt }
                }
            }
    }
    
    func addCard(cardNumber: String) async throws {
        guard let userId = currentUserId else { throw CardError.userNotAuthenticated }
        isLoading = true
        defer { isLoading = false }
        
        let cleanCardNumber = cardNumber.replacingOccurrences(of: " ", with: "")
        guard cleanCardNumber.count == 16, cleanCardNumber.allSatisfy({ $0.isNumber }) else {
            throw CardError.invalidCardNumber
        }
        
        let cardDoc = try await db.collection("loyalty_cards").document(cleanCardNumber).getDocument()
        guard let card = try? cardDoc.data(as: LoyaltyCard.self),
              card.hasAccessForCurrentUser else {
            throw CardError.invalidCardNumber
        }
        
        try await db.collection("users").document(userId).updateData([
            "activeCards": FieldValue.arrayUnion([cleanCardNumber])
        ])
    }
    
    func setActiveCard(_ card: LoyaltyCard) async throws {
        guard let userId = currentUserId, card.hasAccessForCurrentUser else {
            throw CardError.noAccess
        }
        isLoading = true
        defer { isLoading = false }
        
        try await db.collection("users").document(userId).updateData([
            "activeCards": [card.cardNumber]
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
