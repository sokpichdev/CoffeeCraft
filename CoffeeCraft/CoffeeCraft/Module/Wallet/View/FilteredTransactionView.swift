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
    
    // MARK: - Filter State
    
    @State private var selectedFilter: TransactionFilter = .all
    
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
    }
    
    // MARK: - Filtered Data
    
    var filteredTransactions: [WalletTransaction] {
        guard let type = selectedFilter.transactionType else {
            return transactions
        }
        return transactions.filter { $0.type == type }
    }
    
    // MARK: - Stats
    
    var totalCredits: Double {
        filteredTransactions.filter { $0.isCredit }.reduce(0) { $0 + $1.amount }
    }
    
    var totalDebits: Double {
        filteredTransactions.filter { !$0.isCredit }.reduce(0) { $0 + abs($1.amount) }
    }
    
    // MARK: - Body
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            
            // Header with count
            headerSection
            
            // Filter Picker
            filterPicker
            
            // Stats Summary (only show when not loading and has data)
            if !isLoading && !filteredTransactions.isEmpty {
                statsSection
            }
            
            // Content
            contentSection
            
            Spacer().frame(height: 20)
        }
    }
    
    // MARK: - Header
    
    private var headerSection: some View {
        HStack {
            Label("Transaction History", systemImage: "list.bullet.rectangle")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(.primary)
            
            Spacer()
            
            if !isLoading {
                Text("\(filteredTransactions.count) of \(transactions.count)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .contentTransition(.numericText())
                    .animation(.easeInOut(duration: 0.2), value: filteredTransactions.count)
            }
        }
        .padding(.horizontal, 4)
    }
    
    // MARK: - Filter Picker
    
    private var filterPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(TransactionFilter.allCases, id: \.self) { filter in
                    FilterChip(
                        title: filter.rawValue,
                        isSelected: selectedFilter == filter,
                        count: countForFilter(filter)
                    ) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selectedFilter = filter
                        }
                    }
                }
            }
            .padding(.horizontal, 4)
        }
    }
    
    private func countForFilter(_ filter: TransactionFilter) -> Int {
        guard let type = filter.transactionType else { return transactions.count }
        return transactions.filter { $0.type == type }.count
    }
    
    // MARK: - Stats Section
    
    private var statsSection: some View {
        HStack(spacing: 12) {
            StatCard(
                title: "In",
                amount: totalCredits,
                color: Color("leafGreen"),
                icon: "arrow.down"
            )
            
            StatCard(
                title: "Out",
                amount: totalDebits,
                color: Color("errorRed"),
                icon: "arrow.up"
            )
        }
        .padding(.horizontal, 4)
    }
    
    // MARK: - Content
    
    @ViewBuilder
    private var contentSection: some View {
        if isLoading && transactions.isEmpty {
            shimmerRows
        } else if filteredTransactions.isEmpty {
            emptyState
        } else {
            transactionList
        }
    }
    
    private var transactionList: some View {
        VStack(spacing: 0) {
            ForEach(filteredTransactions) { tx in
                WalletTransactionRow(transaction: tx)
                    .padding(.horizontal, 16)
                    .transition(.opacity.combined(with: .move(edge: .trailing)))
                
                if tx.id != filteredTransactions.last?.id {
                    Divider()
                        .padding(.leading, 70)
                }
            }
        }
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .animation(.easeInOut(duration: 0.25), value: filteredTransactions.map(\.id))
    }
    
    // MARK: - Shimmer
    
    private var shimmerRows: some View {
        VStack(spacing: 0) {
            ForEach(0..<4, id: \.self) { _ in
                HStack(spacing: 14) {
                    ShimmerView(cornerRadius: 20)
                        .frame(width: 40, height: 40)
                    VStack(alignment: .leading, spacing: 6) {
                        ShimmerView(cornerRadius: 4)
                            .frame(width: 140, height: 14)
                        ShimmerView(cornerRadius: 4)
                            .frame(width: 90, height: 11)
                    }
                    Spacer()
                    ShimmerView(cornerRadius: 4)
                        .frame(width: 60, height: 14)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                Divider().padding(.leading, 70)
            }
        }
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    // MARK: - Empty State
    
    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: iconForEmptyState)
                .font(.system(size: 44))
                .foregroundStyle(Color.coffeeBrown.opacity(0.3))
                .symbolRenderingMode(.hierarchical)
            
            Text(emptyStateTitle)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundStyle(.primary)
            
            Text(emptyStateMessage)
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 50)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    private var iconForEmptyState: String {
        switch selectedFilter {
        case .all: return "tray"
        case .topup: return "arrow.down.circle"
        case .payment: return "cart"
        case .refund: return "arrow.uturn.left.circle"
        case .reward: return "star"
        }
    }
    
    private var emptyStateTitle: String {
        if selectedFilter == .all {
            return "No transactions yet"
        }
        return "No \(selectedFilter.rawValue) transactions"
    }
    
    private var emptyStateMessage: String {
        switch selectedFilter {
        case .all:
            return "Top up your wallet to get started"
        case .topup:
            return "Add funds to see your top-up history"
        case .payment:
            return "Make a purchase to see payment history"
        case .refund:
            return "Cancelled orders will appear here"
        case .reward:
            return "Complete milestones to earn rewards"
        }
    }
}

// MARK: - Filter Chip

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let count: Int
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(isSelected ? .semibold : .medium)
                
                if count > 0 {
                    Text("\(count)")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundStyle(isSelected ? .white : .secondary)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(
                            Capsule()
                                .fill(isSelected ? Color.white.opacity(0.25) : Color(.tertiarySystemFill))
                        )
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(isSelected ? Color.coffeeBrown : Color(.secondarySystemGroupedBackground))
            )
            .foregroundStyle(isSelected ? .white : .primary)
            .overlay(
                Capsule()
                    .strokeBorder(isSelected ? Color.clear : Color(.separator), lineWidth: 0.5)
            )
        }
        .buttonStyle(.plain)
        .scaleEffect(isSelected ? 1.02 : 1.0)
        .animation(.spring(response: 0.2), value: isSelected)
    }
}

// MARK: - Stat Card

struct StatCard: View {
    let title: String
    let amount: Double
    let color: Color
    let icon: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.caption)
                    .foregroundStyle(color)
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Text(amount.currencyFormatted)
                .font(.system(.subheadline, design: .rounded))
                .fontWeight(.semibold)
                .foregroundStyle(color)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(color.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(color.opacity(0.15), lineWidth: 1)
        )
    }
}

// MARK: - Preview

#Preview {
    VStack {
        FilteredTransactionView(
            transactions: [
                WalletTransaction(
                    id: "1",
                    userId: "user1",
                    type: .topup,
                    amount: 50.0,
                    balanceBefore: 0,
                    balanceAfter: 50,
                    description: "Top-up via Card",
                    referenceId: nil,
                    timestamp: Date()
                ),
                WalletTransaction(
                    id: "2",
                    userId: "user1",
                    type: .payment,
                    amount: -12.5,
                    balanceBefore: 50,
                    balanceAfter: 37.5,
                    description: "Order #ABC123",
                    referenceId: "ABC123",
                    timestamp: Date().addingTimeInterval(-3600)
                ),
                WalletTransaction(
                    id: "3",
                    userId: "user1",
                    type: .reward,
                    amount: 5.0,
                    balanceBefore: 37.5,
                    balanceAfter: 42.5,
                    description: "Loyalty Bonus",
                    referenceId: nil,
                    timestamp: Date().addingTimeInterval(-7200)
                )
            ],
            isLoading: false
        )
    }
    .padding()
    .background(Color(.systemGroupedBackground))
}
