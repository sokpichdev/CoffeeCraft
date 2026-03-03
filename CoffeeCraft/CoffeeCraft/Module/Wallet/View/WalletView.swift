//
//  WalletView.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 03/03/2026.
//
import SwiftUI

struct WalletView: View {

    @Environment(\.dismiss) private var dismiss
    @StateObject private var vm = WalletViewModel()
    @State private var showTopUp: Bool = false

    var body: some View {
        CustomRefreshScrollView({
            VStack(spacing: 20) {

                WalletBalanceCard(
                    wallet: vm.wallet,
                    isLoading: vm.isLoading
                ) {
                    showTopUp = true
                }

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
            TopUpView(walletVM: vm)
        }
        .onAppear {
            guard let userId = UserSession.shared.userId else { return }
            vm.setup(userId: userId)
        }
    }
}
