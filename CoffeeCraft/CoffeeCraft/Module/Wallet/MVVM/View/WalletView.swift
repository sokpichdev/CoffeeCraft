//
//  WalletView.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 03/03/2026.
//
import SwiftUI

struct WalletView: View {
    var showWallet: Bool = true
    @Environment(\.dismiss) private var dismiss
    @Environment(\.pushScreen) private var push
    @StateObject private var vm = WalletViewModel()

    var body: some View {
        CustomRefreshScrollView({
            VStack(spacing: 20) {

                if showWallet {
                    WalletBalanceCard(
                        wallet: vm.wallet,
                        isLoading: vm.isLoading,
                        cardWidth: UIScreen.main.bounds.width - 32
                    ) {
                        push(AnyView(TopUpView(walletVM: vm)))
                    }
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
            .padding(.horizontal)
            .padding(.top, 8)
        }, onRefresh: {
            await vm.refresh()
        })
        .background(Color.bgPrimary)
        .customNavigationBar(showWallet ? "My Wallet" : "My Transactions") {
            ToolBarButton.back { dismiss() }
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
                .foregroundColor(Color.semanticError)

            Text(message)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(Color.semanticError)

            Spacer()

            Button {
                Task { await vm.refresh() }
            } label: {
                Text("Retry")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color.semanticError)
                    .clipShape(Capsule())
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(Color.semanticError.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .strokeBorder(Color.semanticError.opacity(0.2), lineWidth: 1)
        )
        .transition(.move(edge: .top).combined(with: .opacity))
    }
}
