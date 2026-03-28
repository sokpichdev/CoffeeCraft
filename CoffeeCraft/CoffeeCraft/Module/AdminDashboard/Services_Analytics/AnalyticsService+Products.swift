//
//  AnalyticsService+Products.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 13/03/26.
//

import FirebaseFirestore
import Foundation

// MARK: - AnalyticsService — Product Performance (Phase 8.3)

extension AnalyticsService {

    // MARK: - Main Entry Point

    /// Fetches the complete product performance payload for the given period.
    ///
    /// Strategy (two-step, no Cloud Function needed):
    ///   1. Fetch all Completed orders in range → explode items → build revenue/units map
    ///   2. Fetch the full product catalog in one query → join in memory
    ///
    /// This keeps Firestore reads to exactly 2 queries regardless of product count.
    func fetchProductPerformance(for period: SalesPeriod) async throws -> ProductPerformanceData {
        let (start, end) = productDateRange(for: period)

        // Run both queries in parallel — they're independent
        async let ordersData = fetchCompletedOrderItems(from: start, to: end)
        async let productsData = fetchAllProducts()

        let (itemMap, totalRevenue, totalUnits) = try await ordersData
        let productDocs = try await productsData

        // Join: enrich each product entry with catalog metadata
        let stats = buildProductStats(from: itemMap, catalog: productDocs)

        return ProductPerformanceData(
            period: period,
            topProducts: stats,
            categoryRevenue: buildCategoryRevenue(from: stats),
            totalRevenue: totalRevenue,
            totalUnitsSold: totalUnits
        )
    }

    // MARK: - Step 1: Order Items

    /// Returns a tuple of:
    ///   - `itemMap`: [productId → (unitsSold, revenue)]
    ///   - `totalRevenue`: sum across all items
    ///   - `totalUnits`: sum of all units sold
    private func fetchCompletedOrderItems(from start: Date,
                                          to end: Date) async throws -> ([String: (Int, Double)], Double, Int) {
        let snapshot = try await db.collection(Firebase.Orders.collection)
            .whereField(Firebase.Orders.status, isEqualTo: OrderStatus.completed.rawValue)
            .whereField(Firebase.Orders.timestamp, isGreaterThanOrEqualTo: Timestamp(date: start))
            .whereField(Firebase.Orders.timestamp, isLessThanOrEqualTo: Timestamp(date: end))
            .getDocuments()

        var itemMap: [String: (Int, Double)] = [:]
        var totalRevenue: Double = 0
        var totalUnits: Int = 0

        for doc in snapshot.documents {
            let data = doc.data()
            let items = data[Firebase.Orders.items] as? [[String: Any]] ?? []

            for item in items {
                // Defensive field access — try both "productId" and "id" as fallback
                guard let productId = item["productId"] as? String
                              ?? item["id"] as? String,
                      !productId.isEmpty
                else { continue }

                let quantity = item["quantity"] as? Int ?? 1
                // Price per unit — prefer item-level price, fall back to order-level
                let unitPrice = item["price"] as? Double
                             ?? item["totalPrice"] as? Double
                             ?? 0.0
                let lineRevenue = unitPrice * Double(quantity)

                let existing = itemMap[productId] ?? (0, 0.0)
                itemMap[productId] = (existing.0 + quantity, existing.1 + lineRevenue)

                totalRevenue += lineRevenue
                totalUnits += quantity
            }
        }

        return (itemMap, totalRevenue, totalUnits)
    }

    // MARK: - Step 2: Product Catalog

    /// Fetches the entire product catalog in one read.
    /// For a coffee shop with ~20–50 products this is always a single round-trip.
    private func fetchAllProducts() async throws -> [String: [String: Any]] {
        let snapshot = try await db.collection(Firebase.Products.collection).getDocuments()
        var catalog: [String: [String: Any]] = [:]
        for doc in snapshot.documents {
            catalog[doc.documentID] = doc.data()
        }
        return catalog
    }

    // MARK: - Step 3: Build Joined Stats

    private func buildProductStats(from itemMap: [String: (Int, Double)],
                                   catalog: [String: [String: Any]]) -> [ProductStatItem] {
        var stats: [ProductStatItem] = []

        for (productId, (units, revenue)) in itemMap {
            let data = catalog[productId] ?? [:]
            let name = data[Firebase.Products.name] as? String ?? "Unknown Product"
            let category = data[Firebase.Products.category] as? String ?? "Uncategorized"
            let avgRating = data[Firebase.Products.avgRating] as? Double ?? 0.0
            let ratingCount = data[Firebase.Products.ratingCount] as? Int ?? 0
            let imageURL = data[Firebase.Products.imageURL] as? String

            stats.append(ProductStatItem(
                id: productId,
                name: name,
                category: category,
                unitsSold: units,
                revenue: revenue,
                avgRating: avgRating,
                ratingCount: ratingCount,
                imageURL: imageURL
            ))
        }

        // Sort by units sold descending, assign 1-based rank
        stats.sort { $0.unitsSold > $1.unitsSold }
        for i in stats.indices {
            stats[i].rank = i + 1
        }

        return stats
    }

    // MARK: - Step 4: Category Breakdown

    private func buildCategoryRevenue(from stats: [ProductStatItem]) -> [CategoryRevenueStat] {
        let totalRevenue = stats.reduce(0) { $0 + $1.revenue }
        guard totalRevenue > 0 else { return [] }

        // Group by category
        var categoryMap: [String: (Double, Int)] = [:]   // category → (revenue, units)
        for stat in stats {
            let existing = categoryMap[stat.category] ?? (0, 0)
            categoryMap[stat.category] = (existing.0 + stat.revenue,
                                          existing.1 + stat.unitsSold)
        }

        return categoryMap
            .map { category, values in
                CategoryRevenueStat(
                    category: category,
                    revenue: values.0,
                    unitsSold: values.1,
                    percentage: (values.0 / totalRevenue) * 100
                )
            }
            .sorted { $0.revenue > $1.revenue }  // largest slice first
    }

    // MARK: - Date Range Helper

    private func productDateRange(for period: SalesPeriod) -> (Date, Date) {
        let now = Date()
        let todayStart = Calendar.current.startOfDay(for: now)
        let start = Calendar.current.date(
            byAdding: .day,
            value: -(period.dayCount - 1),
            to: todayStart
        )!
        return (start, now)
    }
}
