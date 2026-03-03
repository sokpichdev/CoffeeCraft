//
//  PaymentMethod.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 3/3/26.
//

import SwiftUI

// MARK: - PaymentMethod
// Shared enum used by CartManager, OrderService, and WalletService
// to represent how a customer pays for their order.
//
// USAGE:
//   CartManager  → holds the selected paymentMethod before checkout
//   OrderService → writes paymentMethod into the order document
//   WalletService → checks paymentMethod before deducting / refunding

enum PaymentMethod: String, Codable, CaseIterable {
    case wallet = "wallet"
    case cash   = "cash"

    // MARK: Display

    var displayName: String {
        switch self {
        case .wallet: return "CoffeeCoins Wallet"
        case .cash:   return "Cash at Counter"
        }
    }

    var icon: String {
        switch self {
        case .wallet: return "creditcard.fill"
        case .cash:   return "banknote"
        }
    }

    var description: String {
        switch self {
        case .wallet: return "Pay using your CC balance"
        case .cash:   return "Pay in person at the counter"
        }
    }
}
