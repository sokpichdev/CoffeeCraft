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
                                    .foregroundStyle(Color.bgPrimary)
                                
                                Text(bank.name)
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .foregroundStyle(Color.bgPrimary)
                            }
                        }
                        .frame(height: 110)
                        .clipShape(UnevenRoundedRectangle(topLeadingRadius: 20, topTrailingRadius: 20))

                        VStack(spacing: 0) {
                            checkoutRow(label: "Recipient", value: "CoffeeCraft Wallet")
                            Divider()
                                .overlay(Color.border)
                                .padding(.horizontal, 16)
                            checkoutRow(label: "Amount", value: String(format: "$%.2f USD", usdAmount))
                            Divider()
                                .overlay(Color.border)
                                .padding(.horizontal, 16)
                            checkoutRow(label: "You receive", value: "+\(usdAmount.currencyFormatted)", highlight: true)
                            Divider()
                                .overlay(Color.border)
                                .padding(.horizontal, 16)
                            checkoutRow(label: "Method", value: bank.name)
                        }
                        .background(Color.surfacePrimary)
                        .clipShape(UnevenRoundedRectangle(bottomLeadingRadius: 20, bottomTrailingRadius: 20))
                    }
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .strokeBorder(Color.border, lineWidth: 1)
                    )
                    .shadow(color: Color.coffeeDarkBrown.opacity(0.08), radius: 12, y: 4)

                    // Info Note
                    HStack(spacing: 10) {
                        Image(systemName: "info.circle.fill")
                            .foregroundStyle(Color.accentGold)
                            .font(.system(size: 16))
                        
                        Text("Balance will be credited instantly after payment confirmation.")
                            .font(.caption)
                            .foregroundStyle(Color.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding()
                    .background(Color.parchment.opacity(0.55))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .strokeBorder(Color.accentGold.opacity(0.3), lineWidth: 1)
                    )
                }
                .padding()
            }

            // Pay Button
            VStack(spacing: 0) {
                Divider()
                    .overlay(Color.border)
                Button {
                    Task { await pay() }
                } label: {
                    HStack(spacing: 8) {
                        if isLoading {
                            ProgressView()
                                .tint(Color.bgPrimary)
                                .scaleEffect(0.8)
                        } else {
                            Image(systemName: "lock.fill")
                                .font(.system(size: 14))
                        }
                        
                        Text(isLoading ? "Processing..." : "Pay \(String(format: "$%.2f", usdAmount))")
                            .font(.headline)
                    }
                    .foregroundColor(Color.bgPrimary)
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
                .padding()
            }
            .background(Color.bgSecondary)
        }
        .background(Color.bgPrimary)
    }

    private func checkoutRow(label: String, value: String, highlight: Bool = false) -> some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundStyle(Color.textSecondary)
            Spacer()
            Text(value)
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundStyle(highlight ? Color.semanticSuccess : Color.textPrimary)
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
