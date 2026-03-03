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

import Foundation
import FirebaseFirestore

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
