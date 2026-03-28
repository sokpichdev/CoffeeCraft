import FirebaseFirestore
//
//  CardViewModel.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 1/26/26.
//
import Foundation
import SwiftUI

@MainActor
class CardViewModel: ObservableObject {
    @Published var cards: [LoyaltyCard] = []
    @Published var activeCardNumber: String = ""
    @Published var isActiveCardFetched: Bool = false
    @Published var isLoading = false
    @Published var isRefreshing = false
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
    
    func setUser(userId: String, isRefresh: Bool = false) {
        currentUserId = userId
        LoyaltyCard.currentUserId = userId
        AppLog.firestore.debug("👤 User set — uid: \(userId), isRefresh: \(isRefresh)")

        if isRefresh {
            isRefreshing = true
        }

        setupListeners()
    }
    
    private func setupListeners() {
        self.isActiveCardFetched = false
        guard let userId = currentUserId else {
            AppLog.firestore.warning("⚠️ setupListeners — no currentUserId, skipping")
            isRefreshing = false
            return
        }
        
        AppLog.firestore.debug("🔌 Attaching Firestore listeners for uid: \(userId)")
        
        // Listen to user document (activeCard + accessibleCards)
        activeListener?.remove()
        activeListener = db.collection(Firebase.Users.collection).document(userId)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                
                if let error = error {
                    AppLog.firestore.error("❌ User document listener error: \(error.localizedDescription)")
                    self.isRefreshing = false
                    return
                }
                
                guard let data = snapshot?.data() else {
                    AppLog.firestore.warning("⚠️ User document snapshot has no data")
                    self.isRefreshing = false
                    return
                }
                
                // Update activeCard
                if let activeCardNum = data[Firebase.Users.activeCard] as? String {
                    self.activeCardNumber = activeCardNum
                    LoyaltyCard.currentActiveCardNumber = activeCardNum
                    self.isActiveCardFetched = true
                    AppLog.firestore.debug("🃏 Active card updated: \(activeCardNum)")
                } else {
                    self.activeCardNumber = ""
                    AppLog.firestore.warning("⚠️ No activeCard field found in user document")
                }
                
                // Fetch accessibleCards on login
                if let accessibleCardNumbers = data[Firebase.Users.accessibleCards] as? [String] {
                    AppLog.firestore.debug("📋 accessibleCards from user doc: \(accessibleCardNumbers)")
                    Task {
                        await self.fetchAccessibleCards(accessibleCardNumbers)
                        self.isRefreshing = false
                    }
                } else {
                    self.isRefreshing = false
                }
            }
        
        // Owned cards listener for real-time updates
        cardsListener?.remove()
        cardsListener = db.collection(Firebase.LoyaltyCards.collection)
            .whereField(Firebase.LoyaltyCards.ownerId, isEqualTo: userId)
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

    private func fetchAccessibleCards(_ cardNumbers: [String]) async {
        guard !cardNumbers.isEmpty else { return }
        AppLog.firestore.debug("🔍 Batch-fetching \(cardNumbers.count) accessible card(s): \(cardNumbers)")

        // Firestore `in` supports up to 30 values per query — chunk if needed.
        // Most users will have 1–3 cards so this will almost always be one request.
        let chunks = stride(from: 0, to: cardNumbers.count, by: 30).map {
            Array(cardNumbers[$0..<min($0 + 30, cardNumbers.count)])
        }

        var fetchedCards: [LoyaltyCard] = []

        for chunk in chunks {
            do {
                let snapshot = try await db.collection(Firebase.LoyaltyCards.collection)
                    .whereField(Firebase.LoyaltyCards.cardNumber, in: chunk)
                    .getDocuments()

                let decoded = snapshot.documents.compactMap { try? $0.data(as: LoyaltyCard.self) }
                fetchedCards.append(contentsOf: decoded)

                AppLog.firestore.debug("✅ Batch chunk fetched \(decoded.count)/\(chunk.count) card(s)")
            } catch {
                AppLog.firestore.error("❌ Batch fetch failed for chunk \(chunk): \(error.localizedDescription)")
                AlertManager.shared.showError(message: "Failed to fetch cards: \(error.localizedDescription)")
            }
        }

        // Already @MainActor — no MainActor.run wrapper needed
        cards = fetchedCards.sorted { $0.createdAt > $1.createdAt }
        AppLog.printList(cards, label: "Accessible Cards", logger: AppLog.firestore)
    }
    
    func addCard(cardNumber: String) async throws {
        guard let userId = currentUserId else {
            AppLog.firestore.error("❌ addCard — user not authenticated")
            throw CardError.userNotAuthenticated
        }
        
        let cleanCardNumber = cardNumber.replacingOccurrences(of: " ", with: "")
        AppLog.firestore.debug("➕ addCard called — cardNumber: \(cleanCardNumber), userId: \(userId)")
        
        let cardDoc = try await db.collection(Firebase.LoyaltyCards.collection).document(cleanCardNumber).getDocument()
        
        guard let card = try? cardDoc.data(as: LoyaltyCard.self) else {
            AppLog.firestore.error("❌ addCard — invalid or non-existent card: \(cleanCardNumber)")
            throw CardError.invalidCardNumber
        }
        
        if card.ownerId == userId {
            AppLog.firestore.debug("✅ addCard — owner access granted for: \(cleanCardNumber)")
        } else if card.sharedWith.contains(userId) {
            AppLog.firestore.debug("✅ addCard — user already in sharedWith for: \(cleanCardNumber)")
        } else {
            AppLog.firestore.error("❌ addCard — access denied for userId: \(userId) on card: \(cleanCardNumber)")
            throw CardError.noAccess
        }
        
        try await db.collection(Firebase.Users.collection).document(userId).updateData([
            Firebase.Users.accessibleCards: FieldValue.arrayUnion([cleanCardNumber])
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
            let snapshot = try await db.collection(Firebase.LoyaltyCards.collection)
                .whereField(Firebase.LoyaltyCards.sharedWith, arrayContains: userId)
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
    
    func findUserId(byEmail email: String) async throws -> String? {
        AppLog.firestore.debug("🔍 findUserId — looking up email: \(email.lowercased())")
        
        let query = db.collection(Firebase.Users.collection)
            .whereField(Firebase.Users.email, isEqualTo: email.lowercased())
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
        defer { isLoading = false }
        
        try await db.collection(Firebase.Users.collection).document(userId).updateData([
            Firebase.Users.activeCard: card.cardNumber
        ])
        
        AppLog.firestore.debug("✅ setActiveCard — activeCard updated to: \(card.cardNumber)")
    }
    
    func shareCard(_ card: LoyaltyCard, with userId: String) async throws {
        guard card.isOwnedByCurrentUser else {
            AppLog.firestore.error("❌ shareCard — current user is not the owner of card: \(card.cardNumber)")
            throw CardError.notOwner
        }
        
        AppLog.firestore.debug("🤝 shareCard — sharing card \(card.cardNumber) with userId: \(userId)")
        
        try await db.collection(Firebase.LoyaltyCards.collection).document(card.id ?? "").updateData([
            Firebase.LoyaltyCards.sharedWith: FieldValue.arrayUnion([userId])
        ])
        
        AppLog.firestore.debug("✅ shareCard — card \(card.cardNumber) successfully shared with userId: \(userId)")
    }
    
    // MARK: - Loyalty Reward Constants
    // Every `rewardMilestone` points earned → `rewardCC` dollars added to wallet.
    // Uses integer-division milestone detection so it works correctly across multiple
    // orders and shared cards without ever double-awarding the same milestone.
    //   e.g. 9 → 10 pts: (9/10=0) < (10/10=1) ✓ milestone
    //        10 → 11 pts: (10/10=1) == (11/10=1) ✗ no milestone
    //        19 → 20 pts: (19/10=1) < (20/10=2) ✓ milestone
    private static let rewardMilestone = 10
    private static let rewardCC        = 20.0

    func addPoints(to card: LoyaltyCard, amount: Int) async throws {
        guard card.hasAccessForCurrentUser else {
            AppLog.firestore.error("❌ addPoints — access denied for card: \(card.cardNumber)")
            throw CardError.noAccess
        }

        AppLog.firestore.debug("⭐️ addPoints — adding \(amount) point(s) to card: \(card.cardNumber)")

        let cardRef = db.collection(Firebase.LoyaltyCards.collection).document(card.id ?? "")

        // Use a transaction so we atomically read pointsBefore, write pointsAfter,
        // and detect a milestone crossing — safe even on shared cards with concurrent writers.
        let result = try await db.runTransaction { transaction, errorPointer -> Any? in
            do {
                let snapshot    = try transaction.getDocument(cardRef)
                let before      = snapshot.data()?[Firebase.LoyaltyCards.points] as? Int ?? 0
                let after       = before + amount
                transaction.updateData([Firebase.LoyaltyCards.points: after], forDocument: cardRef)
                // Return [before, after] so the caller can detect milestone crossings
                return [before, after] as NSArray
            } catch {
                errorPointer?.pointee = error as NSError
                return nil
            }
        }

        guard let arr = result as? [Int], arr.count == 2 else {
            AppLog.firestore.error("❌ addPoints — transaction returned unexpected result")
            return
        }

        let pointsBefore = arr[0]
        let pointsAfter  = arr[1]

        AppLog.firestore.debug("✅ addPoints — card: \(card.cardNumber), \(pointsBefore) → \(pointsAfter) pts")

        // MARK: - Milestone check
        let milestonesBefore = pointsBefore / Self.rewardMilestone
        let milestonesAfter  = pointsAfter  / Self.rewardMilestone
        let newMilestones    = milestonesAfter - milestonesBefore

        guard newMilestones > 0, let userId = currentUserId else { return }

        AppLog.firestore.info("🎉 addPoints — \(newMilestones) milestone(s) crossed at \(pointsAfter) pts for uid: \(userId)")

        for i in 0..<newMilestones {
            // Calculate which milestone number was just hit (e.g. "10th point", "20th point")
            let milestoneNumber = (milestonesBefore + 1 + i) * Self.rewardMilestone
            let reason = "Loyalty milestone – \(milestoneNumber) pts"

            do {
                try await WalletService.shared.addReward(
                    userId: userId,
                    amount: Self.rewardCC,
                    reason: reason
                )
                AppLog.firestore.info("✅ Reward granted: +\(Self.rewardCC.currencyFormatted) — \(reason)")
            } catch {
                AppLog.firestore.error("❌ addReward failed for \(reason): \(error.localizedDescription)")
            }
        }

        let totalReward = Double(newMilestones) * Self.rewardCC
        ToastManager.shared.show(
            message: "🎉 +\(totalReward.currencyFormatted) loyalty reward!",
            type: .success
        )
    }
    
    func createInitialCard(userId: String, userName: String) async throws {
        let cardNumber = generateCardNumber()
        AppLog.firestore.debug("🆕 createInitialCard userName: \(userName), cardNumber: \(cardNumber)")
        
        try await db.collection(Firebase.LoyaltyCards.collection).document(cardNumber).setData([
            Firebase.LoyaltyCards.cardNumber: cardNumber,
            Firebase.LoyaltyCards.ownerId: userId,
            Firebase.LoyaltyCards.ownerName: userName,
            Firebase.LoyaltyCards.memberSince: formatMemberSince(Date()),
            Firebase.LoyaltyCards.points: 0,
            Firebase.LoyaltyCards.createdAt: Timestamp(date: Date()),
            Firebase.LoyaltyCards.sharedWith: [] as NSArray
        ])
        
        try await db.collection(Firebase.Users.collection).document(userId).setData([
            Firebase.Users.activeCard: cardNumber,
            Firebase.Users.accessibleCards: [cardNumber],
            Firebase.Users.updatedAt: Timestamp(date: Date())
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
