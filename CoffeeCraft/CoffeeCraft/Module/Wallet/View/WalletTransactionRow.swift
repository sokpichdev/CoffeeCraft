//
//  WalletTransactionRow.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 03/03/2026.
//

import SwiftUI

// MARK: - WalletTransactionRow
// Single row in the transaction history list.
// Shows icon, label, date, and signed amount — colour-coded green/red.

struct WalletTransactionRow: View {

    let transaction: WalletTransaction

    var body: some View {
        HStack(spacing: 14) {

            // Icon
            ZStack {
                Circle()
                    .fill(transaction.type.color.opacity(0.15))
                    .frame(width: 40, height: 40)
                Image(systemName: transaction.type.icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(transaction.type.color)
            }

            // Label + date
            VStack(alignment: .leading, spacing: 3) {
                Text(transaction.description)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(.primary)
                    .lineLimit(1)

                Text(transaction.formattedDate)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            // Amount
            Text(transaction.formattedAmount)
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundStyle(transaction.isCredit ? Color.leafGreen : Color.errorRed)
        }
        .padding(.vertical, 6)
    }
}
