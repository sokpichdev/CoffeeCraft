//
//  RewardsViewModel.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 3/30/26.
//
//  Owns the real-time points history listener for the Rewards screen.
//  CardViewModel (injected via @EnvironmentObject) handles the card/points state.
//

import FirebaseFirestore
import Foundation

@MainActor
class RewardsViewModel: ObservableObject {

    @Published var pointsHistory: [PointsTransaction] = []
    @Published var isLoadingHistory: Bool = false

    private let db = Firestore.firestore()
    private var listener: ListenerRegistration?

    // MARK: - Setup

    func setup(userId: String) {
        guard listener == nil else { return }
        isLoadingHistory = true

        AppLog.rewards.debug("🔌 RewardsViewModel — attaching points_transactions listener for userId: \(userId)")

        listener = db.collection(Firebase.PointsTransactions.collection)
            .whereField(Firebase.PointsTransactions.userId, isEqualTo: userId)
            .order(by: Firebase.PointsTransactions.timestamp, descending: true)
            .limit(to: 50)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self else { return }

                if let error {
                    AppLog.rewards.error("❌ RewardsViewModel listener error: \(error.localizedDescription)")
                    self.isLoadingHistory = false
                    return
                }

                let transactions = snapshot?.documents.compactMap {
                    try? $0.data(as: PointsTransaction.self)
                } ?? []

                AppLog.rewards.debug("📡 RewardsViewModel — \(transactions.count) transaction(s) received")
                self.pointsHistory = transactions
                self.isLoadingHistory = false
            }
    }

    // MARK: - Teardown

    func teardown() {
        listener?.remove()
        listener = nil
        pointsHistory = []
        AppLog.rewards.debug("🔌 RewardsViewModel — listener removed")
    }
}
