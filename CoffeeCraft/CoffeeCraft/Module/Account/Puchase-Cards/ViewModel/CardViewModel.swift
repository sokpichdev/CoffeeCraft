//
//  CardViewModel.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 1/26/26.
//
import Foundation
import FirebaseFirestore
import SwiftUI

@MainActor
class CardViewModel: ObservableObject {
    @Published var cards: [LoyaltyCard] = []
    @Published var activeCardNumber: String = ""
    @Published var isActiveCardFetched: Bool = false
    @Published var isLoading = false
    @Published var alert: AlertModel?

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
        AppLog.firestore.debug("👤 User set — uid: \(userId)")
        setupListeners()
    }
    
    private func setupListeners() {
        self.isActiveCardFetched = false
        guard let userId = currentUserId else {
            AppLog.firestore.warning("⚠️ setupListeners — no currentUserId, skipping")
            return
        }
        
        AppLog.firestore.debug("🔌 Attaching Firestore listeners for uid: \(userId)")
        
        // Listen to user document (activeCard + accessibleCards)
        activeListener?.remove()
        activeListener = db.collection("users").document(userId)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                
                if let error = error {
                    AppLog.firestore.error("❌ User document listener error: \(error.localizedDescription)")
                    return
                }
                
                guard let data = snapshot?.data() else {
                    AppLog.firestore.warning("⚠️ User document snapshot has no data")
                    return
                }
                
                // Update activeCard
                if let activeCardNum = data["activeCard"] as? String {
                    self.activeCardNumber = activeCardNum
                    LoyaltyCard.currentActiveCardNumber = activeCardNum
                    self.isActiveCardFetched = true
                    AppLog.firestore.debug("🃏 Active card updated: \(activeCardNum)")
                } else {
                    self.activeCardNumber = ""
                    AppLog.firestore.warning("⚠️ No activeCard field found in user document")
                }
                
                // Fetch accessibleCards on login
                if let accessibleCardNumbers = data["accessibleCards"] as? [String] {
                    AppLog.firestore.debug("📋 accessibleCards from user doc: \(accessibleCardNumbers)")
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
                guard let self = self else { return }
                
                if let error = error {
                    AppLog.firestore.error("❌ Owned cards listener error: \(error.localizedDescription)")
                    return
                }
                
                let ownedCards = snapshot?.documents.compactMap { try? $0.data(as: LoyaltyCard.self) } ?? []
                self.cards = ownedCards
                AppLog.printList(ownedCards, label: "Owned Cards", logger: AppLog.firestore)
            }
    }

    // Fetch all cards from accessibleCards array
    private func fetchAccessibleCards(_ cardNumbers: [String]) async {
        AppLog.firestore.debug("🔍 Fetching \(cardNumbers.count) accessible card(s): \(cardNumbers)")
        
        var fetchedCards: [LoyaltyCard] = []
        var failedCardNumbers: [String] = []

        for cardNumber in cardNumbers {
            do {
                let cardDoc = try await db.collection("loyalty_cards")
                    .document(cardNumber)
                    .getDocument()
                
                if let card = try? cardDoc.data(as: LoyaltyCard.self) {
                    fetchedCards.append(card)
                } else {
                    AppLog.firestore.warning("⚠️ Could not decode card: \(cardNumber)")
                }
            } catch {
                AppLog.firestore.error("❌ Failed to fetch card \(cardNumber): \(error.localizedDescription)")
                failedCardNumbers.append(cardNumber)
            }
        }
        
        let finalCards = fetchedCards
        await MainActor.run {
            self.cards = finalCards
            self.cards.sort { $0.createdAt > $1.createdAt }
        }
        
        AppLog.printList(finalCards, label: "Accessible Cards", logger: AppLog.firestore)
        
        if failedCardNumbers.count > 0 {
            AppLog.firestore.error("❌ Failed card numbers: \(failedCardNumbers.joined(separator: ", "))")
            if let _ = UserSession.shared.currentUser {
                AlertManager.shared.showError(message: "Failed to fetch cards: \(failedCardNumbers.joined(separator: ", "))")
            }
        }
    }
    
    func addCard(cardNumber: String) async throws {
        guard let userId = currentUserId else {
            AppLog.firestore.error("❌ addCard — user not authenticated")
            throw CardError.userNotAuthenticated
        }
        
        let cleanCardNumber = cardNumber.replacingOccurrences(of: " ", with: "")
        AppLog.firestore.debug("➕ addCard called — cardNumber: \(cleanCardNumber), userId: \(userId)")
        
        let cardDoc = try await db.collection("loyalty_cards").document(cleanCardNumber).getDocument()
        
        guard let card = try? cardDoc.data(as: LoyaltyCard.self) else {
            AppLog.firestore.error("❌ addCard — invalid or non-existent card: \(cleanCardNumber)")
            throw CardError.invalidCardNumber
        }
        
        // Validate access
        if card.ownerId == userId {
            AppLog.firestore.debug("✅ addCard — owner access granted for: \(cleanCardNumber)")
        } else if card.sharedWith.contains(userId) {
            AppLog.firestore.debug("✅ addCard — user already in sharedWith for: \(cleanCardNumber)")
        } else {
            AppLog.firestore.error("❌ addCard — access denied for userId: \(userId) on card: \(cleanCardNumber)")
            throw CardError.noAccess
        }
        
        try await db.collection("users").document(userId).updateData([
            "accessibleCards": FieldValue.arrayUnion([cleanCardNumber])
        ])
        
        AppLog.firestore.debug("✅ Card added to accessibleCards: \(cleanCardNumber)")
        
        await fetchSharedCards()
    }
    
    private func fetchSharedCards() async {
        guard let userId = currentUserId else {
            AppLog.firestore.warning("⚠️ fetchSharedCards — no currentUserId, skipping")
            return
        }
        
        AppLog.firestore.debug("🔍 Fetching shared cards for userId: \(userId)")
        
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
                AppLog.printList(newSharedCards, label: "Newly Added Shared Cards", logger: AppLog.firestore)
            }
        } catch {
            AppLog.firestore.error("❌ fetchSharedCards error: \(error.localizedDescription)")
        }
    }
    
    // input email return id
    func findUserId(byEmail email: String) async throws -> String? {
        AppLog.firestore.debug("🔍 findUserId — looking up email: \(email.lowercased())")
        
        let query = db.collection("users")
            .whereField("email", isEqualTo: email.lowercased())
            .limit(to: 1)
        
        let snapshot = try await query.getDocuments()
        let foundId = snapshot.documents.first?.documentID
        
        if let foundId {
            AppLog.firestore.debug("✅ findUserId — found uid: \(foundId) for email: \(email)")
        } else {
            AppLog.firestore.warning("⚠️ findUserId — no user found for email: \(email)")
        }
        
        return foundId
    }
    
    func setActiveCard(_ card: LoyaltyCard) async throws {
        guard let userId = currentUserId, card.hasAccessForCurrentUser else {
            AppLog.firestore.error("❌ setActiveCard — access denied for card: \(card.cardNumber)")
            throw CardError.noAccess
        }
        
        AppLog.firestore.debug("🃏 setActiveCard — setting \(card.cardNumber) as active for uid: \(userId)")
        
        isLoading = true
        defer { Task { @MainActor in isLoading = false } }
        
        try await db.collection("users").document(userId).updateData([
            "activeCard": card.cardNumber
        ])
        
        AppLog.firestore.debug("✅ setActiveCard — activeCard updated to: \(card.cardNumber)")
    }
    
    func shareCard(_ card: LoyaltyCard, with userId: String) async throws {
        guard card.isOwnedByCurrentUser else {
            AppLog.firestore.error("❌ shareCard — current user is not the owner of card: \(card.cardNumber)")
            throw CardError.notOwner
        }
        
        AppLog.firestore.debug("🤝 shareCard — sharing card \(card.cardNumber) with userId: \(userId)")
        
        try await db.collection("loyalty_cards").document(card.id ?? "").updateData([
            "sharedWith": FieldValue.arrayUnion([userId])
        ])
        
        AppLog.firestore.debug("✅ shareCard — card \(card.cardNumber) successfully shared with userId: \(userId)")
    }
    
    func addPoints(to card: LoyaltyCard, amount: Int) async throws {
        guard card.hasAccessForCurrentUser else {
            AppLog.firestore.error("❌ addPoints — access denied for card: \(card.cardNumber)")
            throw CardError.noAccess
        }
        
        AppLog.firestore.debug("⭐️ addPoints — adding \(amount) point(s) to card: \(card.cardNumber)")
        
        try await db.collection("loyalty_cards").document(card.id ?? "").updateData([
            "points": FieldValue.increment(Int64(amount))
        ])
        
        AppLog.firestore.debug("✅ addPoints — \(amount) point(s) added to card: \(card.cardNumber)")
    }
    
    func createInitialCard(userId: String, userName: String) async throws {
        let cardNumber = generateCardNumber()
        AppLog.firestore.debug("🆕 createInitialCard — userId: \(userId), userName: \(userName), cardNumber: \(cardNumber)")
        
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
            "activeCard": cardNumber,
            "accessibleCards": [cardNumber],
            "updatedAt": Timestamp(date: Date())
        ], merge: true)
        
        AppLog.firestore.debug("✅ createInitialCard — card \(cardNumber) created and set as active for uid: \(userId)")
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
