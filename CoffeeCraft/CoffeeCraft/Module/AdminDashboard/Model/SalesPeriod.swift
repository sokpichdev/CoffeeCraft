//
//  SalesPeriod.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 12/03/2026.
//

import Foundation

// MARK: - Period Selector

enum SalesPeriod: String, CaseIterable, Identifiable {
    case week  = "7 Days"
    case month = "30 Days"

    var id: String { rawValue }

    /// Number of calendar days to look back from today.
    var dayCount: Int {
        switch self {
        case .week:  return 7
        case .month: return 30
        }
    }
}

// MARK: - Daily Revenue Point

/// One point on the revenue line/area chart.
/// `date` is always midnight (startOfDay) so the x-axis labels are clean.
struct DailyRevenuePoint: Identifiable {
    let id = UUID()
    let date: Date
    let revenue: Double
    let orderCount: Int

    var dateLabel: String {
        let fmt = DateFormatter()
        fmt.dateFormat = "MMM d"
        return fmt.string(from: date)
    }
}

// MARK: - Order Status Breakdown

/// One bar in the horizontal status breakdown chart.
struct OrderStatusPoint: Identifiable {
    let id = UUID()
    let status: String
    let count: Int
    let percentage: Double   // 0–100, pre-computed for the label
}

// MARK: - Peak Hour Point

/// One cell in the peak-hours heatmap.
/// `hour` is 0–23, `weekday` is 1 (Sun) – 7 (Sat) matching Calendar.
struct PeakHourPoint: Identifiable {
    let id = UUID()
    let hour: Int           // 0–23
    let weekday: Int        // 1=Sun … 7=Sat
    let orderCount: Int

    var hourLabel: String {
        let h = hour % 12 == 0 ? 12 : hour % 12
        return "\(h)\(hour < 12 ? "am" : "pm")"
    }

    var weekdayLabel: String {
        ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"][weekday - 1]
    }
}

// MARK: - Sales Summary (Stat Cards)

/// Scalar KPIs shown as stat cards above the charts.
struct SalesSummary {
    let totalRevenue: Double
    let totalOrders: Int
    let avgOrderValue: Double
    let refundRate: Double              // 0–100 %
    let cancelledCount: Int
    let completedCount: Int

    var totalRevenueFormatted: String  { totalRevenue.asCurrency }
    var avgOrderValueFormatted: String { avgOrderValue.asCurrency }
    var refundRateFormatted: String    { String(format: "%.1f%%", refundRate) }

    static var empty: SalesSummary {
        SalesSummary(totalRevenue: 0, totalOrders: 0, avgOrderValue: 0,
                     refundRate: 0, cancelledCount: 0, completedCount: 0)
    }
}

// MARK: - Full Analytics Payload

/// Everything the SalesAnalyticsViewModel holds for one period.
struct SalesAnalyticsData {
    let period: SalesPeriod
    let summary: SalesSummary
    let dailyRevenue: [DailyRevenuePoint]
    let statusBreakdown: [OrderStatusPoint]
    let peakHours: [PeakHourPoint]
}
