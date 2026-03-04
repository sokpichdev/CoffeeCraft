//
//  WalletViewModel.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 03/03/2026.
//

import Foundation
import FirebaseFirestore

@MainActor
class WalletViewModel: ObservableObject {

    @Published var wallet: Wallet?
    @Published var transactions: [WalletTransaction] = []
    @Published var isLoading: Bool = false
    @Published var isRefreshing: Bool = false
    @Published var errorMessage: String? = nil

    private let service = WalletService.shared
    private var walletListener: ListenerRegistration?
    private var currentUserId: String?

    func setup(userId: String, isRefresh: Bool = false) {
        currentUserId = userId
        if isRefresh { isRefreshing = true } else { isLoading = true }
        AppLog.firestore.debug("🔌 WalletViewModel.setup — uid: \(userId)")
        attachWalletListener(userId: userId)
        Task { await loadTransactions(userId: userId) }
    }

    private func attachWalletListener(userId: String) {
        walletListener?.remove()
        walletListener = Firestore.firestore()
            .collection("wallets")
            .document(userId)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self else { return }
                if let error {
                    AppLog.firestore.error("❌ WalletViewModel listener: \(error.localizedDescription)")
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

    func loadTransactions(userId: String) async {
        do {
            transactions = try await service.fetchTransactions(userId: userId)
            errorMessage = nil
        } catch {
            AppLog.firestore.error("❌ WalletViewModel.loadTransactions: \(error.localizedDescription)")
            errorMessage = "Could not load transactions. Pull down to retry."
        }
    }

    func refresh() async {
        guard let userId = currentUserId else { return }
        isRefreshing = true
        await loadTransactions(userId: userId)
        isRefreshing = false
    }

    func canAfford(_ amount: Double) -> Bool {
        wallet?.canAfford(amount) ?? false
    }

    var formattedBalance: String {
        wallet?.formattedBalance ?? "0 CC"
    }

    var hasWallet: Bool { wallet != nil }

    deinit { walletListener?.remove() }
}
