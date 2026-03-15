//
//  Order.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 10/23/25.
//
//  added paymentMethod + walletAmountPaid fields.
//  All existing fields are untouched — fully backward compatible.
//  Old orders without paymentMethod decode cleanly (optional field → nil).
//

import FirebaseFirestore
import Foundation

struct Order: Identifiable, Codable, Hashable, Equatable {
    @DocumentID var id: String?
    var orderId: Int?
    var userId: String?
    var items: [CartItemData?]?
    var totalPrice: Double?
    var status: String?
    var timestamp: Date?

    // MARK: Phase 4 — Wallet integration
    /// "wallet" | "cash" — nil on old orders (treated as cash)
    var paymentMethod: String?
    /// The CC amount actually deducted. Used by Phase 5 refund.
    var walletAmountPaid: Double?

    // MARK: Phase 4 — Branch tagging (Map module)
    /// Firestore document ID of the branch this order was placed from.
    /// nil on orders placed before Phase 4 — treat as "branch unspecified".
    var branchId: String?
    /// Display name snapshot at time of order. Stored so history shows
    /// the correct name even if the branch is renamed later.
    var branchName: String?

    // MARK: Delivery (Map module Phase 4)
    /// Firestore document ID in deliveries/{orderId}. nil = pickup order (no tracking).
    var deliverySessionId: String?
    /// "delivery" | "pickup" — nil on old orders treated as pickup.
    var deliveryType: String?

    var isDeliveryOrder: Bool { deliveryType == "delivery" }

    // MARK: Phase 7 — Ratings (proof of purchase)
    /// Flat array of productIds from all items in this order.
    /// Written at checkout by OrderService. Enables single-query proof-of-
    /// purchase check: .whereField("productIds", arrayContains: productId)
    /// nil on orders placed before Phase 7 — treated as unverifiable (deny rating).
    var productIds: [String]?

    // MARK: Computed helpers

    var wasWalletPayment: Bool {
        paymentMethod == PaymentMethod.wallet.rawValue
    }

    // MARK: Hashable / Equatable

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: Order, rhs: Order) -> Bool {
        lhs.id == rhs.id &&
        lhs.status == rhs.status &&
        lhs.totalPrice == rhs.totalPrice &&
        lhs.orderId == rhs.orderId &&
        lhs.items == rhs.items
    }
}

// Simpler model just for decoding item info
struct CartItemData: Identifiable, Codable, Hashable {
    var id: String { "\(name ?? "unknown")-\(price ?? 0.0)" }
    var productId: String?
    var name: String?
    var imageURL: String?
    var selections: [String: String]?
    var extras: [String]?
    var price: Double?
    var quantity: Int?

    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(price)
        hasher.combine(imageURL)
        hasher.combine(selections)
        hasher.combine(extras)
        hasher.combine(quantity)
        hasher.combine(productId)
    }

    static func == (lhs: CartItemData, rhs: CartItemData) -> Bool {
        lhs.name == rhs.name &&
        lhs.price == rhs.price &&
        lhs.imageURL == rhs.imageURL &&
        lhs.selections == rhs.selections &&
        lhs.extras == rhs.extras &&
        lhs.quantity == rhs.quantity &&
        lhs.productId == rhs.productId
    }
}
