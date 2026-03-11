//
//  WalletViewModel.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 03/03/2026.
//
//  Sprint 2: Firestore removed — all data access goes through WalletRepositoryProtocol.
//  Listener setup previously living in private methods now lives in
//  FirestoreWalletRepository; the VM only manages published state.
//

import Foundation

@MainActor
class WalletViewModel: ObservableObject {

    @Published var wallet: Wallet?
    @Published var transactions: [WalletTransaction] = []
    @Published var isLoading: Bool    = false
    @Published var isRefreshing: Bool = false
    @Published var errorMessage: String?

    private let repository: WalletRepositoryProtocol
    private var cancelWalletListener: (() -> Void)?
    private var cancelTransactionsListener: (() -> Void)?
    private var currentUserId: String?

    init(repository: WalletRepositoryProtocol = FirestoreWalletRepository()) {
        self.repository = repository
    }

    deinit {
        cancelWalletListener?()
        cancelTransactionsListener?()
    }

    // MARK: - Setup

    /// Attach both live listeners. Call once when the user session is known.
    func setup(userId: String, isRefresh: Bool = false) {
        currentUserId = userId
        if isRefresh { isRefreshing = true } else { isLoading = true }
        AppLog.wallet.debug("🔌 WalletViewModel.setup — uid: \(userId)")
        attachListeners(userId: userId)
    }

    // MARK: - Listeners

    private func attachListeners(userId: String) {
        // Remove existing listeners before re-attaching
        cancelWalletListener?()
        cancelTransactionsListener?()

        // Balance listener
        cancelWalletListener = repository.listenWallet(userId: userId) { [weak self] wallet in
            guard let self else { return }
            self.wallet = wallet
            self.isLoading = false
            self.isRefreshing = false
            self.errorMessage = nil
            AppLog.printItem(wallet, label: "Wallet (live)", logger: AppLog.wallet)
        }

        // Transactions listener — repository surfaces only newly .added docs
        cancelTransactionsListener = repository.listenTransactions(userId: userId) { [weak self] newTxs in
            guard let self else { return }
            // Deduplicate against what's already in the list
            let existingIds = Set(self.transactions.compactMap { $0.id })
            let unique = newTxs.filter { tx in
                guard let id = tx.id else { return false }
                return !existingIds.contains(id)
            }
            for tx in unique {
                self.transactions.insert(tx, at: 0)
                AppLog.wallet.debug("➕ new transaction: \(tx.id ?? "nil"), type: \(tx.type.rawValue)")
            }
        }
    }

    // MARK: - Refresh

    func refresh() async {
        guard let userId = currentUserId else { return }
        isRefreshing = true
        transactions = []
        attachListeners(userId: userId)
    }

    // MARK: - Helpers

    func canAfford(_ amount: Double) -> Bool { wallet?.canAfford(amount) ?? false }

    var formattedBalance: String { wallet?.formattedBalance ?? "$0" }

    var hasWallet: Bool { wallet != nil }
}
