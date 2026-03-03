//
//  WalletError.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 3/3/26.
//

import SwiftUI

// MARK: - WalletError
// Typed errors for all Wallet operations.
// Follows the same LocalizedError pattern as CardError.swift.
//
// USAGE:
//   throw WalletError.insufficientBalance
//   catch { AlertManager.shared.showError(message: error.localizedDescription) }

enum WalletError: LocalizedError {
    case userNotAuthenticated
    case insufficientBalance
    case walletNotFound
    case invalidAmount
    case transactionFailed
    case orderNotFound
    case refundNotEligible

    var errorDescription: String? {
        switch self {
        case .userNotAuthenticated:
            return "User not authenticated. Please sign in and try again."
        case .insufficientBalance:
            return "Insufficient CoffeeCoins balance. Please top up and try again."
        case .walletNotFound:
            return "Wallet not found. Please top up first to create your wallet."
        case .invalidAmount:
            return "Invalid amount. Amount must be greater than zero."
        case .transactionFailed:
            return "Transaction failed. Please try again."
        case .orderNotFound:
            return "Order not found. Cannot process refund."
        case .refundNotEligible:
            return "This order is not eligible for a wallet refund."
        }
    }
}
