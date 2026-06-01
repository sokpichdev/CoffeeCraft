//
//  DateRange.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 28/05/2026.
//

import Foundation

/// A start/end date pair used by admin analytics filters.
/// `presetLabel` is set for named presets (e.g. "7 Days") and nil for custom ranges.
struct DateRange: Equatable {
    var start: Date
    var end: Date
    var presetLabel: String?

    /// Inclusive day count between start and end.
    var dayCount: Int {
        let cal = Calendar.current
        let days = cal.dateComponents([.day],
                                      from: cal.startOfDay(for: start),
                                      to: cal.startOfDay(for: end)).day ?? 0
        return max(1, days + 1)
    }

    var displayLabel: String {
        if let presetLabel { return presetLabel }
        let fmt = DateFormatter()
        fmt.dateFormat = "MMM d, yyyy"
        return "\(fmt.string(from: start)) – \(fmt.string(from: end))"
    }

    // MARK: - Presets

    static func lastDays(_ count: Int, label: String, now: Date = AppEnvironment.now) -> DateRange {
        let cal = Calendar.current
        let todayStart = cal.startOfDay(for: now)
        let start = cal.date(byAdding: .day, value: -(count - 1), to: todayStart)!
        return DateRange(start: start, end: now, presetLabel: label)
    }

    static var last7Days: DateRange  { lastDays(7,  label: "7 Days") }
    static var last30Days: DateRange { lastDays(30, label: "30 Days") }
    static var last90Days: DateRange { lastDays(90, label: "90 Days") }

    static func thisMonth(now: Date = AppEnvironment.now) -> DateRange {
        let cal = Calendar.current
        let start = cal.date(from: cal.dateComponents([.year, .month], from: now))!
        return DateRange(start: start, end: now, presetLabel: "This Month")
    }

    static func lastMonth(now: Date = AppEnvironment.now) -> DateRange {
        let cal = Calendar.current
        let thisMonthStart = cal.date(from: cal.dateComponents([.year, .month], from: now))!
        let lastMonthStart = cal.date(byAdding: .month, value: -1, to: thisMonthStart)!
        let lastMonthEnd = cal.date(byAdding: .second, value: -1, to: thisMonthStart)!
        return DateRange(start: lastMonthStart, end: lastMonthEnd, presetLabel: "Last Month")
    }
}
