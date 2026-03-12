//
//  OrderQueueCard.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 13/03/2026.
//

import SwiftUI

// MARK: - Order Queue Card

/// A card shown in the live order queue.
/// Displays elapsed wait time, items preview, and a one-tap advance button.
struct OrderQueueCard: View {

    let item: OrderQueueItem
    let now: Date
    let isUpdating: Bool
    let onAdvance: () async -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {

            // Top row: customer + wait badge
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(item.customerName)
                        .font(.subheadline.weight(.semibold))
                        .lineLimit(1)
                    Text(item.itemsSubtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }

                Spacer()

                WaitTimeBadge(minutes: item.waitMinutes(relativeTo: now))
            }

            // Divider
            Divider()

            // Bottom row: price + status + advance button
            HStack {
                // Order ID + price
                VStack(alignment: .leading, spacing: 2) {
                    Text("#\(item.id.prefix(8).uppercased())")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                        .monospaced()
                    Text(item.totalFormatted)
                        .font(.subheadline.weight(.semibold))
                }

                Spacer()

                // Status badge
                StatusBadge1(status: item.status.rawValue)

                // Advance button — only shown when a next status exists
                if let next = item.nextStatus {
                    Button {
                        Task { await onAdvance() }
                    } label: {
                        if isUpdating {
                            ProgressView()
                                .scaleEffect(0.7)
                                .frame(width: 28, height: 28)
                        } else {
                            Image(systemName: next == .preparing ? "flame.fill" : "checkmark.circle.fill")
                                .font(.title3)
                                .foregroundStyle(.white)
                                .frame(width: 36, height: 36)
                                .background(item.status.color, in: Circle())
                        }
                    }
                    .buttonStyle(.plain)
                    .disabled(isUpdating)
                    .padding(.leading, 6)
                    .accessibilityLabel(item.status.advanceButtonLabel)
                }
            }
        }
        .padding(14)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(item.status.color.opacity(0.3), lineWidth: 1.5)
        )
    }
}

// MARK: - Wait Time Badge

/// Shows elapsed wait time. Turns red when waiting > 15 minutes.
private struct WaitTimeBadge: View {
    let minutes: Int

    private var isUrgent: Bool { minutes >= 15 }

    var body: some View {
        HStack(spacing: 3) {
            Image(systemName: "clock")
                .font(.system(size: 10))
            Text(label)
                .font(.system(size: 11, weight: .semibold))
                .monospacedDigit()
        }
        .foregroundStyle(isUrgent ? .white : .primary)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(isUrgent ? Color.red : Color.secondary.opacity(0.12),
                    in: Capsule())
        .animation(.easeInOut(duration: 0.3), value: isUrgent)
    }

    private var label: String {
        if minutes < 1  { return "Just now" }
        if minutes < 60 { return "\(minutes)m" }
        return "\(minutes / 60)h \(minutes % 60)m"
    }
}

// MARK: - History Order Row

/// Compact row used in the paginated history table.
struct HistoryOrderRow: View {
    let item: OrderQueueItem
    let now: Date

    var body: some View {
        HStack(spacing: 12) {
            // Status dot
            Circle()
                .fill(item.status.color)
                .frame(width: 9, height: 9)

            VStack(alignment: .leading, spacing: 3) {
                Text(item.customerName)
                    .font(.subheadline.weight(.medium))
                    .lineLimit(1)
                Text(item.itemsSubtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text(item.totalFormatted)
                    .font(.subheadline.weight(.semibold))
                Text(item.timestamp.timeAgo(relativeTo: now))
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(.vertical, 8)
    }
}

// MARK: - Date Extension (reused from DashboardSummary pattern)

private extension Date {
    func timeAgo(relativeTo now: Date) -> String {
        let diff = now.timeIntervalSince(self)
        if diff < 60 { return "Just now" }
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        formatter.dateTimeStyle = .named
        return formatter.localizedString(for: self, relativeTo: now)
    }
}
