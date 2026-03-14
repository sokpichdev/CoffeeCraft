//
//  LiveActivityRow.swift
//  CoffeeCraft
//

import SwiftUI

// MARK: - Live Activity Row

struct LiveActivityRow: View {

    let item: LiveOrderItem
    /// Passed from parent's 30-second timer so all rows refresh simultaneously.
    let now: Date

    var body: some View {
        HStack(spacing: 14) {

            // Avatar with status ring
            ZStack {
                Circle()
                    .fill(statusColor.opacity(0.10))
                    .frame(width: 42, height: 42)
                Image(systemName: statusIcon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(statusColor)
            }
            .overlay(
                Circle()
                    .stroke(statusColor.opacity(0.30), lineWidth: 1.5)
            )

            // Order info
            VStack(alignment: .leading, spacing: 3) {
                Text(item.customerName)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.textPrimary)
                    .lineLimit(1)

                HStack(spacing: 4) {
                    Text("\(item.itemCount) item\(item.itemCount > 1 ? "s" : "")")
                        .font(.caption)
                        .foregroundStyle(Color.textMuted)
                    Text("·")
                        .font(.caption)
                        .foregroundStyle(Color.textMuted)
                    Text(item.timeAgo(relativeTo: now))
                        .font(.caption)
                        .foregroundStyle(Color.textMuted)
                }
            }

            Spacer()

            // Amount + status badge
            VStack(alignment: .trailing, spacing: 5) {
                Text(item.totalFormatted)
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(Color.textPrimary)
                StatusBadge1(status: item.status)
            }
        }
        .padding(.vertical, 11)
        .padding(.horizontal, 2)
        .contentShape(Rectangle())
    }

    // MARK: - Helpers

    private var statusColor: Color {
        switch item.status {
        case "Pending": return .orange
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
            .padding(.horizontal, 9)
            .padding(.vertical, 4)
            .background(color.opacity(0.12), in: Capsule())
            .overlay(Capsule().stroke(color.opacity(0.22), lineWidth: 1))
    }

    private var color: Color {
        switch status {
        case "Pending": return .orange
        case "Preparing": return Color.accentPrimary
        case "Ready": return Color.semanticSuccess
        case "Completed": return Color.textMuted
        case "Cancelled": return Color.semanticError
        default: return Color.textSecondary
        }
    }
}
