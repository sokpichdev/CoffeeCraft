//
//  OrderStatus.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 3/16/26.
//
//  Single source of truth for every order status in the app.
//
//  Flow:
//    Pickup:   Pending → InProgress → Ready → Completed
//    Delivery: Pending → InProgress → Ready → OnDelivery → Completed
//    Either:   Pending → Cancelled
//
//  Usage:
//    • Compare:   order.orderStatus == .ready
//    • Firestore: .whereField("status", isEqualTo: OrderStatus.completed.rawValue)
//    • Display:   Text(status.displayLabel)
//    • Color:     status.color
//    • Icon:      status.icon
//

import SwiftUI

enum OrderStatus: String, CaseIterable, Codable, Identifiable {

    case pending    = "Pending"
    case inProgress = "InProgress"
    case ready      = "Ready"
    case onDelivery = "OnDelivery"
    case completed  = "Completed"
    case cancelled  = "Cancelled"

    var id: String { rawValue }

    // MARK: - Display

    /// Human-readable label shown in badges, filters, and list headers.
    var displayLabel: String {
        switch self {
        case .pending:    return "Pending"
        case .inProgress: return "In Progress"
        case .ready:      return "Ready"
        case .onDelivery: return "On Delivery"
        case .completed:  return "Completed"
        case .cancelled:  return "Cancelled"
        }
    }

    // MARK: - Appearance

    /// Consistent color used across badges, timelines, and card headers.
    var color: Color {
        switch self {
        case .pending:    return .orange
        case .inProgress: return .accentPrimary
        case .ready:      return .semanticSuccess
        case .onDelivery: return .blue
        case .completed:  return .textMuted
        case .cancelled:  return .semanticError
        }
    }

    /// SF Symbol name used in timelines, notification rows, and queue cards.
    var icon: String {
        switch self {
        case .pending:    return "clock"
        case .inProgress: return "flame.fill"
        case .ready:      return "checkmark.circle.fill"
        case .onDelivery: return "bicycle"
        case .completed:  return "bag.fill"
        case .cancelled:  return "xmark.circle.fill"
        }
    }

    // MARK: - Transition Logic

    /// The next status a manager can advance a pickup order to.
    /// Returns nil when no forward transition exists.
    var nextPickupStatus: OrderStatus? {
        switch self {
        case .pending:    return .inProgress
        case .inProgress: return .ready
        case .ready:      return .completed
        default:          return nil
        }
    }

    /// The next status a manager can advance a delivery order to.
    /// Returns nil when no forward transition exists.
    var nextDeliveryStatus: OrderStatus? {
        switch self {
        case .pending:    return .inProgress
        case .inProgress: return .ready
        case .ready:      return .onDelivery
        case .onDelivery: return .completed
        default:          return nil
        }
    }

    /// Convenience: resolves next status based on order type.
    func nextStatus(isDelivery: Bool) -> OrderStatus? {
        isDelivery ? nextDeliveryStatus : nextPickupStatus
    }

    // MARK: - State Checks

    /// True for terminal states — no further transitions possible.
    var isTerminal: Bool {
        self == .completed || self == .cancelled
    }

    /// True while the order is actively being worked on.
    /// Used to filter "active orders" in the admin queue.
    var isActive: Bool {
        switch self {
        case .pending, .inProgress, .ready, .onDelivery: return true
        case .completed, .cancelled:                     return false
        }
    }

    // MARK: - Manager Button Labels

    /// One-tap advance button label shown on queue cards (pickup).
    var advanceButtonLabelPickup: String {
        switch self {
        case .pending:    return "Start Preparing"
        case .inProgress: return "Mark Ready"
        case .ready:      return "Complete Order"
        case .onDelivery: return "Mark Delivered"
        default:          return ""
        }
    }

    /// One-tap advance button label shown on queue cards (delivery).
    var advanceButtonLabelDelivery: String {
        switch self {
        case .pending:    return "Start Preparing"
        case .inProgress: return "Mark Ready"
        case .ready:      return "Dispatch Rider"
        case .onDelivery: return "Mark Delivered"
        default:          return ""
        }
    }

    // MARK: - Timeline

    /// Timeline step title shown to the customer.
    func timelineTitle(isDelivery: Bool) -> String {
        switch self {
        case .pending:    return "Order Received"
        case .inProgress: return "Preparing"
        case .ready:      return isDelivery ? "Ready" : "Ready for Pickup"
        case .onDelivery: return "On Delivery"
        case .completed:  return isDelivery ? "Delivered" : "Completed"
        case .cancelled:  return "Cancelled"
        }
    }

    /// Timeline subtitle shown under the active step.
    func timelineSubtitle(isDelivery: Bool) -> String {
        switch self {
        case .pending:    return "Waiting to be prepared"
        case .inProgress: return "Barista is working on it"
        case .ready:      return isDelivery ? "Handing off to rider" : "Come pick it up!"
        case .onDelivery: return "Your order is on the way 🛵"
        case .completed:  return isDelivery ? "Delivered — enjoy!" : "Enjoy your coffee!"
        case .cancelled:  return "This order was cancelled"
        }
    }

    // MARK: - Firestore Query Helpers

    /// All statuses that count as "active" for Firestore `.whereField("status", in:)` queries.
    static var activeRawValues: [String] {
        OrderStatus.allCases
            .filter { $0.isActive }
            .map { $0.rawValue }
    }

    /// Convenience init from a raw Firestore string.
    /// Falls back to `.pending` if the value is unrecognised (e.g. legacy data).
    static func from(_ raw: String?) -> OrderStatus {
        guard let raw, let status = OrderStatus(rawValue: raw) else { return .pending }
        return status
    }
}

// MARK: - Order + OrderStatus convenience

extension Order {
    /// Typed status. Falls back to .pending for legacy / nil values.
    var orderStatus: OrderStatus {
        OrderStatus.from(status)
    }
}
