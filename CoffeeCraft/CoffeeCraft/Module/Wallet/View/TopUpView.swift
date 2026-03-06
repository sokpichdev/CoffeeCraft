//
//  TopUpView.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 03/03/2026.
//

import SwiftUI

// MARK: - Bank Option
struct BankOption: Identifiable {
    let id: String
    let name: String
    let icon: String
    let color: Color
    let description: String
}

private let bankOptions: [BankOption] = [
    BankOption(id: "aba", name: "ABA Bank", icon: "building.columns.fill", color: .blue, description: "Scan & Pay via ABA Mobile"),
    BankOption(id: "vattanac", name: "Vattanac Bank", icon: "building.columns.fill", color: Color(hex: "1A56DB"), description: "Scan & Pay via Vattanac Mobile"),
    BankOption(id: "acleda", name: "ACLEDA Bank", icon: "building.columns.fill", color: .orange, description: "Scan & Pay via ACLEDA Unity"),
    BankOption(id: "wing", name: "Wing Bank", icon: "w.circle.fill", color: .green, description: "Scan & Pay via Wing Mobile")
]

// MARK: - TopUpView (sheet root)
struct TopUpView: View {

    @ObservedObject var walletVM: WalletViewModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.pushScreen) private var push
    @State private var selectedUSD: Double?
    @State private var customInput: String = ""
    @State private var selectedBank: BankOption?

    var body: some View {
//        CustomNavigationStack {
            TopUpAmountStep(
                walletVM: walletVM,
                selectedUSD: $selectedUSD,
                customInput: $customInput,
                selectedBank: $selectedBank,
                onContinue: {
                    if let bank = selectedBank, let usd = resolvedUSD {
                        push(AnyView(TopUpCheckoutStep(
                            walletVM: walletVM,
                            bank: bank,
                            usdAmount: usd,
                            onSuccess: { dismiss() }
                        )))
                    }
                }
            )
//        }
//        .presentationDetents([.large])
//        .presentationDragIndicator(.visible)
    }
    private var resolvedUSD: Double? {
        if let s = selectedUSD { return s }
        if let v = Double(customInput), v > 0 { return v }
        return nil
    }
}

// MARK: - Step 1: Amount
private struct TopUpAmountStep: View {

    @ObservedObject var walletVM: WalletViewModel
    @Binding var selectedUSD: Double?
    @Binding var customInput: String
    @Binding var selectedBank: BankOption?
    let onContinue: () -> Void

    @FocusState private var keyboardFocused: Bool

    private let presets: [(usd: Double, badge: String?)] = [
        (2, nil), (5, nil), (10, "Popular"), (20, "Best Value")
    ]

    private var resolvedUSD: Double? {
        if let s = selectedUSD { return s }
        if let v = Double(customInput), v > 0 { return v }
        return nil
    }

    var body: some View {
        CustomRefreshScrollView( {
            VStack(spacing: 28) {

                VStack(spacing: 8) {
                    ZStack {
                        Circle().fill(Color.accentPrimary.opacity(0.1)).frame(width: 64, height: 64)
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 32)).foregroundStyle(Color.accentPrimary)
                    }
                    Text("Top Up Wallet").font(.title2).fontWeight(.bold)
                    Text("Choose an amount to add to your wallet")
                        .font(.subheadline).foregroundStyle(.secondary).multilineTextAlignment(.center)

                    HStack(spacing: 5) {
                        Image(systemName: "creditcard.fill").font(.caption)
                        Text("Balance: \(walletVM.formattedBalance)").font(.caption).fontWeight(.medium)
                    }
                    .foregroundStyle(Color.accentPrimary)
                    .padding(.horizontal, 14).padding(.vertical, 6)
                    .background(Color.accentPrimary.opacity(0.1)).clipShape(Capsule())
                }
                .padding(.top, 8)

                VStack(alignment: .leading, spacing: 12) {
                    Text("Choose Amount").font(.subheadline).fontWeight(.semibold)
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        ForEach(presets, id: \.usd) { option in
                            PresetAmountButton(
                                usd: option.usd,
                                badge: option.badge,
                                isSelected: selectedUSD == option.usd && customInput.isEmpty
                            ) {
                                selectedUSD     = option.usd
                                customInput     = ""
                                keyboardFocused = false
                            }
                        }
                    }
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Or enter amount (USD)").font(.subheadline).fontWeight(.semibold)
                    HStack(spacing: 10) {
                        Text("$").font(.title3).fontWeight(.bold).foregroundStyle(Color.accentPrimary)
                        TextField("0.00", text: $customInput)
                            .keyboardType(.decimalPad)
                            .focused($keyboardFocused)
                            .font(.title3).fontWeight(.semibold)
                            .onChange(of: customInput) { _, _ in selectedUSD = nil }
                        if !customInput.isEmpty {
                            Text((Double(customInput) ?? 0).currencyFormatted)
                                .font(.caption).foregroundStyle(.secondary)
                        }
                    }
                    .padding(.horizontal, 16).padding(.vertical, 14)
                    .background(RoundedRectangle(cornerRadius: 14)
                        .fill(Color(.secondarySystemGroupedBackground)))
                    .overlay(RoundedRectangle(cornerRadius: 14)
                        .strokeBorder(
                            keyboardFocused ? Color.accentPrimary : Color.accentPrimary.opacity(0.2),
                            lineWidth: keyboardFocused ? 2 : 1
                        ))
                }

                if let usd = resolvedUSD, usd > 0 {
                    VStack(spacing: 0) {
                        summaryRow(label: "You pay", value: String(format: "$%.2f", usd))
                        Divider().padding(.horizontal, 16)
                        summaryRow(label: "You receive", value: "+\(usd.currencyFormatted)", highlight: true)
                        Divider().padding(.horizontal, 16)
                        summaryRow(
                            label: "New balance",
                            value: ((walletVM.wallet?.balance ?? 0) + usd).currencyFormatted
                        )
                    }
                    .background(Color(.secondarySystemGroupedBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }

                VStack(alignment: .leading, spacing: 12) {
                    Text("Payment Method").font(.subheadline).fontWeight(.semibold)
                    VStack(spacing: 8) {
                        ForEach(bankOptions) { bank in
                            BankRow(bank: bank, isSelected: selectedBank?.id == bank.id) {
                                selectedBank = bank
                            }
                        }
                    }
                }

                CustomCoffeeButton(
                    title: "Continue",
                    buttonImage: "arrow.right.circle.fill",
                    bgColors: [Color.accentPrimary, Color.coffeeLight],
                    isDisabled: resolvedUSD == nil || (resolvedUSD ?? 0) <= 0 || selectedBank == nil
                ) {
                    keyboardFocused = false
                    onContinue()
                }

                Spacer().frame(height: 20)
            }
            .padding(.horizontal, 20)
            .animation(.spring(duration: 0.3), value: resolvedUSD != nil)
        })
        .background(Color(.systemGroupedBackground))
        .customNavigationBar("Top Up")
    }

    private func summaryRow(label: String, value: String, highlight: Bool = false) -> some View {
        HStack {
            Text(label).font(.subheadline).foregroundStyle(.secondary)
            Spacer()
            Text(value).font(.subheadline).fontWeight(.bold)
                .foregroundStyle(highlight ? Color.semanticSuccess : Color.accentPrimary)
        }
        .padding(.horizontal, 16).padding(.vertical, 14)
    }
}

// MARK: - Preset Amount Button
private struct PresetAmountButton: View {
    let usd: Double; let badge: String?
    let isSelected: Bool; let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            ZStack(alignment: .topTrailing) {
                VStack(spacing: 4) {
                    Text(usd.currencyFormatted)
                        .font(.title2).fontWeight(.bold)
                        .foregroundStyle(isSelected ? .white : .primary)
                }
                .frame(maxWidth: .infinity).padding(.vertical, 20)
                .background(RoundedRectangle(cornerRadius: 16).fill(
                    isSelected
                        ? AnyShapeStyle(LinearGradient(colors: [Color.accentPrimary, Color.coffeeLight], startPoint: .topLeading, endPoint: .bottomTrailing))
                        : AnyShapeStyle(Color(.secondarySystemGroupedBackground))
                ))
                .overlay(RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(isSelected ? Color.accentPrimary : Color.accentPrimary.opacity(0.15), lineWidth: isSelected ? 2 : 1))
                .shadow(color: isSelected ? Color.accentPrimary.opacity(0.35) : .clear, radius: 8, y: 4)

                if let badge {
                    Text(badge).font(.system(size: 9, weight: .bold)).foregroundStyle(.white)
                        .padding(.horizontal, 6).padding(.vertical, 3)
                        .background(Capsule().fill(Color.semanticError))
                        .offset(x: -8, y: 8)
                }
            }
        }
        .buttonStyle(.plain)
        .scaleEffect(isSelected ? 1.03 : 1.0)
        .animation(.spring(duration: 0.25), value: isSelected)
    }
}

// MARK: - Step 2: Bank Selection
private struct TopUpBankStep: View {
    @Binding var selectedBank: BankOption?
    let onContinue: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(bankOptions) { bank in
                        BankRow(bank: bank, isSelected: selectedBank?.id == bank.id) {
                            selectedBank = bank
                        }
                    }
                }
                .padding(20)
            }
            VStack(spacing: 0) {
                Divider()
                CustomCoffeeButton(
                    title: "Continue", buttonImage: "arrow.right.circle.fill",
                    bgColors: [Color.accentPrimary, Color.coffeeLight],
                    isDisabled: selectedBank == nil
                ) { onContinue() }
                .padding(20)
            }
            .background(Color(.systemGroupedBackground))
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Payment Method")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct BankRow: View {
    let bank: BankOption; let isSelected: Bool; let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12).fill(bank.color.opacity(0.12)).frame(width: 48, height: 48)
                    Image(systemName: bank.icon).font(.system(size: 20, weight: .semibold)).foregroundStyle(bank.color)
                }
                VStack(alignment: .leading, spacing: 3) {
                    Text(bank.name).font(.subheadline).fontWeight(.semibold).foregroundStyle(.primary)
                    Text(bank.description).font(.caption).foregroundStyle(.secondary)
                }
                Spacer()
                ZStack {
                    Circle().strokeBorder(isSelected ? Color.accentPrimary : Color.secondary.opacity(0.3), lineWidth: 2).frame(width: 22, height: 22)
                    if isSelected { Circle().fill(Color.accentPrimary).frame(width: 12, height: 12) }
                }
            }
            .padding(16)
            .background(RoundedRectangle(cornerRadius: 16)
                .fill(isSelected ? Color.accentPrimary.opacity(0.06) : Color(.secondarySystemGroupedBackground)))
            .overlay(RoundedRectangle(cornerRadius: 16)
                .strokeBorder(isSelected ? Color.accentPrimary.opacity(0.4) : Color.clear, lineWidth: 1.5))
        }
        .buttonStyle(.plain)
        .animation(.spring(duration: 0.2), value: isSelected)
    }
}

// MARK: - Step 3: Checkout
private struct TopUpCheckoutStep: View {
    @ObservedObject var walletVM: WalletViewModel
    let bank: BankOption; let usdAmount: Double
    let onSuccess: () -> Void

    @State private var isLoading = false

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 24) {
                    VStack(spacing: 0) {
                        ZStack {
                            LinearGradient(colors: [bank.color, bank.color.opacity(0.75)], startPoint: .topLeading, endPoint: .bottomTrailing)
                            VStack(spacing: 6) {
                                Image(systemName: bank.icon).font(.system(size: 28, weight: .semibold)).foregroundStyle(.white)
                                Text(bank.name).font(.title3).fontWeight(.bold).foregroundStyle(.white)
                            }
                        }
                        .frame(height: 100)
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

                    HStack(spacing: 8) {
                        Image(systemName: "info.circle.fill").foregroundStyle(Color.accentPrimary)
                        Text("Balance will be credited instantly after payment is confirmed.")
                            .font(.caption).foregroundStyle(.secondary)
                    }
                    .padding(14)
                    .background(Color.accentPrimary.opacity(0.07))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .padding(20)
            }

            VStack(spacing: 0) {
                Divider()
                CustomCoffeeButton(
                    title: isLoading ? "Processing..." : "Pay \(String(format: "$%.2f", usdAmount))",
                    buttonImage: isLoading ? "" : "checkmark.circle.fill",
                    bgColors: [Color.accentPrimary, Color.coffeeLight],
                    isDisabled: isLoading
                ) { Task { await pay() } }
                .padding(20)
            }
            .background(Color(.systemGroupedBackground))
        }
        .background(Color(.systemGroupedBackground))
        .customNavigationBar("Checkout")
    }

    private func checkoutRow(label: String, value: String, highlight: Bool = false) -> some View {
        HStack {
            Text(label).font(.subheadline).foregroundStyle(.secondary)
            Spacer()
            Text(value).font(.subheadline).fontWeight(.bold)
                .foregroundStyle(highlight ? Color.semanticSuccess : .primary)
        }
        .padding(.horizontal, 16).padding(.vertical, 14)
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
