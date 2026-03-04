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

            //icon badge
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(transaction.type.color.opacity(0.12))
                    .frame(width: 44, height: 44)

                Image(systemName: transaction.type.icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(transaction.type.color)
            }

            // label + date
            VStack(alignment: .leading, spacing: 3) {
                Text(transaction.description)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color.textPrimary)
                    .lineLimit(1)

                Text(transaction.formattedDate)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(Color.textMuted)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 3) {
                Text(transaction.formattedAmount)
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(transaction.isCredit ? Color.semanticSuccess : Color.semanticError)

                // Type
                Text(transaction.type.rawValue.capitalized)
                    .font(.system(size: 9, weight: .semibold))
                    .tracking(0.5)
                    .foregroundStyle(transaction.type.color.opacity(0.8))
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(transaction.type.color.opacity(0.1))
                    .clipShape(Capsule())
            }
        }
        .padding(.vertical, 10)
        .contentShape(Rectangle())
    }
}
