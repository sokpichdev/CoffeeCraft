//
//  TopUpCheckoutStep.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 3/7/26.
//
import SwiftUI

struct TopUpCheckoutStep: View {
    @ObservedObject var walletVM: WalletViewModel
    let bank: BankOption
    let usdAmount: Double
    let onSuccess: () -> Void

    @State private var isLoading = false

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 24) {
                    // Bank Card
                    VStack(spacing: 0) {
                        ZStack {
                            LinearGradient(
                                colors: [bank.color, bank.color.opacity(0.75)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                            
                            VStack(spacing: 8) {
                                Image(systemName: bank.icon)
                                    .font(.system(size: 32, weight: .semibold))
                                    .foregroundStyle(.white)
                                
                                Text(bank.name)
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .foregroundStyle(.white)
                            }
                        }
                        .frame(height: 110)
                        .clipShape(UnevenRoundedRectangle(topLeadingRadius: 20, topTrailingRadius: 20))

                        VStack(spacing: 0) {
                            checkoutRow(label: "Recipient", value: "CoffeeCraft Wallet")
                            Divider().padding(.horizontal, 16)
                            checkoutRow(label: "Amount", value: String(format: "$%.2f USD", usdAmount))
                            Divider().padding(.horizontal, 16)
                            checkoutRow(label: "You receive", value: "+\(usdAmount.currencyFormatted)", highlight: true)
                            Divider().padding(.horizontal, 16)
                            checkoutRow(label: "Method", value: bank.name)
                        }
                        .background(Color(.secondarySystemGroupedBackground))
                        .clipShape(UnevenRoundedRectangle(bottomLeadingRadius: 20, bottomTrailingRadius: 20))
                    }
                    .shadow(color: Color.textPrimary.opacity(0.08), radius: 12, y: 4)

                    // Info Note
                    HStack(spacing: 10) {
                        Image(systemName: "info.circle.fill")
                            .foregroundStyle(Color.accentPrimary)
                            .font(.system(size: 16))
                        
                        Text("Balance will be credited instantly after payment confirmation.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(14)
                    .background(Color.accentPrimary.opacity(0.07))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .padding(20)
            }

            // Pay Button
            VStack(spacing: 0) {
                Divider()
                Button {
                    Task { await pay() }
                } label: {
                    HStack(spacing: 8) {
                        if isLoading {
                            ProgressView()
                                .tint(.white)
                                .scaleEffect(0.8)
                        } else {
                            Image(systemName: "lock.fill")
                                .font(.system(size: 14))
                        }
                        
                        Text(isLoading ? "Processing..." : "Pay \(String(format: "$%.2f", usdAmount))")
                            .font(.headline)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(
                                isLoading
                                ? Color.accentPrimary.opacity(0.6)
                                : Color.accentPrimary
                            )
                    )
                }
                .disabled(isLoading)
                .padding(20)
            }
            .background(Color(.systemGroupedBackground))
        }
        .background(Color(.systemGroupedBackground))
    }

    private func checkoutRow(label: String, value: String, highlight: Bool = false) -> some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundStyle(highlight ? Color.semanticSuccess : .primary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }

    @MainActor
    private func pay() async {
        guard let userId = UserSession.shared.userId else {
            AlertManager.shared.showError(message: WalletError.userNotAuthenticated.localizedDescription)
            return
        }
        isLoading = true
        do {
            try await WalletService.shared.topUp(userId: userId, amount: usdAmount)
            await walletVM.loadTransactions(userId: userId)
            ToastManager.shared.show(message: "+\(usdAmount.currencyFormatted) added to your wallet", type: .success)
            onSuccess()
        } catch {
            AlertManager.shared.showError(message: error.localizedDescription)
        }
        isLoading = false
    }
}
