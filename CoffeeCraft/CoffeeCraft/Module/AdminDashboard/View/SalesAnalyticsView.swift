//
//  SalesAnalyticsView.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 12/03/2026.
//

import Charts
import SwiftUI

// MARK: - Sales Analytics View

struct SalesAnalyticsView: View {

    @StateObject private var vm = SalesAnalyticsViewModel()

    var body: some View {
        CustomRefreshScrollView({
            VStack(alignment: .leading, spacing: 20) {

                periodPicker
                summaryCards

                if vm.isLoading {
                    loadingPlaceholder
                } else if !vm.hasData {
                    emptyState
                } else {
                    revenueChartSection
                    statusBreakdownSection
                    peakHoursSection
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 32)
        }, onRefresh: {
            await vm.loadAnalytics()
        })
        .navigationTitle("Sales Analytics")
        .navigationBarTitleDisplayMode(.large)
        .onAppear { vm.onAppear() }
    }

    // MARK: - Period Picker

    private var periodPicker: some View {
        Picker("Period", selection: $vm.selectedPeriod) {
            ForEach(SalesPeriod.allCases) { period in
                Text(period.rawValue).tag(period)
            }
        }
        .pickerStyle(.segmented)
        .padding(.top, 8)
        .onChange(of: vm.selectedPeriod) { _, _ in
            Task { await vm.periodChanged() }
        }
    }

    // MARK: - Summary Stat Cards

    private var summaryCards: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                StatCard(
                    title: "Total Revenue",
                    value: vm.analyticsData?.summary.totalRevenueFormatted ?? "$0.00",
                    icon: "dollarsign.circle.fill",
                    color: .green,
                    isLoading: vm.isLoading
                )
                StatCard(
                    title: "Total Orders",
                    value: "\(vm.analyticsData?.summary.totalOrders ?? 0)",
                    icon: "bag.fill",
                    color: .blue,
                    isLoading: vm.isLoading
                )
            }
            HStack(spacing: 12) {
                StatCard(
                    title: "Avg Order Value",
                    value: vm.analyticsData?.summary.avgOrderValueFormatted ?? "$0.00",
                    icon: "chart.bar.fill",
                    color: .purple,
                    isLoading: vm.isLoading
                )
                StatCard(
                    title: "Cancellation Rate",
                    value: vm.analyticsData?.summary.refundRateFormatted ?? "0.0%",
                    icon: "xmark.circle.fill",
                    color: vm.isLoading ? .secondary : cancellationRateColor,
                    isLoading: vm.isLoading
                )
            }
        }
    }

    private var cancellationRateColor: Color {
        let rate = vm.analyticsData?.summary.refundRate ?? 0
        if rate < 5  { return .green }
        if rate < 15 { return .orange }
        return .red
    }

    // MARK: - Revenue Chart

    private var revenueChartSection: some View {
        ChartCard(title: "Daily Revenue", subtitle: vm.selectedPeriod.rawValue) {
            Chart(vm.analyticsData?.dailyRevenue ?? []) { point in
                AreaMark(
                    x: .value("Date", point.date, unit: .day),
                    y: .value("Revenue", point.revenue)
                )
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color.accentPrimary.opacity(0.3), Color.accentPrimary.opacity(0.02)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .interpolationMethod(.catmullRom)

                LineMark(
                    x: .value("Date", point.date, unit: .day),
                    y: .value("Revenue", point.revenue)
                )
                .foregroundStyle(Color.accentPrimary)
                .lineStyle(StrokeStyle(lineWidth: 2))
                .interpolationMethod(.catmullRom)

                PointMark(
                    x: .value("Date", point.date, unit: .day),
                    y: .value("Revenue", point.revenue)
                )
                .foregroundStyle(Color.accentPrimary)
                .symbolSize(point.revenue > 0 ? 30 : 0)
            }
            .chartYScale(domain: 0...vm.revenueChartMax)
            .chartXAxis {
                AxisMarks(values: .stride(by: .day, count: axisDayStride)) { value in
                    AxisGridLine(stroke: StrokeStyle(lineWidth: 0.4))
                    AxisValueLabel(format: .dateTime.month(.abbreviated).day())
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading) { value in
                    AxisGridLine(stroke: StrokeStyle(lineWidth: 0.4))
                    AxisValueLabel {
                        if let v = value.as(Double.self) {
                            Text(v == 0 ? "$0" : "$\(Int(v))")
                                .font(.caption2)
                        }
                    }
                }
            }
            .frame(height: 200)
        }
    }

    /// Fewer x-axis labels for 30-day range so they don't overlap.
    private var axisDayStride: Int {
        vm.selectedPeriod == .week ? 1 : 5
    }

    // MARK: - Status Breakdown

    private var statusBreakdownSection: some View {
        ChartCard(title: "Orders by Status", subtitle: "All statuses · \(vm.selectedPeriod.rawValue)") {
            VStack(spacing: 10) {
                Chart(vm.analyticsData?.statusBreakdown ?? []) { point in
                    BarMark(
                        x: .value("Count", point.count),
                        y: .value("Status", point.status)
                    )
                    .foregroundStyle(statusColor(point.status))
                    .cornerRadius(4)
                    .annotation(position: .trailing, alignment: .leading) {
                        Text("\(point.count)  ·  \(String(format: "%.0f", point.percentage))%")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                            .padding(.leading, 4)
                    }
                }
                .chartXAxis(.hidden)
                .chartYAxis {
                    AxisMarks { value in
                        AxisValueLabel {
                            if let label = value.as(String.self) {
                                Text(label).font(.caption)
                            }
                        }
                    }
                }
                .frame(height: CGFloat((vm.analyticsData?.statusBreakdown.count ?? 3) * 44))
            }
        }
    }

    private func statusColor(_ status: String) -> Color {
        switch status {
        case "Completed": return .green
        case "Preparing": return .blue
        case "Pending": return .orange
        case "Ready": return .teal
        case "Cancelled": return .red
        default: return .secondary
        }
    }

    // MARK: - Peak Hours Heatmap

    private var peakHoursSection: some View {
        ChartCard(title: "Peak Ordering Hours", subtitle: "6 am – 10 pm · Non-cancelled orders") {
            PeakHoursHeatmap(
                points: vm.analyticsData?.peakHours ?? [],
                maxCount: vm.peakHourMax
            )
        }
    }

    // MARK: - States

    private var loadingPlaceholder: some View {
        VStack(spacing: 16) {
            ForEach(0..<3, id: \.self) { _ in
                ShimmerView()
                    .frame(maxWidth: .infinity)
                    .frame(height: 180)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "chart.xyaxis.line")
                .font(.system(size: 48))
                .foregroundStyle(.tertiary)
            Text("No data for this period")
                .font(.headline)
                .foregroundStyle(.secondary)
            Text("Place some orders to see analytics appear here.")
                .font(.subheadline)
                .foregroundStyle(.tertiary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 48)
    }
}

// MARK: - Stat Card

private struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    var isLoading: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.subheadline)
                    .foregroundStyle(color)
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            if isLoading {
                ShimmerView()
                    .frame(width: 80, height: 22)
                    .clipShape(RoundedRectangle(cornerRadius: 4))
            } else {
                Text(value)
                    .font(.title3.bold())
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(color.opacity(0.15), lineWidth: 1)
        )
    }
}

// MARK: - Chart Card Container

/// Consistent card wrapper used by all three chart sections.
private struct ChartCard<Content: View>: View {
    let title: String
    let subtitle: String
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline)
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            content()
        }
        .padding(16)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - Peak Hours Heatmap

/// Custom grid view — Swift Charts' RectangleMark doesn't support
/// categorical x × y axes cleanly on iOS 17, so we build the grid manually.
private struct PeakHoursHeatmap: View {

    let points: [PeakHourPoint]
    let maxCount: Int

    // Business hours shown on x-axis: 6am to 10pm
    private let hours   = stride(from: 6, through: 22, by: 2).map { $0 }
    private let weekdays = [1, 2, 3, 4, 5, 6, 7]   // Sun … Sat

    private func count(weekday: Int, hour: Int) -> Int {
        points.first { $0.weekday == weekday && $0.hour == hour }?.orderCount ?? 0
    }

    private func cellColor(for count: Int) -> Color {
        guard maxCount > 0 else { return Color.accentPrimary.opacity(0.05) }
        let intensity = Double(count) / Double(maxCount)
        // Low → light teal, high → deep accent
        return Color.accentPrimary.opacity(max(0.05, intensity * 0.85))
    }

    var body: some View {
        VStack(spacing: 0) {
            // Hour labels (x-axis)
            HStack(spacing: 0) {
                // Offset for weekday labels
                Text("")
                    .frame(width: 34)
                ForEach(hours, id: \.self) { hour in
                    let label = hour == 12 ? "12p" : hour < 12 ? "\(hour)a" : "\(hour - 12)p"
                    Text(label)
                        .font(.system(size: 9))
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.bottom, 4)

            // Rows: one per weekday
            ForEach(weekdays, id: \.self) { weekday in
                HStack(spacing: 2) {
                    // Weekday label
                    Text(weekdayLabel(weekday))
                        .font(.system(size: 10))
                        .foregroundStyle(.secondary)
                        .frame(width: 32, alignment: .trailing)

                    ForEach(hours, id: \.self) { hour in
                        let c = count(weekday: weekday, hour: hour)
                        RoundedRectangle(cornerRadius: 3)
                            .fill(cellColor(for: c))
                            .frame(maxWidth: .infinity)
                            .frame(height: 22)
                            .overlay(
                                c > 0 ?
                                Text("\(c)")
                                    .font(.system(size: 8, weight: .semibold))
                                    .foregroundStyle(c > maxCount / 2 ? .white : .primary)
                                : nil
                            )
                    }
                }
                .padding(.vertical, 1)
            }

            // Legend
            HStack(spacing: 6) {
                Text("Low")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                LinearGradient(
                    colors: [Color.accentPrimary.opacity(0.05), Color.accentPrimary.opacity(0.85)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .frame(width: 60, height: 8)
                .clipShape(Capsule())
                Text("High")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
            .padding(.top, 8)
        }
    }

    private func weekdayLabel(_ weekday: Int) -> String {
        ["S", "M", "T", "W", "T", "F", "S"][weekday - 1]
    }
}
