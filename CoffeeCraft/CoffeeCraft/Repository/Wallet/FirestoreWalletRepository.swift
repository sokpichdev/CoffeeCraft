//
//  FirestoreWalletRepository.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 3/11/26.
//
//  Live Firestore implementation of WalletRepositoryProtocol.
//
//  • Listener setup (previously private methods in WalletViewModel) lives here.
//  • Mutation (topUp) delegates to WalletService.shared — no duplication.
//  • Performance trace on topUp so wallet_top_up appears in Firebase console.
//

import FirebaseFirestore
import Foundation

struct FirestoreWalletRepository: WalletRepositoryProtocol {

    private let db = Firestore.firestore()

    // MARK: - Wallet Listener

    func listenWallet(userId: String, onChange: @escaping (Wallet?) -> Void) -> () -> Void {
        let registration = db.collection(Firebase.Wallets.collection)
            .document(userId)
            .addSnapshotListener { snapshot, error in
                if let error {
                    AppLog.wallet.error("❌ WalletRepository.listenWallet: \(error.localizedDescription)")
                    return
                }
                let wallet = try? snapshot?.data(as: Wallet.self)
                AppLog.wallet.debug("💳 WalletRepository — wallet snapshot received, balance: \(wallet?.balance ?? 0)")
                onChange(wallet)
            }
        return { registration.remove() }
    }

    // MARK: - Transactions Listener

    /// Only surfaces `.added` change events — existing transactions are immutable
    /// so `.modified` and `.removed` can never happen on this collection.
    func listenTransactions(userId: String, onChange: @escaping ([WalletTransaction]) -> Void) -> () -> Void {
        let registration = db.collection(Firebase.WalletTransactions.collection)
            .whereField(Firebase.WalletTransactions.userId, isEqualTo: userId)
            .order(by: Firebase.WalletTransactions.timestamp, descending: true)
            .limit(to: 50)
            .addSnapshotListener { snapshot, error in
                if let error {
                    AppLog.wallet.error("❌ WalletRepository.listenTransactions: \(error.localizedDescription)")
                    return
                }
                guard let changes = snapshot?.documentChanges else { return }

                let added = changes
                    .filter { $0.type == .added }
                    .compactMap { try? $0.document.data(as: WalletTransaction.self) }

                if !added.isEmpty {
                    AppLog.wallet.debug("➕ WalletRepository — \(added.count) new transaction(s)")
                    onChange(added)
                }
            }
        return { registration.remove() }
    }

    // MARK: - Top-Up

    /// Delegates to WalletService (atomic Firestore transaction) and wraps
    /// the call in a Firebase Performance trace.
    func topUp(userId: String, amount: Double) async throws {
        try await PerformanceService.shared.trace(.walletTopUp) {
            try await WalletService.shared.topUp(userId: userId, amount: amount)
        }
    }
}
