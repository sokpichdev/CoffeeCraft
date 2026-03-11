//
//  WalletRepositoryProtocol.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 3/11/26.
//
//  Covers all Firestore operations WalletViewModel needs:
//    • Two real-time listeners (wallet balance, transaction list)
//    • The topUp mutation (called from TopUpCheckoutStep via the VM)
//
//  WalletService stays unchanged — FirestoreWalletRepository delegates
//  the mutation work to WalletService.shared so logic isn't duplicated.
//
//  Listener methods return () -> Void cancel closures so this protocol
//  has zero Firebase imports, making it trivial to mock in unit tests.
//

protocol WalletRepositoryProtocol {

    // MARK: - Listeners

    /// Attaches a real-time listener to the user's wallet document.
    /// `onChange` is called with nil when the wallet doesn't exist yet.
    /// Returns a cancel closure — call it in deinit.
    func listenWallet(
        userId: String,
        onChange: @escaping (Wallet?) -> Void
    ) -> () -> Void

    /// Attaches a real-time listener for the 50 most recent transactions.
    /// `onChange` delivers only NEWLY ADDED transactions per snapshot diff
    /// so the ViewModel can insert them without rebuilding the full list.
    /// Returns a cancel closure — call it in deinit.
    func listenTransactions(
        userId: String,
        onChange: @escaping ([WalletTransaction]) -> Void
    ) -> () -> Void

    // MARK: - Mutations

    /// Atomically adds `amount` to the wallet balance and writes a ledger entry.
    func topUp(userId: String, amount: Double) async throws
}
