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

                if let error = vm.errorMessage {
                    errorBanner(message: error)
                }

                FilteredTransactionView(
                    transactions: vm.transactions,
                    isLoading: vm.isLoading
                )

                Spacer().frame(height: 40)
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)

        }, onRefresh: {
            await vm.refresh()
        })
        .background(Color(hex: "#F5EDE4"))   // warm cream background
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

    func errorBanner(message: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: "wifi.exclamationmark")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Color(hex: "#C0392B"))

            Text(message)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(Color(hex: "#C0392B"))

            Spacer()

            Button {
                Task { await vm.refresh() }
            } label: {
                Text("Retry")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color(hex: "#C0392B"))
                    .clipShape(Capsule())
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(Color(hex: "#C0392B").opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .strokeBorder(Color(hex: "#C0392B").opacity(0.2), lineWidth: 1)
        )
        .transition(.move(edge: .top).combined(with: .opacity))
    }
}
