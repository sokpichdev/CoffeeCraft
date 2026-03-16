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

    private var status: OrderStatus { OrderStatus.from(item.status) }

    var body: some View {
        HStack(spacing: 14) {

            // Avatar with status ring
            ZStack {
                Circle()
                    .fill(status.color.opacity(0.10))
                    .frame(width: 42, height: 42)
                Image(systemName: status.icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(status.color)
            }
            .overlay(
                Circle().stroke(status.color.opacity(0.30), lineWidth: 1.5)
            )

            // Order info
            VStack(alignment: .leading, spacing: 3) {
                Text(item.customerName)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.textPrimary)
                    .lineLimit(1)

                HStack(spacing: 4) {
                    Text("\(item.itemCount) item\(item.itemCount > 1 ? "s" : "")")
                        .font(.caption).foregroundStyle(Color.textMuted)
                    Text("·")
                        .font(.caption).foregroundStyle(Color.textMuted)
                    Text(item.timeAgo(relativeTo: now))
                        .font(.caption).foregroundStyle(Color.textMuted)
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
}

// MARK: - Status Badge (compact, used in dashboard rows)

struct StatusBadge1: View {
    let status: String

    private var orderStatus: OrderStatus { OrderStatus.from(status) }

    var body: some View {
        Text(orderStatus.displayLabel)
            .font(.system(size: 10, weight: .bold))
            .foregroundStyle(orderStatus.color)
            .tracking(0.2)
            .padding(.horizontal, 9)
            .padding(.vertical, 4)
            .background(orderStatus.color.opacity(0.12), in: Capsule())
            .overlay(Capsule().stroke(orderStatus.color.opacity(0.22), lineWidth: 1))
    }
}
