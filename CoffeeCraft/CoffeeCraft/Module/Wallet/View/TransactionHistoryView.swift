//
//  TransactionHistoryView.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 03/03/2026.
//

import SwiftUI

// MARK: - TransactionHistoryView
// Shows the full list of wallet transactions with shimmer loading
// and a clean empty state when the user has no history yet.

struct TransactionHistoryView: View {
    let transactions: [WalletTransaction]
    let isLoading: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Label("Transaction History", systemImage: "list.bullet.rectangle")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)
                Spacer()
                if !transactions.isEmpty {
                    Text("\(transactions.count) records")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal, 4)

            // Content
            if isLoading && transactions.isEmpty {
                shimmerRows
            } else if transactions.isEmpty {
                emptyState
            } else {
                transactionList
            }
        }
    }

    // MARK: - List

    private var transactionList: some View {
        VStack(spacing: 0) {
            ForEach(transactions) { tx in
                WalletTransactionRow(transaction: tx)
                    .padding(.horizontal, 16)

                if tx.id != transactions.last?.id {
                    Divider()
                        .padding(.leading, 70)
                }
            }
        }
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
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
            Image(systemName: "tray")
                .font(.system(size: 40))
                .foregroundStyle(Color.coffeeBrown.opacity(0.4))
            Text("No transactions yet")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundStyle(.primary)
            Text("Top up your wallet to get started")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}
