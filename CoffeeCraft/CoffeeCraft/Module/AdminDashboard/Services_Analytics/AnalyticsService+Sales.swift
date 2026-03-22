//
//  AnalyticsService+Sales.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 3/12/26.
//

import FirebaseFirestore
import Foundation

// MARK: - AnalyticsService — Sales Analytics (Phase 8.2)

extension AnalyticsService {

    // MARK: - Main Entry Point

    /// Fetches the complete sales analytics payload for the given period.
    /// All sub-queries run in parallel.
    func fetchSalesAnalytics(for period: SalesPeriod) async throws -> SalesAnalyticsData {
        let (start, end) = dateRange(for: period)
        let orders = try await fetchOrdersInRange(from: start, to: end)

        // All aggregations are computed from the same in-memory snapshot —
        // no extra Firestore reads needed after the initial fetch.
        async let summary = computeSummary(from: orders, period: period)
        async let dailyRevenue = computeDailyRevenue(from: orders, start: start, period: period)
        async let statusBreakdown = computeStatusBreakdown(from: orders)
        async let peakHours = computePeakHours(from: orders)

        return await SalesAnalyticsData(
            period: period,
            summary: summary,
            dailyRevenue: dailyRevenue,
            statusBreakdown: statusBreakdown,
            peakHours: peakHours
        )
    }

    // MARK: - Firestore Fetch

    /// Fetches all order documents in the date range regardless of status.
    /// Sorting happens client-side — we need all orders for every aggregation.
    private func fetchOrdersInRange(from start: Date, to end: Date) async throws -> [[String: Any]] {
        let snapshot = try await db.collection(Firebase.Orders.collection)
            .whereField(Firebase.Orders.timestamp, isGreaterThanOrEqualTo: Timestamp(date: start))
            .whereField(Firebase.Orders.timestamp, isLessThanOrEqualTo: Timestamp(date: end))
            .getDocuments()

        return snapshot.documents.map { $0.data() }
    }

    // MARK: - Summary Aggregation

    private func computeSummary(from orders: [[String: Any]], period: SalesPeriod) -> SalesSummary {
        let completed = orders.filter { $0["status"] as? String == OrderStatus.completed.rawValue }
        let cancelled = orders.filter { $0["status"] as? String == OrderStatus.cancelled.rawValue }

        let totalRevenue = completed.reduce(0.0) { $0 + ($1["totalPrice"] as? Double ?? 0) }
        let avgOrderValue = completed.isEmpty ? 0 : totalRevenue / Double(completed.count)
        let refundRate = orders.isEmpty ? 0 : (Double(cancelled.count) / Double(orders.count)) * 100

        return SalesSummary(
            totalRevenue: totalRevenue,
            totalOrders: orders.count,
            avgOrderValue: avgOrderValue,
            refundRate: refundRate,
            cancelledCount: cancelled.count,
            completedCount: completed.count
        )
    }

    // MARK: - Daily Revenue Series

    /// Groups completed-order revenue by calendar day.
    /// Fills in zero-revenue days so the chart x-axis has no gaps.
    private func computeDailyRevenue(from orders: [[String: Any]],
                                     start: Date,
                                     period: SalesPeriod) -> [DailyRevenuePoint] {
        let cal = Calendar.current

        // Build a dict: day-start-date → (revenue, count)
        var revenueMap: [Date: (Double, Int)] = [:]
        for order in orders {
            guard
                order["status"] as? String == OrderStatus.completed.rawValue,
                let ts = (order["timestamp"] as? Timestamp)?.dateValue()
            else { continue }

            let dayStart = cal.startOfDay(for: ts)
            let existing = revenueMap[dayStart] ?? (0, 0)
            revenueMap[dayStart] = (existing.0 + (order["totalPrice"] as? Double ?? 0),
                                    existing.1 + 1)
        }

        // Generate every day in the range, filling gaps with 0
        var points: [DailyRevenuePoint] = []
        var cursor = cal.startOfDay(for: start)
        let endDay = cal.startOfDay(for: Date())

        while cursor <= endDay {
            let (rev, count) = revenueMap[cursor] ?? (0, 0)
            points.append(DailyRevenuePoint(date: cursor, revenue: rev, orderCount: count))
            cursor = cal.date(byAdding: .day, value: 1, to: cursor)!
        }

        return points
    }

    // MARK: - Status Breakdown

    private func computeStatusBreakdown(from orders: [[String: Any]]) -> [OrderStatusPoint] {
        let total = orders.count
        guard total > 0 else { return [] }

        // Display order follows the natural flow; OnDelivery inserted between Ready and Completed
        let statusOrder: [OrderStatus] = [.completed, .inProgress, .pending, .ready, .onDelivery, .cancelled]
        var counts: [String: Int] = [:]
        for order in orders {
            let status = order["status"] as? String ?? "Unknown"
            counts[status, default: 0] += 1
        }

        return statusOrder.compactMap { status -> OrderStatusPoint? in
            guard let count = counts[status.rawValue], count > 0 else { return nil }
            return OrderStatusPoint(
                status: status.displayLabel,
                count: count,
                percentage: (Double(count) / Double(total)) * 100
            )
        }
    }

    // MARK: - Peak Hours Heatmap

    /// Counts orders per (hour, weekday) cell for the heatmap grid.
    /// Groups orders into the heatmap's 2-hour display columns (6am, 8am … 10pm).
    /// Only counts non-cancelled orders so noise doesn't distort the heatmap.
    private func computePeakHours(from orders: [[String: Any]]) -> [PeakHourPoint] {
        let cal = Calendar.current

        // (weekday, displayHour) → count
        var grid: [Int: [Int: Int]] = [:]

        for order in orders {
            guard
                order["status"] as? String != OrderStatus.cancelled.rawValue,
                let ts = (order["timestamp"] as? Timestamp)?.dateValue()
            else { continue }

            let hour = cal.component(.hour, from: ts)
            let weekday = cal.component(.weekday, from: ts)   // 1=Sun … 7=Sat

            // Snap to the nearest 2-hour display bucket used by the heatmap:
            // 6→6, 7→6, 8→8, 9→8, 10→10 … 22→22, 23→22
            // Orders before 6am and after 11pm are outside business hours — skip.
            guard hour >= 6 else { continue }
            let displayHour = min(22, (hour / 2) * 2)

            grid[weekday, default: [:]][displayHour, default: 0] += 1
        }

        var points: [PeakHourPoint] = []
        for weekday in 1...7 {
            for hour in stride(from: 6, through: 22, by: 2) {
                let count = grid[weekday]?[hour] ?? 0
                points.append(PeakHourPoint(hour: hour, weekday: weekday, orderCount: count))
            }
        }
        return points
    }

    // MARK: - Date Range Helper

    private func dateRange(for period: SalesPeriod) -> (Date, Date) {
        let now = Date()
        let todayStart = Calendar.current.startOfDay(for: now)
        let start = Calendar.current.date(byAdding: .day, value: -(period.dayCount - 1), to: todayStart)!
        return (start, now)
    }
}
