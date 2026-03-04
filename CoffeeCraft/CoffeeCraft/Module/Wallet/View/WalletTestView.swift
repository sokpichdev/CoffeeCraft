//
//  WalletTestView.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 03/03/2026.
//
//  ⚠️ TEMPORARY — Phase 1 test harness only.
//  Delete this file after Phase 1 is verified in Firebase console.
//

import SwiftUI

struct WalletTestView: View {

    @Environment(\.dismiss) private var dismiss

    // MARK: - State

    @State private var wallet: Wallet?
    @State private var transactions: [WalletTransaction] = []
    @State private var isLoading = false
    @State private var lastAction = "—"

    // MARK: - Helpers

    private var userId: String {
        UserSession.shared.userId ?? "NO_USER"
    }

    private var isLoggedIn: Bool {
        UserSession.shared.isLoggedIn
    }

    // MARK: - Body

    var body: some View {
        CustomRefreshScrollView({
            VStack(spacing: 20) {

                // ── Warning banner ──────────────────────────────
                warningBanner

                // ── Auth status ─────────────────────────────────
                authStatusCard

                // ── Current wallet ──────────────────────────────
                walletCard

                // ── Test actions ────────────────────────────────
                testActionsCard

                // ── Transaction log ─────────────────────────────
                transactionLogCard
            }
            .padding()
        }, onRefresh: {
            await refresh()
        })
        .background(Color(.systemGroupedBackground))
        .customNavigationBar("Wallet Phase 1 Test") {
            ToolBarButton.back { dismiss() }
        }
        .task { await refresh() }
    }

    // MARK: - Sub-views

    private var warningBanner: some View {
        HStack(spacing: 10) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(Color.semanticWarning)
            VStack(alignment: .leading, spacing: 2) {
                Text("Dev Only — Delete After Phase 1")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(Color.semanticWarning)
                Text("Remove WalletTestView.swift before release.")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding(12)
        .background(Color.semanticWarning.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.semanticWarning.opacity(0.4), lineWidth: 1)
        )
    }

    private var authStatusCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("Auth Status", systemImage: "person.circle")
                .font(.subheadline.weight(.semibold))

            HStack {
                Circle()
                    .fill(isLoggedIn ? Color.semanticSuccess : Color.semanticError)
                    .frame(width: 8, height: 8)
                Text(isLoggedIn ? "Logged in" : "Not logged in — sign in first")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            if isLoggedIn {
                Group {
                    labelRow("Name",   UserSession.shared.userName ?? "—")
                    labelRow("UID",    userId)
                    labelRow("Role",   UserSession.shared.userRole?.rawValue ?? "—")
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    private var walletCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("Firestore Wallet Document", systemImage: "creditcard")
                .font(.subheadline.weight(.semibold))

            if let wallet {
                Group {
                    labelRow("Balance",    wallet.formattedBalance)
                    labelRow("Currency",   wallet.currency)
                    labelRow("Total Top-Up", wallet.totalTopUp.currencyFormatted)
                    labelRow("Total Spent",  wallet.totalSpent.currencyFormatted)
                    labelRow("Updated At", wallet.updatedAt.formatted(date: .abbreviated, time: .shortened))
                }
            } else {
                HStack {
                    Image(systemName: "exclamationmark.circle")
                        .foregroundStyle(.secondary)
                    Text("No wallet found — tap Top-Up to create it")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Text("Last action: \(lastAction)")
                .font(.caption2)
                .foregroundStyle(.secondary)
                .padding(.top, 4)
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    private var testActionsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Test Actions", systemImage: "flask.fill")
                .font(.subheadline.weight(.semibold))

            // Top-Up buttons
            Text("Top-Up (writes to wallets + wallet_transactions)")
                .font(.caption)
                .foregroundStyle(.secondary)

            HStack(spacing: 10) {
                ForEach([50.0, 100.0, 200.0], id: \.self) { amount in
                    testButton(
                        title: "+\(amount.currencyFormatted)",
                        color: Color.semanticSuccess,
                        disabled: !isLoggedIn || isLoading
                    ) {
                        await runAction("Top-Up \(amount.currencyFormatted)") {
                            try await WalletService.shared.topUp(userId: userId, amount: amount)
                        }
                    }
                }
            }

            Divider()

            // Deduct button
            Text("Deduct (simulates paying for order #TEST01)")
                .font(.caption)
                .foregroundStyle(.secondary)

            testButton(
                title: "Deduct $20",
                color: Color.semanticError,
                disabled: !isLoggedIn || isLoading || (wallet?.balance ?? 0) < 20
            ) {
                await runAction("Deduct $20") {
                    try await WalletService.shared.deductForOrder(
                        userId: userId,
                        amount: 20,
                        orderId: "TEST01"
                    )
                }
            }

            Divider()

            // Refund button
            Text("Refund (simulates cancelling order #TEST01)")
                .font(.caption)
                .foregroundStyle(.secondary)

            testButton(
                title: "Refund $20",
                color: Color.activeTF,
                disabled: !isLoggedIn || isLoading
            ) {
                await runAction("Refund $20") {
                    try await WalletService.shared.refund(
                        userId: userId,
                        amount: 20,
                        orderId: "TEST01"
                    )
                }
            }

            Divider()

            // Reward button
            Text("Reward (simulates loyalty milestone)")
                .font(.caption)
                .foregroundStyle(.secondary)

            testButton(
                title: "+ $15 Reward",
                color: Color.vanillaYellow,
                disabled: !isLoggedIn || isLoading
            ) {
                await runAction("Reward +$15") {
                    try await WalletService.shared.addReward(
                        userId: userId,
                        amount: 15,
                        reason: "Loyalty milestone – 10th order"
                    )
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    private var transactionLogCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("Transaction Log (\(transactions.count))", systemImage: "list.bullet.rectangle")
                .font(.subheadline.weight(.semibold))

            if transactions.isEmpty {
                Text("No transactions yet — run a test action above")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } else {
                ForEach(transactions) { tx in
                    HStack(spacing: 10) {
                        Image(systemName: tx.type.icon)
                            .foregroundStyle(tx.type.color)
                            .frame(width: 20)

                        VStack(alignment: .leading, spacing: 2) {
                            Text(tx.description)
                                .font(.caption.weight(.medium))
                            Text(tx.formattedDate)
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }

                        Spacer()

                        Text(tx.formattedAmount)
                            .font(.caption.weight(.bold))
                            .foregroundStyle(tx.isCredit ? Color.semanticSuccess : Color.semanticError)
                    }
                    .padding(.vertical, 4)

                    if tx.id != transactions.last?.id {
                        Divider()
                    }
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    // MARK: - Helpers

    private func labelRow(_ label: String, _ value: String) -> some View {
        HStack {
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
                .frame(width: 90, alignment: .leading)
            Text(value)
                .font(.caption.weight(.medium))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
    }

    private func testButton(
        title: String,
        color: Color,
        disabled: Bool,
        action: @escaping () async -> Void
    ) -> some View {
        Button {
            Task { await action() }
        } label: {
            HStack {
                if isLoading {
                    ProgressView()
                        .scaleEffect(0.8)
                        .tint(.white)
                }
                Text(title)
                    .font(.subheadline.weight(.semibold))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(disabled ? Color.surfaceSub : color)
            .foregroundColor(disabled ? .secondary : .white)
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .disabled(disabled)
    }

    // MARK: - Actions

    @MainActor
    private func runAction(_ label: String, action: @escaping () async throws -> Void) async {
        isLoading = true
        lastAction = "\(label) — running…"

        do {
            try await action()
            lastAction = "✅ \(label) succeeded"
            ToastManager.shared.show(message: "\(label) succeeded", type: .success)
            await refresh()
        } catch {
            lastAction = "❌ \(label) failed: \(error.localizedDescription)"
            AlertManager.shared.showError(message: error.localizedDescription)
        }

        isLoading = false
    }

    private func refresh() async {
        guard isLoggedIn else { return }
        do {
            wallet       = try await WalletService.shared.fetchWallet(userId: userId)
            transactions = try await WalletService.shared.fetchTransactions(userId: userId)
        } catch {
            AppLog.firestore.error("❌ WalletTestView refresh error: \(error.localizedDescription)")
        }
    }
}
