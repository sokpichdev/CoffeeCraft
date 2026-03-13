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
                    DashboardLoadingPlaceholder(count: 3)
                } else if !vm.hasData {
                    DashboardEmptyState()
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
        .background(Color.bgPrimary.ignoresSafeArea())
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
                    color: .semanticSuccess,
                    isLoading: vm.isLoading
                )
                StatCard(
                    title: "Total Orders",
                    value: "\(vm.analyticsData?.summary.totalOrders ?? 0)",
                    icon: "bag.fill",
                    color: .accentPrimary,
                    isLoading: vm.isLoading
                )
            }
            HStack(spacing: 12) {
                StatCard(
                    title: "Avg Order Value",
                    value: vm.analyticsData?.summary.avgOrderValueFormatted ?? "$0.00",
                    icon: "chart.bar.fill",
                    color: .accentGold,
                    isLoading: vm.isLoading
                )
                StatCard(
                    title: "Cancellation Rate",
                    value: vm.analyticsData?.summary.refundRateFormatted ?? "0.0%",
                    icon: "xmark.circle.fill",
                    color: vm.isLoading ? .secondary : cancellationRateColor,
                    isLoading: vm.isLoading,
                    tintBackground: !vm.isLoading
                )
            }
        }
    }

    private var cancellationRateColor: Color {
        let rate = vm.analyticsData?.summary.refundRate ?? 0
        if rate < 5 { return .semanticSuccess }
        if rate < 15 { return .orange }
        return .semanticError
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
                        colors: [Color.accentPrimary.opacity(0.28), Color.accentPrimary.opacity(0.02)],
                        startPoint: .top, endPoint: .bottom
                    )
                )
                .interpolationMethod(.catmullRom)

                LineMark(
                    x: .value("Date", point.date, unit: .day),
                    y: .value("Revenue", point.revenue)
                )
                .foregroundStyle(Color.accentPrimary)
                .lineStyle(StrokeStyle(lineWidth: 2.5))
                .interpolationMethod(.catmullRom)

                PointMark(
                    x: .value("Date", point.date, unit: .day),
                    y: .value("Revenue", point.revenue)
                )
                .foregroundStyle(Color.accentPrimary)
                .symbolSize(point.revenue > 0 ? 32 : 0)
            }
            .chartYScale(domain: 0...vm.revenueChartMax)
            .chartXAxis {
                AxisMarks(values: .stride(by: .day, count: axisDayStride)) { _ in
                    AxisGridLine(stroke: StrokeStyle(lineWidth: 0.4))
                    AxisValueLabel(format: .dateTime.month(.abbreviated).day())
                        .font(.caption2)
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading) { value in
                    AxisGridLine(stroke: StrokeStyle(lineWidth: 0.4))
                    AxisValueLabel {
                        if let v = value.as(Double.self) {
                            Text(v == 0 ? "$0" : "$\(Int(v))").font(.caption2)
                        }
                    }
                }
            }
            .frame(height: 200)
        }
    }

    private var axisDayStride: Int { vm.selectedPeriod == .week ? 1 : 5 }

    // MARK: - Status Breakdown

    private var statusBreakdownSection: some View {
        ChartCard(title: "Orders by Status",
                  subtitle: "All statuses · \(vm.selectedPeriod.rawValue)") {
            Chart(vm.analyticsData?.statusBreakdown ?? []) { point in
                BarMark(
                    x: .value("Count", point.count),
                    y: .value("Status", point.status)
                )
                .foregroundStyle(statusColor(point.status))
                .cornerRadius(5)
                .annotation(position: .trailing, alignment: .leading) {
                    Text("\(point.count)  ·  \(String(format: "%.0f", point.percentage))%")
                        .font(.caption2)
                        .foregroundStyle(Color.textMuted)
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

    private func statusColor(_ status: String) -> Color {
        switch status {
        case "Completed": return .semanticSuccess
        case "Preparing": return Color.accentPrimary
        case "Pending": return .orange
        case "Ready": return .teal
        case "Cancelled": return .semanticError
        default: return .secondary
        }
    }

    // MARK: - Peak Hours Heatmap

    private var peakHoursSection: some View {
        ChartCard(title: "Peak Ordering Hours",
                  subtitle: "6 am – 10 pm · Non-cancelled orders") {
            PeakHoursHeatmap(
                points: vm.analyticsData?.peakHours ?? [],
                maxCount: vm.peakHourMax
            )
        }
    }
}

// MARK: - Peak Hours Heatmap

private struct PeakHoursHeatmap: View {

    let points: [PeakHourPoint]
    let maxCount: Int

    private let hours = stride(from: 6, through: 22, by: 2).map { $0 }
    private let weekdays = [1, 2, 3, 4, 5, 6, 7]

    private func count(weekday: Int, hour: Int) -> Int {
        points.first { $0.weekday == weekday && $0.hour == hour }?.orderCount ?? 0
    }

    private func cellColor(for count: Int) -> Color {
        guard maxCount > 0 else { return Color.accentPrimary.opacity(0.05) }
        let intensity = Double(count) / Double(maxCount)
        return Color.accentPrimary.opacity(max(0.05, intensity * 0.85))
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                Text("").frame(width: 34)
                ForEach(hours, id: \.self) { hour in
                    let label = hour == 12 ? "12p" : hour < 12 ? "\(hour)a" : "\(hour - 12)p"
                    Text(label)
                        .font(.system(size: 9))
                        .foregroundStyle(Color.textMuted)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.bottom, 4)

            ForEach(weekdays, id: \.self) { weekday in
                HStack(spacing: 2) {
                    Text(weekdayLabel(weekday))
                        .font(.system(size: 10))
                        .foregroundStyle(Color.textMuted)
                        .frame(width: 32, alignment: .trailing)

                    ForEach(hours, id: \.self) { hour in
                        let count = count(weekday: weekday, hour: hour)
                        RoundedRectangle(cornerRadius: 3)
                            .fill(cellColor(for: count))
                            .frame(maxWidth: .infinity)
                            .frame(height: 22)
                            .overlay(
                                count > 0 ?
                                Text("\(count)")
                                    .font(.system(size: 8, weight: .semibold))
                                    .foregroundStyle(count > maxCount / 2 ? .white : Color.textPrimary)
                                : nil
                            )
                    }
                }
                .padding(.vertical, 1)
            }

            // Legend
            HStack(spacing: 6) {
                Text("Low").font(.caption2).foregroundStyle(Color.textMuted)
                LinearGradient(
                    colors: [Color.accentPrimary.opacity(0.05), Color.accentPrimary.opacity(0.85)],
                    startPoint: .leading, endPoint: .trailing
                )
                .frame(width: 60, height: 8)
                .clipShape(Capsule())
                Text("High").font(.caption2).foregroundStyle(Color.textMuted)
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
            .padding(.top, 8)
        }
    }

    private func weekdayLabel(_ weekday: Int) -> String {
        ["S", "M", "T", "W", "T", "F", "S"][weekday - 1]
    }
}
