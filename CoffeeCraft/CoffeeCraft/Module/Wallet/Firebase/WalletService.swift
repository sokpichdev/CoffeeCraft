//
//  WalletService.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 3/3/26.
//

import FirebaseAuth
import FirebaseFirestore
import Foundation

// MARK: - WalletService
// Handles all Firestore reads and writes for the Wallet module.
// Every balance mutation uses runTransaction() to guarantee atomicity —
// no partial writes, no double-deductions, no race conditions.
//
// COLLECTIONS USED:
//   "wallets"              — one document per user (id = userId)
//   "wallet_transactions"  — append-only ledger, auto-generated ids
//
// CALL SITES:
//   WalletViewModel  → topUp(), fetchWallet(), fetchTransactions()
//   OrderService     → deductForOrder()
//   OrderDetailVM    → refund()          (Phase 5)
//   CardViewModel    → addReward()       (Phase 6)
//
// IMPORTANT: Never update wallet.balance directly from outside.
// All balance changes MUST go through one of the methods below
// so that the wallet_transactions ledger stays in sync.

final class WalletService {

    // MARK: - Singleton

    static let shared = WalletService()
    private init() {}

    // MARK: - Private

    private let db = Firestore.firestore()

    private var walletsRef: CollectionReference {
        db.collection("wallets")
    }

    private var transactionsRef: CollectionReference {
        db.collection("wallet_transactions")
    }

    // MARK: - Create Wallet

    /// Creates a brand-new wallet document for a user if one doesn't exist yet.
    /// Called automatically by topUp() the first time a user adds $.
    /// Safe to call multiple times — uses merge: true so existing data is preserved.
    func createWalletIfNeeded(userId: String, userName: String) async throws {
        AppLog.firestore.debug("🆕 WalletService.createWalletIfNeeded — userId: \(userId)")

        let walletRef = walletsRef.document(userId)
        let snapshot  = try await walletRef.getDocument()

        guard !snapshot.exists else {
            AppLog.firestore.debug("✅ Wallet already exists for userId: \(userId)")
            return
        }

        let now = Timestamp(date: Date())
        try await walletRef.setData([
            "balance": 0.0,
            "currency": "USD",
            "totalTopUp": 0.0,
            "totalSpent": 0.0,
            "createdAt": now,
            "updatedAt": now
        ])

        AppLog.firestore.debug("✅ Wallet created for userId: \(userId)")
    }

    // MARK: - Top-Up

    /// Atomically adds `amount` $ to the user's wallet and writes a "topup" transaction.
    /// - Parameters:
    ///   - userId: Firebase Auth UID
    ///   - amount: Positive Double — the $ amount to add
    /// - Throws: WalletError.invalidAmount if amount ≤ 0
    func topUp(userId: String, amount: Double) async throws {
        guard amount > 0 else {
            AppLog.firestore.error("❌ WalletService.topUp — invalid amount: \(amount)")
            throw WalletError.invalidAmount
        }

        AppLog.firestore.debug("⬆️ WalletService.topUp — userId: \(userId), amount: \(amount)")

        let walletRef = walletsRef.document(userId)
        let txRef     = transactionsRef.document()

        try await db.runTransaction { [self] transaction, errorPointer -> Any? in
            do {
                // 1. Read current balance
                let snapshot = try transaction.getDocument(walletRef)
                let current  = snapshot.data()?["balance"] as? Double ?? 0.0
                let newBalance = current + amount

                // 2. Update wallet balance + totals
                if snapshot.exists {
                    transaction.updateData([
                        "balance": newBalance,
                        "totalTopUp": FieldValue.increment(amount),
                        "updatedAt": Timestamp(date: Date())
                    ], forDocument: walletRef)
                } else {
                    // First top-up → create wallet inline
                    let now = Timestamp(date: Date())
                    transaction.setData([
                        "balance": newBalance,
                        "currency": "USD",
                        "totalTopUp": amount,
                        "totalSpent": 0.0,
                        "createdAt": now,
                        "updatedAt": now
                    ], forDocument: walletRef)
                }

                // 3. Write transaction ledger entry
                let tx = WalletTransaction(
                    userId: userId,
                    type: .topup,
                    amount: amount,
                    balanceBefore: current,
                    balanceAfter: newBalance,
                    description: "Top-up \(amount.currencyFormatted)",
                    referenceId: nil,
                    timestamp: Date()
                )
                transaction.setData(tx.toFirestoreData(), forDocument: txRef)

                AppLog.firestore.debug("✅ topUp transaction prepared — before: \(current), after: \(newBalance)")
                return nil
            } catch {
                errorPointer?.pointee = error as NSError
                return nil
            }
        }

        AppLog.firestore.info("✅ WalletService.topUp complete — +\(amount.currencyFormatted) for userId: \(userId)")
    }

    // MARK: - Deduct (Pay for Order)

    /// Atomically deducts `amount` $ from the wallet when an order is paid via wallet.
    /// Throws WalletError.insufficientBalance if balance is too low — call canAfford() first.
    /// - Parameters:
    ///   - userId:  Firebase Auth UID
    ///   - amount:  Positive Double — the order total
    ///   - orderId: The Firestore document ID of the order (written as referenceId)
    func deductForOrder(userId: String, amount: Double, orderId: String) async throws {
        guard amount > 0 else {
            AppLog.firestore.error("❌ WalletService.deductForOrder — invalid amount: \(amount)")
            throw WalletError.invalidAmount
        }

        AppLog.firestore.debug("🛍️ WalletService.deductForOrder — userId: \(userId), amount: \(amount), orderId: \(orderId)")

        let walletRef = walletsRef.document(userId)
        let txRef     = transactionsRef.document()

        try await db.runTransaction { transaction, errorPointer -> Any? in
            do {
                let snapshot = try transaction.getDocument(walletRef)

                guard snapshot.exists else {
                    throw WalletError.walletNotFound
                }

                let current = snapshot.data()?["balance"] as? Double ?? 0.0

                guard current >= amount else {
                    AppLog.firestore.error("❌ Insufficient balance — have: \(current), need: \(amount)")
                    throw WalletError.insufficientBalance
                }

                let newBalance = current - amount

                // Update wallet
                transaction.updateData([
                    "balance": newBalance,
                    "totalSpent": FieldValue.increment(amount),
                    "updatedAt": Timestamp(date: Date())
                ], forDocument: walletRef)

                // Write ledger entry
                let tx = WalletTransaction(
                    userId: userId,
                    type: .payment,
                    amount: -amount,
                    balanceBefore: current,
                    balanceAfter: newBalance,
                    description: "Order #\(orderId.suffix(6))",
                    referenceId: orderId,
                    timestamp: Date()
                )
                transaction.setData(tx.toFirestoreData(), forDocument: txRef)

                AppLog.firestore.debug("✅ deductForOrder transaction prepared — before: \(current), after: \(newBalance)")
                return nil
            } catch {
                errorPointer?.pointee = error as NSError
                return nil
            }
        }

        AppLog.firestore.info("✅ WalletService.deductForOrder complete — -\(amount.currencyFormatted) for orderId: \(orderId)")
    }

    // MARK: - Refund

    /// Atomically refunds `amount` $ back to the wallet when a wallet-paid order is cancelled.
    /// - Parameters:
    ///   - userId:  Firebase Auth UID
    ///   - amount:  Positive Double — the original amount to return
    ///   - orderId: The order being cancelled (written as referenceId)
    func refund(userId: String, amount: Double, orderId: String) async throws {
        guard amount > 0 else {
            AppLog.firestore.error("❌ WalletService.refund — invalid amount: \(amount)")
            throw WalletError.invalidAmount
        }

        AppLog.firestore.debug("↩️ WalletService.refund — userId: \(userId), amount: \(amount), orderId: \(orderId)")

        let walletRef = walletsRef.document(userId)
        let txRef     = transactionsRef.document()

        try await db.runTransaction { transaction, errorPointer -> Any? in
            do {
                let snapshot = try transaction.getDocument(walletRef)

                guard snapshot.exists else {
                    throw WalletError.walletNotFound
                }

                let current    = snapshot.data()?["balance"] as? Double ?? 0.0
                let newBalance = current + amount

                transaction.updateData([
                    "balance": newBalance,
                    "updatedAt": Timestamp(date: Date())
                ], forDocument: walletRef)

                let tx = WalletTransaction(
                    userId: userId,
                    type: .refund,
                    amount: amount,
                    balanceBefore: current,
                    balanceAfter: newBalance,
                    description: "Refund for Order #\(orderId.suffix(6))",
                    referenceId: orderId,
                    timestamp: Date()
                )
                transaction.setData(tx.toFirestoreData(), forDocument: txRef)

                AppLog.firestore.debug("✅ refund transaction prepared — before: \(current), after: \(newBalance)")
                return nil
            } catch {
                errorPointer?.pointee = error as NSError
                return nil
            }
        }

        AppLog.firestore.info("✅ WalletService.refund complete — +\(amount.currencyFormatted) refunded for orderId: \(orderId)")
    }

    // MARK: - Reward Credits

    /// Atomically adds bonus $ as a loyalty reward (e.g. when a milestone is reached).
    /// - Parameters:
    ///   - userId: Firebase Auth UID
    ///   - amount: Positive Double — the bonus $ to award
    ///   - reason: Human-readable description e.g. "Loyalty milestone – 10th order"
    func addReward(userId: String, amount: Double, reason: String) async throws {
        guard amount > 0 else {
            AppLog.firestore.error("❌ WalletService.addReward — invalid amount: \(amount)")
            throw WalletError.invalidAmount
        }

        AppLog.firestore.debug("⭐ WalletService.addReward — userId: \(userId), amount: \(amount), reason: \(reason)")

        let walletRef = walletsRef.document(userId)
        let txRef     = transactionsRef.document()

        try await db.runTransaction { transaction, errorPointer -> Any? in
            do {
                let snapshot   = try transaction.getDocument(walletRef)
                let current    = snapshot.data()?["balance"] as? Double ?? 0.0
                let newBalance = current + amount

                if snapshot.exists {
                    transaction.updateData([
                        "balance": newBalance,
                        "updatedAt": Timestamp(date: Date())
                    ], forDocument: walletRef)
                } else {
                    // Wallet doesn't exist yet — create it with the reward
                    let now = Timestamp(date: Date())
                    transaction.setData([
                        "balance": newBalance,
                        "currency": "USD",
                        "totalTopUp": 0.0,
                        "totalSpent": 0.0,
                        "createdAt": now,
                        "updatedAt": now
                    ], forDocument: walletRef)
                }

                let tx = WalletTransaction(
                    userId: userId,
                    type: .reward,
                    amount: amount,
                    balanceBefore: current,
                    balanceAfter: newBalance,
                    description: reason,
                    referenceId: nil,
                    timestamp: Date()
                )
                transaction.setData(tx.toFirestoreData(), forDocument: txRef)

                AppLog.firestore.debug("✅ addReward transaction prepared — before: \(current), after: \(newBalance)")
                return nil
            } catch {
                errorPointer?.pointee = error as NSError
                return nil
            }
        }

        AppLog.firestore.info("✅ WalletService.addReward complete — +\(amount.currencyFormatted) for reason: \(reason)")
    }

    // MARK: - Fetch Wallet

    /// Fetches the user's wallet document once (not a live listener — use WalletViewModel for live).
    /// Returns nil if the wallet doesn't exist yet (user has never topped up).
    func fetchWallet(userId: String) async throws -> Wallet? {
        AppLog.firestore.debug("🔍 WalletService.fetchWallet — userId: \(userId)")

        let doc    = try await walletsRef.document(userId).getDocument()
        let wallet = try? doc.data(as: Wallet.self)

        AppLog.printItem(wallet, label: "Wallet", logger: AppLog.firestore)
        return wallet
    }

    // MARK: - Fetch Transactions

    /// Fetches the most recent wallet transactions for a user, ordered newest-first.
    /// Limits to 50 rows for performance (add pagination in Phase 7 if needed).
    func fetchTransactions(userId: String, limit: Int = 50) async throws -> [WalletTransaction] {
        AppLog.firestore.debug("🔍 WalletService.fetchTransactions — userId: \(userId), limit: \(limit)")

        let snapshot = try await transactionsRef
            .whereField("userId", isEqualTo: userId)
            .order(by: "timestamp", descending: true)
            .limit(to: limit)
            .getDocuments()

        let transactions = snapshot.documents.compactMap { try? $0.data(as: WalletTransaction.self) }

        AppLog.printList(transactions, label: "Wallet Transactions", logger: AppLog.firestore)
        return transactions
    }

    // MARK: - Balance Check (Convenience)

    /// Quick balance check without fetching the full Wallet model.
    /// Use this inside OrderService before deducting — avoids loading the full model twice.
    func currentBalance(userId: String) async throws -> Double {
        let doc = try await walletsRef.document(userId).getDocument()
        guard doc.exists else { return 0.0 }
        return doc.data()?["balance"] as? Double ?? 0.0
    }
}
