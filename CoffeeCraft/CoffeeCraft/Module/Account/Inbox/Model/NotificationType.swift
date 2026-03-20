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
    case reward        = "reward"        // loyalty-points milestone only
    case wallet        = "wallet"        // topup | payment | refund
    case announcement  = "announcement"
    case unknown                         // fallback — never crashes on unrecognised types
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
    /// When true, this notification was tagged as transient on creation and
    /// will be auto-deleted by the backend once its linked order reaches a
    /// terminal state. The client removes it via the `.removed` listener event.
    let isTransient: Bool
    let createdAt: Timestamp
    let payload: [String: String]?      // flexible — keys differ per type

    // ── Typed payload accessors ───────────────────────────────
    // Add a new var here whenever you add a new NotificationType.

    var orderStatusPayload: OrderStatusPayload? {
        guard type == .orderStatus,
              let orderId = payload?["orderId"],
              let status = payload?["status"]
        else { return nil }
        return OrderStatusPayload(orderId: orderId, status: status)
    }

    var promotionPayload: PromotionPayload? {
        guard type == .promotion,
              let code = payload?["discountCode"],
              let expires = payload?["expiresAt"]
        else { return nil }
        return PromotionPayload(discountCode: code, expiresAt: expires)
    }

    var walletPayload: WalletPayload? {
        guard type == .wallet,
              let txType = payload?["walletTxType"],
              let amount = payload?["amount"],
              let balanceAfter = payload?["balanceAfter"]
        else { return nil }
        return WalletPayload(
            walletTxType: txType,
            amount: Double(amount) ?? 0,
            balanceAfter: Double(balanceAfter) ?? 0,
            referenceId: payload?["referenceId"]
        )
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
struct WalletPayload {
    let walletTxType: String        // "topup" | "payment" | "refund" | "reward"
    let amount: Double              // positive = credit, negative = debit
    let balanceAfter: Double
    let referenceId: String?        // orderId for payment / refund

    /// Mirrors WalletTransactionType display logic without importing the wallet module.
    var icon: String {
        switch walletTxType {
        case "topup":   return "arrow.down.circle.fill"
        case "payment": return "cart.fill"
        case "refund":  return "arrow.uturn.left.circle.fill"
        default:        return "star.fill"
        }
    }

    var iconColorName: String {
        switch walletTxType {
        case "topup":   return "semanticSuccess"
        case "payment": return "semanticError"
        case "refund":  return "activeTF"
        default:        return "accentGold"
        }
    }

    var formattedAmount: String {
        let cc = Int(abs(amount))
        return amount >= 0 ? "+\(cc) CC" : "-\(cc) CC"
    }

    var formattedBalance: String { "\(Int(balanceAfter)) CC" }
}

struct OrderStatusPayload {
    let orderId: String
    let status: String

    /// Typed representation — falls back to .pending for unrecognised values.
    var orderStatus: OrderStatus { OrderStatus.from(status) }

    /// SF Symbol for the notification row icon.
    var statusIcon: String { orderStatus.icon }

    /// Named color string for use with Color(_:) in views.
    var statusColor: String {
        switch orderStatus {
        case .pending:    return "orange"
        case .inProgress: return "accentPrimary"
        case .ready:      return "semanticSuccess"
        case .onDelivery: return "blue"
        case .completed:  return "brown"
        case .cancelled:  return "semanticError"
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
