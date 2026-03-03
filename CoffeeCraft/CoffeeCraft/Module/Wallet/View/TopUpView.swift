//
//  TopUpView.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 03/03/2026.
//

import SwiftUI

struct TopUpView: View {

    @ObservedObject var walletVM: WalletViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var selectedAmount: Double? = nil
    @State private var isLoading: Bool = false

    private let presetAmounts: [(amount: Double, badge: String?)] = [
        (50,  nil),
        (100, nil),
        (200, "Popular"),
        (500, "Best Value"),
    ]

    var body: some View {
        VStack(spacing: 0) {
            Capsule()
                .fill(Color.secondary.opacity(0.3))
                .frame(width: 40, height: 5)
                .padding(.top, 12)
                .padding(.bottom, 24)

            ScrollView {
                VStack(spacing: 28) {
                    headerSection
                    amountGrid
                    summaryCard
                    confirmButton
                    Spacer().frame(height: 20)
                }
                .padding(.horizontal, 20)
            }
        }
        .background(Color(.systemGroupedBackground))
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.hidden)
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(Color.coffeeBrown.opacity(0.12))
                    .frame(width: 64, height: 64)
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 32))
                    .foregroundStyle(Color.coffeeBrown)
            }

            Text("Top Up Wallet")
                .font(.title2).fontWeight(.bold).foregroundStyle(.primary)

            Text("Select an amount to add to your CoffeeCoins balance")
                .font(.subheadline).foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            HStack(spacing: 6) {
                Image(systemName: "creditcard.fill").font(.caption)
                Text("Current balance: \(walletVM.formattedBalance)")
                    .font(.caption).fontWeight(.medium)
            }
            .foregroundStyle(Color.coffeeBrown)
            .padding(.horizontal, 14).padding(.vertical, 6)
            .background(Color.coffeeBrown.opacity(0.1))
            .clipShape(Capsule())
        }
    }

    // MARK: - Amount Grid

    private var amountGrid: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Choose Amount")
                .font(.subheadline).fontWeight(.semibold).foregroundStyle(.primary)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(presetAmounts, id: \.amount) { option in
                    TopUpAmountButton(
                        amount: option.amount,
                        badge: option.badge,
                        isSelected: selectedAmount == option.amount
                    ) {
                        withAnimation(.spring(duration: 0.25)) {
                            selectedAmount = option.amount
                        }
                    }
                }
            }
        }
    }

    // MARK: - Summary Card

    @ViewBuilder
    private var summaryCard: some View {
        if let amount = selectedAmount {
            VStack(spacing: 0) {
                summaryRow(label: "Adding", value: "+\(Int(amount)) CC", valueColor: .leafGreen)
                Divider().padding(.horizontal, 16)
                summaryRow(
                    label: "New balance",
                    value: "\(Int((walletVM.wallet?.balance ?? 0) + amount)) CC",
                    valueColor: Color.coffeeBrown
                )
            }
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .transition(.opacity.combined(with: .move(edge: .top)))
        }
    }

    private func summaryRow(label: String, value: String, valueColor: Color) -> some View {
        HStack {
            Text(label).font(.subheadline).foregroundStyle(.secondary)
            Spacer()
            Text(value).font(.subheadline).fontWeight(.bold).foregroundStyle(valueColor)
        }
        .padding(.horizontal, 16).padding(.vertical, 14)
    }

    // MARK: - Confirm Button

    private var confirmButton: some View {
        CustomCoffeeButton(
            title: isLoading ? "Processing..." : "Confirm Top-Up",
            buttonImage: isLoading ? "" : "checkmark.circle.fill",
            bgColors: [Color.coffeeBrown, Color.coffeeLight],
            isDisabled: selectedAmount == nil || isLoading
        ) {
            guard let amount = selectedAmount else { return }
            Task { await topUp(amount: amount) }
        }
    }

    // MARK: - Action

    @MainActor
    private func topUp(amount: Double) async {
        guard let userId = UserSession.shared.userId else {
            AlertManager.shared.showError(message: WalletError.userNotAuthenticated.localizedDescription)
            return
        }
        isLoading = true
        do {
            try await WalletService.shared.topUp(userId: userId, amount: amount)
            await walletVM.loadTransactions(userId: userId)
            ToastManager.shared.show(message: "+\(Int(amount)) CC added to your wallet", type: .success)
            dismiss()
        } catch {
            AlertManager.shared.showError(message: error.localizedDescription)
        }
        isLoading = false
    }
}
