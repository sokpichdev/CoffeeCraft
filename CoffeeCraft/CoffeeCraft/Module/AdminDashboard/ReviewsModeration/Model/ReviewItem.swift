//
//  ReviewItem.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 3/13/26.
//

import FirebaseFirestore
import Foundation

// MARK: - Review Item

/// One review document from `products/{productId}/reviews/{reviewId}`.
/// Fetched via a collectionGroup query so all products are covered in one read.
struct ReviewItem: Identifiable {
    let id: String // reviewId (document ID)
    let productId: String // parent document ID — needed for hide/unhide writes
    let productName: String // joined from products collection at map time
    let customerName: String
    let userId: String
    let rating: Int // 1–5
    let comment: String
    let timestamp: Date
    var isHidden: Bool // `var` — toggled optimistically on hide/unhide

    var excerpt: String {
        comment.count > 100 ? String(comment.prefix(100)) + "…" : comment
    }

    var timestampFormatted: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: timestamp)
    }

    var ratingStars: String {
        String(repeating: "★", count: rating) +
        String(repeating: "☆", count: max(0, 5 - rating))
    }
}

// MARK: - Review Filter

struct ReviewFilter {
    var visibility: ReviewVisibility = .all
    var rating: Int? // nil = all ratings; 1–5 = specific star filter
    var productId: String? // nil = all products

    var isEmpty: Bool {
        visibility == .all && rating == nil && productId == nil
    }
}

enum ReviewVisibility: String, CaseIterable, Identifiable {
    case all = "All"
    case visible = "Visible"
    case hidden  = "Hidden"

    var id: String { rawValue }
}

// MARK: - Review Analytics (per product)

struct ReviewAnalyticsData {
    let productId: String
    let productName: String
    let totalCount: Int
    let hiddenCount: Int
    let avgRating: Double
    let ratingDistribution: [RatingBucket] // 1★ → 5★ counts
    let ratingOverTime: [RatingTimePoint] // weekly avg for the line chart

    var visibleCount: Int { totalCount - hiddenCount }
    var avgRatingFormatted: String { String(format: "%.1f", avgRating) }
    var hiddenPercentage: Double {
        totalCount > 0 ? (Double(hiddenCount) / Double(totalCount)) * 100 : 0
    }
}

struct RatingBucket: Identifiable {
    let id = UUID()
    let stars: Int // 1–5
    let count: Int
    let percentage: Double // 0–100
}

struct RatingTimePoint: Identifiable {
    let id = UUID()
    let weekStart: Date // Monday of each week
    let avgRating: Double
    let reviewCount: Int

    var weekLabel: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: weekStart)
    }
}

// MARK: - Product Option (filter picker)

struct ProductOption: Identifiable {
    let id: String // productId
    let name: String
}
