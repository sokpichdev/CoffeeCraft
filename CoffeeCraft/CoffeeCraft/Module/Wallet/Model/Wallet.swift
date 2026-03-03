//
//  Wallet.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 3/3/26.
//

import Foundation
import FirebaseFirestore

// MARK: - Wallet
// Represents a single wallet document in Firestore.
// Collection: "wallets"
// Document ID: userId (Firebase Auth UID)
//
// FIRESTORE SHAPE:
// /wallets/<USER_UID>
// {
//   "balance":    87.50,
//   "currency":   "CC",
//   "totalTopUp": 200.0,
//   "totalSpent": 112.50,
//   "createdAt":  <Timestamp>,
//   "updatedAt":  <Timestamp>
// }
//
// NOTE: balance is always updated atomically via runTransaction()
// alongside a corresponding wallet_transaction document write.
// Never update balance directly — always go through WalletService.

struct Wallet: Identifiable, Codable {

    // MARK: - Stored Properties

    @DocumentID var id: String?     // = userId (Firebase UID)
    var balance: Double             // Current CC balance (cached aggregate)
    let currency: String            // Always "CC" — reserved for future use
    var totalTopUp: Double          // Lifetime total topped up
    var totalSpent: Double          // Lifetime total spent on orders
    let createdAt: Date             // When wallet was first created
    var updatedAt: Date             // Last time balance changed

    // MARK: - Computed Helpers

    /// Balance formatted for display — e.g. "87 CC"
    var formattedBalance: String {
        "\(Int(balance)) CC"
    }

    /// True if balance is enough to cover a given amount
    func canAfford(_ amount: Double) -> Bool {
        balance >= amount
    }

    /// True if wallet has any balance at all
    var hasBalance: Bool {
        balance > 0
    }
}

// MARK: - Wallet + Defaults
extension Wallet {

    /// Returns a brand-new wallet document ready to be written to Firestore.
    /// Called by WalletService.createWallet() on a user's first top-up.
    static func new(for userId: String) -> Wallet {
        Wallet(
            id: userId,
            balance: 0,
            currency: "CC",
            totalTopUp: 0,
            totalSpent: 0,
            createdAt: Date(),
            updatedAt: Date()
        )
    }
}
