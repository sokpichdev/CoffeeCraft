//
//  FilteredTransactionView.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 3/4/26.
//

import SwiftUI

// MARK: - FilteredTransactionView
// An enhanced transaction history view with type filtering capabilities.
// Uses a segmented picker for quick filtering and shows animated transitions
// when switching between transaction types.

struct FilteredTransactionView: View {
    let transactions: [WalletTransaction]
    let isLoading: Bool

    @State private var selectedFilter: TransactionFilter = .all
    @State private var appear = false

    enum TransactionFilter: String, CaseIterable {
        case all = "All"
        case topup = "Top-Up"
        case payment = "Payment"
        case refund = "Refund"
        case reward = "Reward"

        var transactionType: WalletTransactionType? {
            switch self {
            case .all: return nil
            case .topup: return .topup
            case .payment: return .payment
            case .refund: return .refund
            case .reward: return .reward
            }
        }

        var icon: String {
            switch self {
            case .all: return "square.grid.2x2"
            case .topup: return "arrow.down.circle"
            case .payment: return "cart"
            case .refund: return "arrow.uturn.left.circle"
            case .reward: return "star"
            }
        }
    }

    var filteredTransactions: [WalletTransaction] {
        guard let type = selectedFilter.transactionType else { return transactions }
        return transactions.filter { $0.type == type }
    }

    var netTotal: Double {
        filteredTransactions.reduce(0) { $0 + $1.amount }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {

            sectionHeader
            
            filterRow
            
            if !isLoading && !filteredTransactions.isEmpty {
                netTotalBanner
                    .transition(.opacity.combined(with: .scale(scale: 0.97, anchor: .top)))
            }
            
            contentSection

            Spacer().frame(height: 16)
        }
        .opacity(appear ? 1 : 0)
        .offset(y: appear ? 0 : 10)
        .onAppear {
            withAnimation(.easeOut(duration: 0.4).delay(0.2)) { appear = true }
        }
    }

    var sectionHeader: some View {
        HStack(alignment: .firstTextBaseline) {
            Text("Transactions")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(Color.textPrimary)

            Spacer()

            if !isLoading && !transactions.isEmpty {
                Text("\(filteredTransactions.count) record\(filteredTransactions.count == 1 ? "" : "s")")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(Color.textMuted)
                    .contentTransition(.numericText())
                    .animation(.easeInOut(duration: 0.2), value: filteredTransactions.count)
            }
        }
        .padding(.horizontal, 4)
    }

    var filterRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(TransactionFilter.allCases, id: \.self) { filter in
                    TransactionFilterChip(
                        filter: filter,
                        isSelected: selectedFilter == filter,
                        count: countForFilter(filter)
                    ) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                            selectedFilter = filter
                        }
                    }
                }
            }
            .padding(.horizontal, 4)
        }
    }

    func countForFilter(_ filter: TransactionFilter) -> Int {
        guard let type = filter.transactionType else { return transactions.count }
        return transactions.filter { $0.type == type }.count
    }

    var netTotalBanner: some View {
        let isPositive = netTotal >= 0
        let color: Color = isPositive ? Color.semanticSuccess : Color.semanticError

        return HStack(spacing: 6) {
            Image(systemName: isPositive ? "arrow.down.circle.fill" : "arrow.up.circle.fill")
                .font(.system(size: 13))
                .foregroundColor(color)

            Text(selectedFilter == .all ? "Net balance change" : "\(selectedFilter.rawValue) total")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(Color.textMuted)

            Spacer()

            Text((isPositive ? "+" : "") + netTotal.currencyFormatted)
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundColor(color)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(color.opacity(0.07))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(color.opacity(0.15), lineWidth: 1)
        )
        .padding(.horizontal, 4)
    }

    @ViewBuilder
    var contentSection: some View {
        if isLoading && transactions.isEmpty {
            shimmerList
        } else if filteredTransactions.isEmpty {
            emptyState
        } else {
            transactionList
        }
    }

    var transactionList: some View {
        VStack(spacing: 0) {
            ForEach(Array(filteredTransactions.enumerated()), id: \.element.id) { _, tx in
                WalletTransactionRow(transaction: tx)
                    .padding(.horizontal, 16)
                    .transition(
                        .asymmetric(
                            insertion: .opacity.combined(with: .offset(x: -8)),
                            removal: .opacity
                        )
                    )

                if tx.id != filteredTransactions.last?.id {
                    Rectangle()
                        .fill(Color.borderColor)
                        .frame(height: 0.75)
                        .padding(.leading, 74)
                }
            }
        }
        .background(Color.surfacePrimary)
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .shadow(color: Color.accentPrimary.opacity(0.06), radius: 12, x: 0, y: 4)
        .animation(.easeInOut(duration: 0.28), value: filteredTransactions.map(\.id))
    }

    var shimmerList: some View {
        VStack(spacing: 0) {
            ForEach(0..<5, id: \.self) { i in
                HStack(spacing: 14) {
                    ShimmerView(cornerRadius: 12)
                        .frame(width: 44, height: 44)

                    VStack(alignment: .leading, spacing: 6) {
                        ShimmerView(cornerRadius: 4)
                            .frame(width: CGFloat.random(in: 110...160), height: 13)
                        ShimmerView(cornerRadius: 4)
                            .frame(width: 80, height: 10)
                    }

                    Spacer()

                    ShimmerView(cornerRadius: 4)
                        .frame(width: 55, height: 13)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)

                if i < 4 {
                    Rectangle()
                        .fill(Color.borderColor)
                        .frame(height: 0.75)
                        .padding(.leading, 74)
                }
            }
        }
        .background(Color.surfacePrimary)
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .shadow(color: Color.accentPrimary.opacity(0.06), radius: 12, x: 0, y: 4)
    }
    
    var emptyState: some View {
        VStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(Color.bgPrimary)
                    .frame(width: 72, height: 72)
                Image(systemName: iconForEmpty)
                    .font(.system(size: 30, weight: .medium))
                    .foregroundColor(Color.textMuted.opacity(0.6))
            }

            VStack(spacing: 6) {
                Text(emptyTitle)
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundColor(Color.textPrimary)

                Text(emptyMessage)
                    .font(.system(size: 13))
                    .foregroundColor(Color.textMuted)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 44)
        .background(Color.surfacePrimary)
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .shadow(color: Color.accentPrimary.opacity(0.06), radius: 12, x: 0, y: 4)
    }

    var iconForEmpty: String {
        switch selectedFilter {
        case .all: return "tray"
        case .topup: return "arrow.down.circle"
        case .payment: return "cart"
        case .refund: return "arrow.uturn.left.circle"
        case .reward: return "star"
        }
    }

    var emptyTitle: String {
        selectedFilter == .all ? "No transactions yet" : "No \(selectedFilter.rawValue) history"
    }

    var emptyMessage: String {
        switch selectedFilter {
        case .all: return "Top up your wallet to start brewing"
        case .topup: return "Add funds and your top-up history shows here"
        case .payment: return "Place an order and it'll appear here"
        case .refund: return "Cancelled orders will show up here"
        case .reward: return "Earn rewards by completing milestones"
        }
    }
}

struct TransactionFilterChip: View {
    let filter: FilteredTransactionView.TransactionFilter
    let isSelected: Bool
    let count: Int
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 5) {
                Image(systemName: filter.icon)
                    .font(.system(size: 11, weight: .semibold))

                Text(filter.rawValue)
                    .font(.system(size: 13, weight: isSelected ? .bold : .medium))

                if count > 0 {
                    Text("\(count)")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(isSelected ? Color.textSecondary : Color.textMuted)
                        .padding(.horizontal, 5)
                        .padding(.vertical, 1)
                        .background(
                            Capsule()
                                .fill(isSelected ? Color.surfacePrimary.opacity(0.3) : Color.surfaceSub)
                        )
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(
                isSelected
                    ? LinearGradient(
                        colors: [Color.accentPrimary, Color.accentPrimary],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    : LinearGradient(
                        colors: [Color.surfacePrimary, Color.surfacePrimary],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
            )
            .foregroundColor(isSelected ? .white : Color.textSecondary)
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .strokeBorder(
                        isSelected ? Color.clear : Color.borderColor,
                        lineWidth: 1
                    )
            )
            .shadow(
                color: isSelected ? Color.accentPrimary.opacity(0.25) : Color.clear,
                radius: 6, x: 0, y: 3
            )
        }
        .buttonStyle(.plain)
        .scaleEffect(isSelected ? 1.02 : 1.0)
        .animation(.spring(response: 0.25, dampingFraction: 0.7), value: isSelected)
    }
}
