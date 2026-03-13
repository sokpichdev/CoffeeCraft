//
//  OrderQueueCard.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 13/03/2026.
//

import SwiftUI

// MARK: - Order Queue Card

struct OrderQueueCard: View {

    let item: OrderQueueItem
    let now: Date
    let isUpdating: Bool
    let onAdvance: () async -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {

            // Top: customer name + wait badge
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 3) {
                    Text(item.customerName)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color.textPrimary)
                        .lineLimit(1)
                    Text(item.itemsSubtitle)
                        .font(.caption)
                        .foregroundStyle(Color.textMuted)
                        .lineLimit(1)
                }
                Spacer()
                WaitTimeBadge(minutes: item.waitMinutes(relativeTo: now))
            }

            Divider().background(Color.borderColor)

            // Bottom: order ID + price + status + advance
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("#\(item.id.prefix(8).uppercased())")
                        .font(.system(size: 10, weight: .medium, design: .monospaced))
                        .foregroundStyle(Color.textMuted)
                    Text(item.totalFormatted)
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(Color.textPrimary)
                }

                Spacer()

                StatusBadge1(status: item.status.rawValue)

                if let next = item.nextStatus {
                    Button {
                        Task { await onAdvance() }
                    } label: {
                        if isUpdating {
                            ProgressView()
                                .scaleEffect(0.75)
                                .frame(width: 36, height: 36)
                        } else {
                            Image(systemName: next == .preparing ? "flame.fill" : "checkmark.circle.fill")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundStyle(.white)
                                .frame(width: 36, height: 36)
                                .background(item.status.color, in: Circle())
                                .shadow(color: item.status.color.opacity(0.3), radius: 4, x: 0, y: 2)
                        }
                    }
                    .buttonStyle(.plain)
                    .disabled(isUpdating)
                    .accessibilityLabel(item.status.advanceButtonLabel)
                }
            }
        }
        .padding(16)
        .background(Color.surfacePrimary)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        // Status-coloured left border stripe
        .overlay(alignment: .leading) {
            RoundedRectangle(cornerRadius: 3)
                .fill(item.status.color)
                .frame(width: 4)
                .padding(.vertical, 12)
        }
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(item.status.color.opacity(0.22), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 3)
    }
}

// MARK: - Wait Time Badge

private struct WaitTimeBadge: View {
    let minutes: Int

    private var isUrgent: Bool { minutes >= 15 }

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "clock")
                .font(.system(size: 10, weight: .medium))
            Text(label)
                .font(.system(size: 11, weight: .semibold))
                .monospacedDigit()
        }
        .foregroundStyle(isUrgent ? .white : Color.textSecondary)
        .padding(.horizontal, 9)
        .padding(.vertical, 5)
        .background(isUrgent ? Color.red : Color.surfaceSub, in: Capsule())
        .overlay(Capsule().stroke(isUrgent ? Color.red.opacity(0.4) : Color.borderColor, lineWidth: 1))
        .animation(.easeInOut(duration: 0.3), value: isUrgent)
    }

    private var label: String {
        if minutes < 1 { return "Just now" }
        if minutes < 60 { return "\(minutes)m" }
        return "\(minutes / 60)h \(minutes % 60)m"
    }
}

// MARK: - History Order Row

struct HistoryOrderRow: View {
    let item: OrderQueueItem
    let now: Date

    var body: some View {
        HStack(spacing: 12) {
            // Status indicator dot
            Circle()
                .fill(item.status.color)
                .frame(width: 9, height: 9)

            VStack(alignment: .leading, spacing: 3) {
                Text(item.customerName)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(Color.textPrimary)
                    .lineLimit(1)
                Text(item.itemsSubtitle)
                    .font(.caption)
                    .foregroundStyle(Color.textMuted)
                    .lineLimit(1)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text(item.totalFormatted)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.textPrimary)
                Text(item.timestamp.timeAgo(relativeTo: now))
                    .font(.caption2)
                    .foregroundStyle(Color.textMuted)
            }
        }
        .padding(.vertical, 9)
    }
}

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
