//
//  LoyaltyService.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 3/30/26.
//
//  Singleton service that awards loyalty points to a customer's active card
//  when their order reaches the "Completed" status.
//
//  Design rules (same pattern as WalletService):
//  • No @MainActor — Firestore runTransaction closure runs on a background thread.
//  • Card point increment + points_transactions ledger write are inside one
//    runTransaction so both succeed or both fail atomically.
//  • Milestone detection happens after the transaction returns [before, after].
//  • ToastManager (which is @MainActor) is always called via Task { @MainActor in }.
//

import FirebaseFirestore
import Foundation

final class LoyaltyService {

    // MARK: - Singleton

    static let shared = LoyaltyService()
    private init() {}

    // MARK: - Private constants

    private let db = Firestore.firestore()

    /// Every `rewardMilestone` whole points → `rewardAmount` $ added to wallet.
    private let rewardMilestone = 10
    private let rewardAmount    = 20.0

    // MARK: - Award Points

    /// Awards loyalty points to the customer's active card for a completed order.
    ///
    /// - Parameters:
    ///   - userId:           Firebase Auth UID of the customer.
    ///   - orderId:          Firestore document ID of the completed order.
    ///   - points:           Raw point total for the order (sum of qty × pointsValue). May be fractional.
    ///   - orderDescription: Human-readable label stored in the ledger (e.g. "Order #42").
    ///
    /// Silently skips (no throw) when the user has no active card — legacy customers
    /// or customers who haven't set up a card yet should not cause order completion to fail.
    func awardPoints(
        userId: String,
        orderId: String,
        points: Double,
        orderDescription: String
    ) async throws {
        guard points > 0 else {
            AppLog.rewards.debug("⚠️ LoyaltyService.awardPoints — points ≤ 0, skipping")
            return
        }

        AppLog.rewards.info("⭐ LoyaltyService.awardPoints — userId: \(userId), orderId: \(orderId), points: \(points)")

        // 1. Resolve active card number from the user document.
        guard let cardNumber = try await fetchActiveCardNumber(userId: userId) else {
            AppLog.rewards.info("ℹ️ LoyaltyService — no active card for userId: \(userId), skipping award")
            return
        }

        // 2. Resolve the card document ID from loyalty_cards collection.
        guard let cardRef = try await fetchCardRef(cardNumber: cardNumber) else {
            AppLog.rewards.warning("⚠️ LoyaltyService — card \(cardNumber) not found in loyalty_cards, skipping")
            return
        }

        // 3. Convert fractional points to an integer increment.
        //    pointsValue can be 0.5, 1.3, etc. — we round to nearest Int.
        //    The raw Double is preserved in the points_transactions ledger.
        let pointsInt = Int(points.rounded())
        guard pointsInt > 0 else {
            AppLog.rewards.debug("⚠️ LoyaltyService — rounded points = 0 for raw \(points), skipping")
            return
        }

        // 4. Atomic transaction: update card points + write ledger entry.
        let ledgerRef = db.collection(Firebase.PointsTransactions.collection).document()

        let result = try await db.runTransaction { [self] transaction, errorPointer -> Any? in
            do {
                // Read current points
                let snapshot    = try transaction.getDocument(cardRef)
                let before      = snapshot.data()?[Firebase.LoyaltyCards.points] as? Int ?? 0
                let after       = before + pointsInt

                // Update card points
                transaction.updateData(
                    [Firebase.LoyaltyCards.points: after],
                    forDocument: cardRef
                )

                // Write points_transactions ledger entry (inside same transaction → atomic)
                let ledgerData: [String: Any] = [
                    Firebase.PointsTransactions.userId:      userId,
                    Firebase.PointsTransactions.cardNumber:  cardNumber,
                    Firebase.PointsTransactions.orderId:     orderId,
                    Firebase.PointsTransactions.points:      points,   // raw Double preserved
                    Firebase.PointsTransactions.description: orderDescription,
                    Firebase.PointsTransactions.timestamp:   Timestamp(date: Date())
                ]
                transaction.setData(ledgerData, forDocument: ledgerRef)

                AppLog.rewards.debug("✅ LoyaltyService transaction prepared — \(before) → \(after) pts, card: \(cardNumber)")
                return [before, after] as NSArray
            } catch {
                errorPointer?.pointee = error as NSError
                return nil
            }
        }

        AppLog.rewards.info("✅ LoyaltyService.awardPoints complete — +\(pointsInt) pts for userId: \(userId)")

        // 5. Milestone detection (post-transaction, using the returned [before, after]).
        guard let arr = result as? [Int], arr.count == 2 else { return }
        let pointsBefore = arr[0]
        let pointsAfter  = arr[1]

        let milestonesBefore = pointsBefore / rewardMilestone
        let milestonesAfter  = pointsAfter  / rewardMilestone
        let newMilestones    = milestonesAfter - milestonesBefore

        guard newMilestones > 0 else { return }

        AppLog.rewards.info("🎉 LoyaltyService — \(newMilestones) milestone(s) crossed at \(pointsAfter) pts for userId: \(userId)")

        var totalRewardCC = 0.0

        for i in 0..<newMilestones {
            let milestoneNumber = (milestonesBefore + 1 + i) * rewardMilestone
            let reason = "Loyalty milestone – \(milestoneNumber) pts"

            do {
                try await WalletService.shared.addReward(
                    userId: userId,
                    amount: rewardAmount,
                    reason: reason
                )
                totalRewardCC += rewardAmount
                AppLog.rewards.info("✅ Reward granted: +\(self.rewardAmount.currencyFormatted) — \(reason)")
            } catch {
                AppLog.rewards.error("❌ addReward failed for \(reason): \(error.localizedDescription)")
            }
        }

        if totalRewardCC > 0 {
            Task { @MainActor in
                ToastManager.shared.show(
                    message: "🎉 +\(totalRewardCC.currencyFormatted) loyalty reward!",
                    type: .success
                )
            }
        }
    }

    // MARK: - Private helpers

    private func fetchActiveCardNumber(userId: String) async throws -> String? {
        let doc = try await db.collection(Firebase.Users.collection).document(userId).getDocument()
        return doc.data()?[Firebase.Users.activeCard] as? String
    }

    private func fetchCardRef(cardNumber: String) async throws -> DocumentReference? {
        let snapshot = try await db.collection(Firebase.LoyaltyCards.collection)
            .whereField(Firebase.LoyaltyCards.cardNumber, isEqualTo: cardNumber)
            .limit(to: 1)
            .getDocuments()
        return snapshot.documents.first?.reference
    }
}
