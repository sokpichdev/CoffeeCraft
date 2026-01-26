//
//  CardViewModel.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 1/26/26.
//

import Foundation
import FirebaseFirestore
import Combine

@MainActor
class CardViewModel: ObservableObject {
    @Published var userCards: [UserCard] = []
    @Published var activeCard: UserCard?
    @Published var activeCardDetails: Card?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let db = Firestore.firestore()
    private var currentUserId: String?
    private var cardsListener: ListenerRegistration?
    
    init() {}
    
    func setUser(userId: String) {
        self.currentUserId = userId
        setupCardsListener()
    }
    
    // MARK: - Real-time Listener
    
    private func setupCardsListener() {
        guard let userId = currentUserId else { return }
        
        cardsListener?.remove()
        
        cardsListener = db.collection("users")
            .document(userId)
            .collection("cards")
            .order(by: "addedAt", descending: false)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                
                if let error = error {
                    self.errorMessage = error.localizedDescription
                    return
                }
                
                guard let documents = snapshot?.documents else { return }
                
                self.userCards = documents.compactMap { document in
                    try? document.data(as: UserCard.self)
                }
                
                // Update active card
                self.activeCard = self.userCards.first(where: { $0.isActive })
                
                // Fetch active card details if exists
                if let activeCard = self.activeCard {
                    Task {
                        await self.fetchActiveCardDetails(cardNumber: activeCard.cardNumber)
                    }
                }
            }
    }
    
    // MARK: - Fetch Active Card Details
    
    func fetchActiveCardDetails(cardNumber: String) async {
        do {
            let snapshot = try await db.collection("cards")
                .document(cardNumber)
                .getDocument()
            
            self.activeCardDetails = try snapshot.data(as: Card.self)
        } catch {
            print("Error fetching card details: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Add Card
    
    func addCard(cardNumber: String) async throws {
        guard let userId = currentUserId else {
            throw CardError.userNotAuthenticated
        }
        
        isLoading = true
        errorMessage = nil
        
        defer { isLoading = false }
        
        // 1. Validate card format (16 digits)
        let cleanCardNumber = cardNumber.replacingOccurrences(of: " ", with: "")
        guard cleanCardNumber.count == 16, cleanCardNumber.allSatisfy({ $0.isNumber }) else {
            throw CardError.invalidCardNumber
        }
        
        // 2. Check if card exists in global collection
        let cardSnapshot = try await db.collection("cards")
            .document(cleanCardNumber)
            .getDocument()
        
        guard cardSnapshot.exists else {
            throw CardError.invalidCardNumber
        }
        
        let globalCard = try cardSnapshot.data(as: Card.self)
        
        // 3. Check if user already has this card
        if userCards.contains(where: { $0.cardNumber == cleanCardNumber }) {
            throw CardError.cardAlreadyAdded
        }
        
        // 4. Create user card reference
        let newUserCard = UserCard(
            id: nil,
            cardNumber: cleanCardNumber,
            isOwner: globalCard.ownerId == userId,
            isActive: false,
            addedAt: Date(),
            memberName: globalCard.ownerName,
            memberSince: globalCard.memberSince
        )
        
        // 5. Save to user's cards subcollection
        try await db.collection("users")
            .document(userId)
            .collection("cards")
            .addDocument(data: [
                "cardNumber": newUserCard.cardNumber,
                "isOwner": newUserCard.isOwner,
                "isActive": newUserCard.isActive,
                "addedAt": Timestamp(date: newUserCard.addedAt),
                "memberName": newUserCard.memberName,
                "memberSince": newUserCard.memberSince
            ])
    }
    
    // MARK: - Switch Active Card
    
    func setActiveCard(_ card: UserCard) async throws {
        guard let userId = currentUserId, let cardId = card.id else {
            throw CardError.userNotAuthenticated
        }
        
        isLoading = true
        errorMessage = nil
        
        defer { isLoading = false }
        
        let batch = db.batch()
        
        // 1. Deactivate all cards
        for userCard in userCards {
            guard let id = userCard.id else { continue }
            let cardRef = db.collection("users")
                .document(userId)
                .collection("cards")
                .document(id)
            batch.updateData(["isActive": false], forDocument: cardRef)
        }
        
        // 2. Activate selected card
        let selectedCardRef = db.collection("users")
            .document(userId)
            .collection("cards")
            .document(cardId)
        batch.updateData(["isActive": true], forDocument: selectedCardRef)
        
        // 3. Commit batch
        try await batch.commit()
    }
    
    // MARK: - Remove Card
    
    func removeCard(_ card: UserCard) async throws {
        guard let userId = currentUserId, let cardId = card.id else {
            throw CardError.userNotAuthenticated
        }
        
        // Cannot remove own card
        guard !card.isOwner else {
            throw CardError.cannotRemoveOwnCard
        }
        
        isLoading = true
        errorMessage = nil
        
        defer { isLoading = false }
        
        // Delete card from user's subcollection
        try await db.collection("users")
            .document(userId)
            .collection("cards")
            .document(cardId)
            .delete()
        
        // If removed card was active, activate the owner's card
        if card.isActive {
            if let ownCard = userCards.first(where: { $0.isOwner }) {
                try await setActiveCard(ownCard)
            }
        }
    }
    
    // MARK: - Create Initial Card for New User
    
    func createInitialCard(userId: String, userName: String) async throws {
        // Generate card number (you might want a better algorithm)
        let cardNumber = generateCardNumber()
        
        // 1. Create global card
        let globalCard = Card(
            id: cardNumber,
            cardNumber: cardNumber,
            ownerId: userId,
            ownerName: userName,
            memberSince: formatMemberSince(Date()),
            points: 0,
            createdAt: Date()
        )
        
        try await db.collection("cards")
            .document(cardNumber)
            .setData([
                "cardNumber": globalCard.cardNumber,
                "ownerId": globalCard.ownerId,
                "ownerName": globalCard.ownerName,
                "memberSince": globalCard.memberSince,
                "points": globalCard.points,
                "createdAt": Timestamp(date: globalCard.createdAt)
            ])
        
        // 2. Create user card reference
        try await db.collection("users")
            .document(userId)
            .collection("cards")
            .addDocument(data: [
                "cardNumber": cardNumber,
                "isOwner": true,
                "isActive": true,
                "addedAt": Timestamp(date: Date()),
                "memberName": userName,
                "memberSince": globalCard.memberSince
            ])
    }
    
    // MARK: - Helper Functions
    
    private func generateCardNumber() -> String {
        let numbers = (0..<16).map { _ in String(Int.random(in: 0...9)) }
        return numbers.joined()
    }
    
    private func formatMemberSince(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/yy"
        return formatter.string(from: date)
    }
    
    deinit {
        cardsListener?.remove()
    }
}
