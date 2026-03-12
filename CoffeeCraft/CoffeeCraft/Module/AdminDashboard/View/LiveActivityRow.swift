//
//  LiveActivityRow.swift
//  CoffeeCraft
//

import SwiftUI

// MARK: - Live Activity Row

struct LiveActivityRow: View {

    let item: LiveOrderItem
    /// Passed from the parent's 30-second timer so all rows refresh together.
    let now: Date

    var body: some View {
        HStack(spacing: 14) {

            // Avatar / status circle
            ZStack {
                Circle()
                    .fill(statusColor.opacity(0.12))
                    .frame(width: 40, height: 40)
                Image(systemName: statusIcon)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(statusColor)
            }

            // Order info
            VStack(alignment: .leading, spacing: 3) {
                Text(item.customerName)
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.textPrimary)
                    .lineLimit(1)

                HStack(spacing: 4) {
                    Text("\(item.itemCount) item\(item.itemCount > 1 ? "s" : "")")
                        .font(.caption)
                        .foregroundColor(.textMuted)
                    Text("·")
                        .font(.caption)
                        .foregroundColor(.textMuted)
                    Text(item.timeAgo(relativeTo: now))
                        .font(.caption)
                        .foregroundColor(.textMuted)
                }
            }

            Spacer()

            // Amount + badge
            VStack(alignment: .trailing, spacing: 5) {
                Text(item.totalFormatted)
                    .font(.subheadline.weight(.bold))
                    .foregroundColor(.textPrimary)
                StatusBadge1(status: item.status)
            }
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 2)
        .contentShape(Rectangle())
    }

    // MARK: - Helpers

    private var statusColor: Color {
        switch item.status {
        case "Pending": return Color.orange
        case "Preparing": return Color.accentPrimary
        case "Ready": return Color.semanticSuccess
        case "Completed": return Color.textMuted
        case "Cancelled": return Color.semanticError
        default: return Color.textMuted
        }
    }

    private var statusIcon: String {
        switch item.status {
        case "Pending": return "clock"
        case "Preparing": return "cup.and.saucer.fill"
        case "Ready": return "checkmark.circle.fill"
        case "Completed": return "bag.fill"
        case "Cancelled": return "xmark.circle.fill"
        default: return "circle"
        }
    }
}

// MARK: - Status Badge

struct StatusBadge1: View {
    let status: String

    var body: some View {
        Text(status)
            .font(.system(size: 10, weight: .bold))
            .foregroundStyle(color)
            .tracking(0.2)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(color.opacity(0.12), in: Capsule())
    }

    private var color: Color {
        switch status {
        case "Pending": return Color.orange
        case "Preparing": return Color.accentPrimary
        case "Ready": return Color.semanticSuccess
        case "Completed": return Color.textMuted
        case "Cancelled": return Color.semanticError
        default: return Color.textSecondary
        }
    }
}
