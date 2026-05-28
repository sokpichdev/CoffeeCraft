//
//  ProductStatItem.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 13/03/2026.
//

import Foundation

// MARK: - Product Stat Item

/// Aggregated performance data for one product over a given period.
/// Built by joining order item data with the product catalog.
struct ProductStatItem: Identifiable {
    let id: String // productId
    let name: String
    let category: String
    let unitsSold: Int
    let revenue: Double
    let avgRating: Double // pulled from products/{productId}.avgRating
    let ratingCount: Int
    let imageURL: String?
    var rank: Int = 0 // assigned after sorting, 1-based

    var revenueFormatted: String { revenue.asCurrency }
    var avgRatingFormatted: String { String(format: "%.1f", avgRating) }

    /// True when the product has enough rating data to be meaningful on the scatter.
    var hasRatings: Bool { ratingCount >= 1 }
}

// MARK: - Category Revenue Stat

/// One slice in the category revenue donut chart.
struct CategoryRevenueStat: Identifiable {
    let id = UUID()
    let category: String
    let revenue: Double
    let unitsSold: Int
    let percentage: Double // 0–100, pre-computed

    var revenueFormatted: String { revenue.asCurrency }
    var percentageFormatted: String { String(format: "%.1f%%", percentage) }
}

// MARK: - Full Performance Payload

struct ProductPerformanceData {
    let range: DateRange
    let topProducts: [ProductStatItem] // sorted by unitsSold desc, rank assigned
    let categoryRevenue: [CategoryRevenueStat]  // sorted by revenue desc
    let totalRevenue: Double
    let totalUnitsSold: Int

    var hasData: Bool { totalUnitsSold > 0 }

    /// Top 5 only — used for the bar chart so it doesn't get crowded.
    var top5Products: [ProductStatItem] { Array(topProducts.prefix(5)) }
}
