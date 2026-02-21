//
//  NotificationType.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 2/21/26.
//

import FirebaseFirestore

// ─────────────────────────────────────────────────────────────
// MARK: - Notification Type
// Add new cases here as you add new cloud function triggers.
// ─────────────────────────────────────────────────────────────
enum NotificationType: String, Codable {
    case orderStatus   = "order_status"
    case promotion     = "promotion"
    case reward        = "reward"
    case announcement  = "announcement"
    case unknown       // fallback — never crashes on unrecognised types
}

// ─────────────────────────────────────────────────────────────
// MARK: - Base Model
// Every notification in Firestore shares these fields.
// `payload` is a raw [String: String] dict — each type reads
// only the keys it cares about via its own typed struct below.
// ─────────────────────────────────────────────────────────────
struct AppNotification: Identifiable, Codable {
    @DocumentID var id: String?
    let type: NotificationType
    let title: String
    let message: String
    let isRead: Bool
    let createdAt: Timestamp
    let payload: [String: String]?      // flexible — keys differ per type

    // ── Typed payload accessors ───────────────────────────────
    // Add a new var here whenever you add a new NotificationType.

    var orderStatusPayload: OrderStatusPayload? {
        guard type == .orderStatus,
              let orderId = payload?["orderId"],
              let status  = payload?["status"]
        else { return nil }
        return OrderStatusPayload(orderId: orderId, status: status)
    }

    var promotionPayload: PromotionPayload? {
        guard type == .promotion,
              let code    = payload?["discountCode"],
              let expires = payload?["expiresAt"]
        else { return nil }
        return PromotionPayload(discountCode: code, expiresAt: expires)
    }

    var rewardPayload: RewardPayload? {
        guard type == .reward,
              let earned = payload?["pointsEarned"],
              let total  = payload?["totalPoints"]
        else { return nil }
        return RewardPayload(
            pointsEarned: Int(earned) ?? 0,
            totalPoints: Int(total) ?? 0
        )
    }
}

// ─────────────────────────────────────────────────────────────
// MARK: - Typed Payload Structs
// Pure value types — no Firestore dependency.
// Add a new struct for each new NotificationType.
// ─────────────────────────────────────────────────────────────
struct OrderStatusPayload {
    let orderId: String
    let status: String

    var statusIcon: String {
        switch status {
        case "Preparing":  return "cup.and.saucer.fill"
        case "Ready":      return "checkmark.seal.fill"
        case "Completed":  return "bag.fill.badge.checkmark"
        case "Cancelled":  return "xmark.circle.fill"
        default:           return "clock.fill"
        }
    }

    var statusColor: String {   // map in view with Color(payload.statusColor)
        switch status {
        case "Preparing":  return "orange"
        case "Ready":      return "green"
        case "Completed":  return "brown"
        case "Cancelled":  return "red"
        default:           return "gray"
        }
    }
}

struct PromotionPayload {
    let discountCode: String
    let expiresAt: String
}

struct RewardPayload {
    let pointsEarned: Int
    let totalPoints: Int
}
