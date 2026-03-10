//
//  WalletViewModel.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 03/03/2026.
//

import FirebaseFirestore
import Foundation

@MainActor
class WalletViewModel: ObservableObject {

    @Published var wallet: Wallet?
    @Published var transactions: [WalletTransaction] = []
    @Published var isLoading: Bool = false
    @Published var isRefreshing: Bool = false
    @Published var errorMessage: String?

    private let db = Firestore.firestore()
    private var walletListener: ListenerRegistration?
    private var transactionsListener: ListenerRegistration?
    private var currentUserId: String?

    /// Call once on view appear. Attaches both listeners — balance and transactions
    /// both update in real time without any further fetches or pull-to-refresh.
    func setup(userId: String, isRefresh: Bool = false) {
        currentUserId = userId
        if isRefresh { isRefreshing = true } else { isLoading = true }
        AppLog.firestore.debug("🔌 WalletViewModel.setup — uid: \(userId)")
        attachWalletListener(userId: userId)
        attachTransactionsListener(userId: userId)
    }

    // MARK: - Balance listener

    private func attachWalletListener(userId: String) {
        walletListener?.remove()
        walletListener = db.collection("wallets")
            .document(userId)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self else { return }
                if let error {
                    AppLog.firestore.error("❌ WalletViewModel walletListener: \(error.localizedDescription)")
                    self.errorMessage = "Could not load wallet. Pull down to retry."
                    self.isLoading = false
                    self.isRefreshing = false
                    return
                }
                self.errorMessage = nil
                self.wallet = try? snapshot?.data(as: Wallet.self)
                self.isLoading = false
                self.isRefreshing = false
                AppLog.printItem(self.wallet, label: "Wallet (live)", logger: AppLog.firestore)
            }
    }

    // MARK: - Transactions listener

    /// Listens to the 50 most recent transactions. Because wallet_transactions is
    /// append-only (top-up, payment, refund, reward) we only handle .added —
    /// existing entries never change so .modified can be safely ignored.
    /// New entries appear instantly without a pull-to-refresh.
    private func attachTransactionsListener(userId: String) {
        transactionsListener?.remove()
        AppLog.firestore.debug("🔌 WalletViewModel.attachTransactionsListener — uid: \(userId)")

        transactionsListener = db.collection("wallet_transactions")
            .whereField("userId", isEqualTo: userId)
            .order(by: "timestamp", descending: true)
            .limit(to: 50)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self else { return }

                if let error {
                    AppLog.firestore.error("❌ WalletViewModel transactionsListener: \(error.localizedDescription)")
                    self.errorMessage = "Could not load transactions. Pull down to retry."
                    return
                }

                guard let changes = snapshot?.documentChanges else { return }

                for change in changes where change.type == .added {
                    if let tx = try? change.document.data(as: WalletTransaction.self),
                       !self.transactions.contains(where: { $0.id == tx.id }) {
                        self.transactions.insert(tx, at: 0)
                        AppLog.firestore.debug("➕ transactionsListener — new tx: \(tx.id ?? "nil"), type: \(tx.type.rawValue)")
                    }
                }
            }
    }

    // MARK: - Refresh

    /// Re-attaches both listeners — picks up any changes missed while offline.
    /// Clears transactions first so the list rebuilds cleanly from the listener's
    /// initial snapshot rather than accumulating duplicates.
    func refresh() async {
        guard let userId = currentUserId else { return }
        isRefreshing = true
        transactions = []
        attachWalletListener(userId: userId)
        attachTransactionsListener(userId: userId)
    }

    // MARK: - Helpers

    func canAfford(_ amount: Double) -> Bool {
        wallet?.canAfford(amount) ?? false
    }

    var formattedBalance: String {
        wallet?.formattedBalance ?? "$0"
    }

    var hasWallet: Bool { wallet != nil }

    deinit {
        walletListener?.remove()
        transactionsListener?.remove()
    }
}
