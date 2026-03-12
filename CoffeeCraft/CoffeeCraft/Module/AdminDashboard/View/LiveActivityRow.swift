//
//  LiveActivityRow.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 3/12/26.
//

import SwiftUI

// MARK: - Live Activity Row

struct LiveActivityRow: View {

    let item: LiveOrderItem

    var body: some View {
        HStack(spacing: 12) {

            // Status dot
            Circle()
                .fill(statusColor)
                .frame(width: 10, height: 10)
                .padding(.top, 2)

            // Order info
            VStack(alignment: .leading, spacing: 3) {
                Text(item.customerName)
                    .font(.subheadline.weight(.medium))
                    .lineLimit(1)
                Text("\(item.itemCount) item\(item.itemCount > 1 ? "s" : "") · \(item.timeAgo)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            // Right side: amount + status badge
            VStack(alignment: .trailing, spacing: 4) {
                Text(item.totalFormatted)
                    .font(.subheadline.weight(.semibold))
                StatusBadge1(status: item.status)
            }
        }
        .padding(.vertical, 6)
    }

    // MARK: - Private

    private var statusColor: Color {
        switch item.status {
        case "Pending":    return .orange
        case "Preparing":  return .blue
        case "Ready":      return .green
        case "Completed":  return .gray
        case "Cancelled":  return .red
        default:           return .gray
        }
    }
}

// MARK: - Status Badge

struct StatusBadge1: View {
    let status: String

    var body: some View {
        Text(status)
            .font(.system(size: 10, weight: .semibold))
            .foregroundStyle(color)
            .padding(.horizontal, 7)
            .padding(.vertical, 3)
            .background(color.opacity(0.12), in: Capsule())
    }

    private var color: Color {
        switch status {
        case "Pending":    return .orange
        case "Preparing":  return .blue
        case "Ready":      return .green
        case "Completed":  return .gray
        case "Cancelled":  return .red
        default:           return .secondary
        }
    }
}
