//
//  PointsTransactionRow.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 3/30/26.
//

import SwiftUI

struct PointsTransactionRow: View {
    let transaction: PointsTransaction

    var body: some View {
        HStack(spacing: 12) {
            // Icon
            Image(systemName: "star.fill")
                .foregroundColor(.accentGold)
                .font(.system(size: 18))
                .frame(width: 36, height: 36)
                .background(Color.accentGold.opacity(0.12))
                .clipShape(Circle())

            // Description + date
            VStack(alignment: .leading, spacing: 2) {
                Text(transaction.description)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.textPrimary)

                Text(transaction.timestamp.relativeFormatted)
                    .font(.caption)
                    .foregroundColor(.textSecondary)
            }

            Spacer()

            // Points badge
            Text("+\(transaction.points.pointsFormatted) pts")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.accentPrimary)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(Color.accentPrimary.opacity(0.1))
                .clipShape(Capsule())
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Helpers

private extension Double {
    /// Formats a raw Double points value cleanly: "1.5", "2", "0.5"
    var pointsFormatted: String {
        truncatingRemainder(dividingBy: 1) == 0
            ? String(Int(self))
            : String(format: "%.1f", self)
    }
}
