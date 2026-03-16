//
//  UserStatItem.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 3/13/26.
//

import FirebaseFirestore
import Foundation

// MARK: - User Stat Item (List Row)

/// Represents one customer in the User Management list.
struct UserStatItem: Identifiable {
    let id: String // userId (Firestore document ID)
    let name: String
    let email: String
    let joinDate: Date
    let loyaltyPoints: Int

    // Enriched asynchronously — nil while the enrichment query is in-flight
    var totalOrders: Int?
    var totalSpent: Double?

    var joinDateFormatted: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: joinDate)
    }

    var totalSpentFormatted: String {
        guard let spent = totalSpent else { return "—" }
        return spent.asCurrency
    }

    var totalOrdersFormatted: String {
        guard let count = totalOrders else { return "—" }
        return "\(count)"
    }

    var initials: String {
        let parts = name.split(separator: " ")
        let first = parts.first?.prefix(1) ?? ""
        let last = parts.dropFirst().first?.prefix(1) ?? ""
        return (first + last).uppercased()
    }
}

// MARK: - User Detail Data

struct UserDetailData {
    let user: UserStatItem
    let recentOrders: [UserOrderItem] // last 10
    let walletBalance: Double
    let fcmToken: String? // present when user has push notifications enabled

    var walletFormatted: String { walletBalance.asCurrency }
}

// MARK: - User Order Item

/// Lightweight order summary shown in the User Detail order history list.
struct UserOrderItem: Identifiable {
    let id: String
    let totalPrice: Double
    let status: String
    let timestamp: Date
    let itemCount: Int

    var totalFormatted: String { totalPrice.asCurrency }

    var timestampFormatted: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: timestamp)
    }

    /// Typed status — delegates to the shared OrderStatus enum.
    var orderStatus: OrderStatus { OrderStatus.from(status) }
}

// MARK: - User List Page (pagination cursor)

struct UserListPage {
    let items: [UserStatItem]
    let lastDocument: DocumentSnapshot?
    let hasMore: Bool
}
