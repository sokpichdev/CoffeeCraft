//
//  WalletView.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 03/03/2026.
//
import SwiftUI

// MARK: - WalletView
// Main wallet screen. Entry point from AccountView.
// Shows the balance card, top-up button, and transaction history.
//
// NAVIGATION: AccountView -> push(AnyView(WalletView()))
// ENV OBJECTS: WalletViewModel injected as @StateObject here
//              (not via EnvironmentObject — wallet is self-contained)

struct WalletView: View {

    @Environment(\.dismiss) private var dismiss
    @StateObject private var vm = WalletViewModel()
    @State private var showTopUp: Bool = false

    var body: some View {
        CustomRefreshScrollView({
            VStack(spacing: 20) {

                // Balance hero card
                WalletBalanceCard(
                    wallet: vm.wallet,
                    isLoading: vm.isLoading
                ) {
                    showTopUp = true
                }

                // Transaction history
                TransactionHistoryView(
                    transactions: vm.transactions,
                    isLoading: vm.isLoading
                )

                Spacer().frame(height: 40)
            }
            .padding()

        }, onRefresh: {
            await vm.refresh()
        })
        .background(Color(.systemGroupedBackground))
        .customNavigationBar("My Wallet") {
            ToolBarButton.back { dismiss() }
        }
        .sheet(isPresented: $showTopUp) {
            // TopUpView — built in Phase 3
            ComingSoonView()
        }
        .onAppear {
            guard let userId = UserSession.shared.userId else { return }
            vm.setup(userId: userId)
        }
    }
}
