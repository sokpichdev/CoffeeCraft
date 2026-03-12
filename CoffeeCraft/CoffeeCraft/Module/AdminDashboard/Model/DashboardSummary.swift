//
//  DashboardSummary.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 3/12/26.
//

import Foundation

// MARK: - Dashboard Summary

struct DashboardSummary {
    let revenue: RevenueSummary
    let orders: OrderSummary
    let customers: CustomerSummary
    let liveActivity: [LiveOrderItem]
}

// MARK: - Revenue Summary

struct RevenueSummary {
    let today: Double
    let thisWeek: Double
    let thisMonth: Double

    var todayFormatted: String { today.asCurrency }
    var thisWeekFormatted: String { thisWeek.asCurrency }
    var thisMonthFormatted: String { thisMonth.asCurrency }
}

// MARK: - Order Summary

struct OrderSummary {
    let todayCount: Int
    let yesterdayCount: Int
    let activeCount: Int          // Pending + Preparing right now

    /// Percentage change vs. yesterday. Positive = up, negative = down.
    var dailyChangePct: Double {
        guard yesterdayCount > 0 else { return todayCount > 0 ? 100 : 0 }
        return ((Double(todayCount) - Double(yesterdayCount)) / Double(yesterdayCount)) * 100
    }

    var dailyChangeLabel: String {
        let pct = dailyChangePct
        let sign = pct >= 0 ? "+" : ""
        return "\(sign)\(String(format: "%.0f", pct))% vs yesterday"
    }

    var dailyChangeIsPositive: Bool { dailyChangePct >= 0 }
}

// MARK: - Customer Summary

struct CustomerSummary {
    let newThisWeek: Int
    let totalCount: Int
}

// MARK: - Live Activity

struct LiveOrderItem: Identifiable {
    let id: String           // orderId
    let customerName: String
    let totalPrice: Double
    let status: String
    let timestamp: Date
    let itemCount: Int

    var totalFormatted: String { totalPrice.asCurrency }

    /// Returns a human-readable relative time string relative to `now`.
    /// Pass the view's current tick date so SwiftUI re-renders correctly
    /// as time passes, rather than computing once and freezing.
    func timeAgo(relativeTo now: Date = Date()) -> String {
        let diff = now.timeIntervalSince(timestamp)
        if diff < 60 { return "Just now" }
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short          // "5 min. ago", "2 hr. ago"
        formatter.dateTimeStyle = .named       // prefers "yesterday" over "-1 day"
        return formatter.localizedString(for: timestamp, relativeTo: now)
    }
}

// MARK: - KPI Period Selector

enum DashboardPeriod: String, CaseIterable {
    case today = "Today"
    case week = "This Week"
    case month = "This Month"
}

// MARK: - Helpers

private extension Double {
    var asCurrency: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "$"
        formatter.maximumFractionDigits = 2
        return formatter.string(from: NSNumber(value: self)) ?? "$0.00"
    }
}
