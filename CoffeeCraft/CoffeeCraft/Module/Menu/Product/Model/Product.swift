//
//  Product.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 10/20/25.
//
import Foundation

struct Product: Identifiable, Hashable, Codable, Equatable {
    var uID = UUID()
    var id: String
    var name: String
    var description: String
    var price: Double
    var imageURL: String
    var category: String
    var available: Bool = true
    var customizations: [String: [String: Double]]?

    // MARK: Phase 7 — Ratings
    /// Running average of all submitted star scores (1.0 – 5.0).
    /// nil on products created before Phase 7. Display as 0 or hide widget.
    var avgRating: Double?

    /// Total number of ratings submitted for this product.
    /// nil on legacy products — treat as 0.
    var ratingCount: Int?

    /// Score frequency map — keys are "1".."5" (Firestore map keys must be strings),
    /// values are the number of ratings at that score.
    /// Updated atomically alongside avgRating in every RatingService transaction.
    /// nil on legacy products that had no ratings before Phase 7.
    var ratingDistribution: [String: Int]?

    // MARK: Computed helpers

    /// Safe display value — falls back to 0.0 when no ratings yet.
    var displayRating: Double { avgRating ?? 0.0 }

    /// Safe count — falls back to 0 when no ratings yet.
    var displayRatingCount: Int { ratingCount ?? 0 }

    /// True when at least one rating has been submitted.
    var hasRatings: Bool { (ratingCount ?? 0) > 0 }

    /// Returns the distribution as an ordered array of (score, count) tuples
    /// for scores 5 down to 1, ready for the bar chart.
    /// Missing keys default to 0 so the chart always shows all 5 bars.
    var orderedDistribution: [(score: Int, count: Int)] {
        (1...5).reversed().map { score in
            (score: score, count: ratingDistribution?[String(score)] ?? 0)
        }
    }

    // MARK: Hashable / Equatable

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: Product, rhs: Product) -> Bool { lhs.id == rhs.id }

    static func empty(in category: String) -> Product {
        Product(
            id: UUID().uuidString,
            name: "",
            description: "",
            price: 0.0,
            imageURL: "",
            category: category,
            available: true,
            customizations: [:]
        )
    }
}

struct SectionData: Identifiable {
    var id: String { name }
    var name: String
    var items: [Product]
}

struct MenuItem: Identifiable {
    let id = UUID()
    let name: String
    let price: Double
    let image: String
}
