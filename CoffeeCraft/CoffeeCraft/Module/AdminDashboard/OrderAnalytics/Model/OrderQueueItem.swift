//
//  OrderQueueItem.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 13/03/2026.
//

import Foundation
import SwiftUI

// MARK: - Order Queue Item

/// Full order data used by the real-time queue and history table.
/// Richer than `LiveOrderItem` — includes userId, branchId, and completedAt
/// for funnel time calculation.
struct OrderQueueItem: Identifiable {
    let id: String
    let customerName: String
    let userId: String
    let totalPrice: Double
    let status: OrderStatus
    let timestamp: Date
    let completedAt: Date? // nil until order reaches Completed
    let itemCount: Int
    let itemNames: [String] // first 2 item names for the subtitle
    let branchId: String

    var totalFormatted: String { totalPrice.asCurrency }

    /// Minutes elapsed since the order was placed.
    func waitMinutes(relativeTo now: Date = Date()) -> Int {
        Int(now.timeIntervalSince(timestamp) / 60)
    }

    /// Fulfillment duration in minutes. Nil if `completedAt` is missing.
    var fulfillmentMinutes: Int? {
        guard let completedAt else { return nil }
        return Int(completedAt.timeIntervalSince(timestamp) / 60)
    }

    /// Human-readable subtitle from item names.
    var itemsSubtitle: String {
        let preview = itemNames.prefix(2).joined(separator: ", ")
        let extra = itemCount > 2 ? " +\(itemCount - 2) more" : ""
        return preview + extra
    }

    /// The next logical status a manager can advance to.
    /// Returns nil when no forward transition is available (Ready / Completed / Cancelled).
    var nextStatus: OrderStatus? {
        switch status {
        case .pending:   return .preparing
        case .preparing: return .ready
        default:         return nil
        }
    }
}

// MARK: - Order Status

enum OrderStatus: String, CaseIterable, Identifiable {
    case pending = "Pending"
    case preparing = "Preparing"
    case ready = "Ready"
    case completed = "Completed"
    case cancelled = "Cancelled"

    var id: String { rawValue }

    var color: Color {
        switch self {
        case .pending: return .orange
        case .preparing: return .blue
        case .ready: return .green
        case .completed: return .gray
        case .cancelled: return .red
        }
    }

    var icon: String {
        switch self {
        case .pending: return "clock"
        case .preparing: return "flame.fill"
        case .ready: return "checkmark.circle.fill"
        case .completed: return "archivebox.fill"
        case .cancelled: return "xmark.circle.fill"
        }
    }

    /// Label for the one-tap advance button shown on queue cards.
    var advanceButtonLabel: String {
        switch self {
        case .pending: return "Start Preparing"
        case .preparing: return "Mark Ready"
        default: return ""
        }
    }
}

// MARK: - History Filter State

struct OrderHistoryFilter {
    var status: OrderStatus? // nil = all statuses
    var searchText: String = ""
    var sortOrder: HistorySortOrder = .newest

    var isEmpty: Bool {
        status == nil && searchText.isEmpty
    }
}

enum HistorySortOrder: String, CaseIterable {
    case newest = "Newest"
    case oldest = "Oldest"
    case highest = "Highest Amount"
    case lowest = "Lowest Amount"
}

// MARK: - Order Funnel Data

struct OrderFunnelData {
    let totalOrders: Int
    let completedCount: Int
    let cancelledCount: Int
    let activeCount: Int            // Pending + Preparing + Ready
    let avgFulfillmentMinutes: Double?   // nil when no completedAt data exists yet

    var completionRate: Double {
        guard totalOrders > 0 else { return 0 }
        return (Double(completedCount) / Double(totalOrders)) * 100
    }

    var cancellationRate: Double {
        guard totalOrders > 0 else { return 0 }
        return (Double(cancelledCount) / Double(totalOrders)) * 100
    }

    var completionRateFormatted: String {
        String(format: "%.1f%%", completionRate)
    }

    var cancellationRateFormatted: String {
        String(format: "%.1f%%", cancellationRate)
    }

    var avgFulfillmentFormatted: String {
        guard let mins = avgFulfillmentMinutes else { return "N/A" }
        if mins < 60 { return "\(Int(mins)) min" }
        return String(format: "%.1f hr", mins / 60)
    }

    static var empty: OrderFunnelData {
        OrderFunnelData(totalOrders: 0, completedCount: 0, cancelledCount: 0,
                        activeCount: 0, avgFulfillmentMinutes: nil)
    }
}
