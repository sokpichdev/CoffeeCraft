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
    @Environment(\.dismiss) private var dismiss
    @State private var showDatePicker = false
    var body: some View {
        CustomRefreshScrollView({
            VStack(alignment: .leading, spacing: 20) {

                dateRangeBar
                    .padding(.top, 8)

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
        .customNavigationBar("Sales Snalytics", displayMode: .large) {
            ToolBarButton.back {
                dismiss()
            }
        }
        .onAppear {
            Task { await vm.loadAnalytics() }
        }
        .sheet(isPresented: $showDatePicker) {
            DateRangePickerSheet(range: $vm.selectedRange) {
                Task { await vm.loadAnalytics() }
            }
        }
    }

    // MARK: - Date Range Bar

    private var dateRangeBar: some View {
        Button {
            showDatePicker = true
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "calendar")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Color.accentPrimary)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Date Range")
                        .font(.caption2)
                        .foregroundStyle(Color.textMuted)
                    Text(vm.selectedRange.displayLabel)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color.textPrimary)
                }
                Spacer()
                Image(systemName: "chevron.down")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Color.textMuted)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(Color.surfacePrimary)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.borderColor, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
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
        ChartCard(title: "Daily Revenue", subtitle: vm.selectedRange.displayLabel) {
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
                        if let value = value.as(Double.self) {
                            Text(value == 0 ? "$0" : "$\(Int(value))").font(.caption2)
                        }
                    }
                }
            }
            .frame(height: 200)
        }
    }

    private var axisDayStride: Int { vm.selectedRange.dayCount <= 10 ? 1 : max(1, vm.selectedRange.dayCount / 7) }

    // MARK: - Status Breakdown

    private var statusBreakdownSection: some View {
        ChartCard(title: "Orders by Status",
                  subtitle: "All statuses · \(vm.selectedRange.displayLabel)") {
            Chart(vm.analyticsData?.statusBreakdown ?? []) { point in
                BarMark(
                    x: .value("Count", point.count),
                    y: .value("Status", point.status)
                )
                .foregroundStyle(OrderStatus.from(point.status).color)
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

    // MARK: - Peak Hours Heatmap

    private var peakHoursSection: some View {
        ChartCard(title: "Peak Ordering Hours",
                  subtitle: "6 am – 10 pm · Non-cancelled orders") {
            PeakHoursHeatmap(
                matrix: vm.heatmapMatrix,
                maxCount: vm.peakHourMax
            )
        }
    }
}
