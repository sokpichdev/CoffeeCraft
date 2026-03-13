//
//  ProductPerformanceView.swift
//  CoffeeCraft — Admin Dashboard Redesign
//

import Charts
import SwiftUI

// MARK: - Product Performance View

struct ProductPerformanceView: View {

    @StateObject private var vm = ProductPerformanceViewModel()

    var body: some View {
        CustomRefreshScrollView({
            VStack(alignment: .leading, spacing: 20) {

                periodPicker
                summaryCards

                if vm.isLoading {
                    DashboardLoadingPlaceholder(count: 3)
                } else if !vm.hasData {
                    DashboardEmptyState(
                        icon: "trophy",
                        title: "No sales data yet",
                        message: "Complete some orders to see product performance."
                    )
                } else {
                    bestSellersSection
                    categoryDonutSection
                    ratingScatterSection
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 32)
        }, onRefresh: {
            await vm.loadPerformance()
        })
        .background(Color.bgPrimary.ignoresSafeArea())
        .navigationTitle("Product Performance")
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

    // MARK: - Summary Cards

    private var summaryCards: some View {
        HStack(spacing: 12) {
            StatCard(
                title: "Units Sold",
                value: "\(vm.performanceData?.totalUnitsSold ?? 0)",
                icon: "shippingbox.fill",
                color: .accentPrimary,
                isLoading: vm.isLoading
            )
            StatCard(
                title: "Total Revenue",
                value: vm.performanceData?.totalRevenue.asCurrency ?? "$0.00",
                icon: "dollarsign.circle.fill",
                color: .semanticSuccess,
                isLoading: vm.isLoading
            )
            StatCard(
                title: "Products",
                value: "\(vm.performanceData?.topProducts.count ?? 0)",
                icon: "cup.and.saucer.fill",
                color: .accentGold,
                isLoading: vm.isLoading
            )
        }
    }

    // MARK: - Best Sellers Table

    private var bestSellersSection: some View {
        ChartCard(
            title: "Best Sellers",
            subtitle: "\(vm.selectedPeriod.rawValue) · Ranked by units sold"
        ) {
            LazyVStack(spacing: 0) {
                // Header row
                HStack {
                    Text("#").frame(width: 22, alignment: .center)
                    Text("Product").frame(maxWidth: .infinity, alignment: .leading)
                    Text("Sold").frame(width: 44, alignment: .trailing)
                    Text("Revenue").frame(width: 72, alignment: .trailing)
                    Text("★").frame(width: 34, alignment: .trailing)
                }
                .font(.caption.weight(.semibold))
                .foregroundStyle(Color.textMuted)
                .padding(.bottom, 8)

                Divider().background(Color.borderColor)

                ForEach(vm.performanceData?.topProducts ?? []) { item in
                    BestSellerRow(item: item, maxUnits: vm.maxUnitsSold)
                    if item.id != vm.performanceData?.topProducts.last?.id {
                        Divider().padding(.leading, 28).background(Color.borderColor)
                    }
                }
            }
        }
    }

    // MARK: - Category Revenue Donut

    private var categoryDonutSection: some View {
        ChartCard(
            title: "Revenue by Category",
            subtitle: vm.selectedPeriod.rawValue
        ) {
            HStack(alignment: .center, spacing: 20) {
                ZStack {
                    Chart(vm.performanceData?.categoryRevenue ?? []) { stat in
                        SectorMark(
                            angle: .value("Revenue", stat.revenue),
                            innerRadius: .ratio(0.55),
                            angularInset: 1.5
                        )
                        .foregroundStyle(by: .value("Category", stat.category))
                        .cornerRadius(4)
                    }
                    VStack(spacing: 2) {
                        Text(vm.totalRevenue.asCurrency)
                            .font(.subheadline.bold())
                            .minimumScaleFactor(0.6)
                            .foregroundStyle(Color.textPrimary)
                        Text("total")
                            .font(.caption2)
                            .foregroundStyle(Color.textMuted)
                    }
                }
                .frame(width: 150, height: 150)
                .chartLegend(.hidden)

                // Legend
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(vm.performanceData?.categoryRevenue ?? []) { stat in
                        HStack(spacing: 6) {
                            Circle()
                                .frame(width: 8, height: 8)
                                .foregroundStyle(categoryColor(stat.category,
                                    in: vm.performanceData?.categoryRevenue ?? []))
                            VStack(alignment: .leading, spacing: 1) {
                                Text(stat.category)
                                    .font(.caption.weight(.medium))
                                    .foregroundStyle(Color.textPrimary)
                                    .lineLimit(1)
                                Text("\(stat.percentageFormatted) · \(stat.revenueFormatted)")
                                    .font(.caption2)
                                    .foregroundStyle(Color.textMuted)
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }

    // MARK: - Rating vs Sales Scatter

    private var ratingScatterSection: some View {
        ChartCard(
            title: "Rating vs. Sales",
            subtitle: "Bubble size = revenue · Only rated products shown"
        ) {
            let ratedProducts = (vm.performanceData?.topProducts ?? []).filter(\.hasRatings)

            if ratedProducts.isEmpty {
                Text("No rated products in this period")
                    .font(.subheadline)
                    .foregroundStyle(Color.textMuted)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 24)
            } else {
                Chart(ratedProducts) { item in
                    PointMark(
                        x: .value("Rating", item.avgRating),
                        y: .value("Units Sold", item.unitsSold)
                    )
                    .foregroundStyle(Color.accentPrimary.opacity(0.7))
                    .symbolSize(max(60, min(600, item.revenue * 0.8)))
                    .annotation(position: .top, spacing: 4) {
                        Text(item.name)
                            .font(.system(size: 9))
                            .foregroundStyle(Color.textMuted)
                            .lineLimit(1)
                            .fixedSize()
                    }
                }
                .chartXScale(domain: 0...5.2)
                .chartXAxis {
                    AxisMarks(values: [1, 2, 3, 4, 5]) { value in
                        AxisGridLine(stroke: StrokeStyle(lineWidth: 0.4))
                        AxisValueLabel {
                            if let v = value.as(Double.self) {
                                HStack(spacing: 2) {
                                    Text(String(format: "%.0f", v))
                                    Image(systemName: "star.fill")
                                        .font(.system(size: 7))
                                        .foregroundStyle(.yellow)
                                }
                                .font(.caption2)
                            }
                        }
                    }
                }
                .chartYAxis {
                    AxisMarks(position: .leading) { value in
                        AxisGridLine(stroke: StrokeStyle(lineWidth: 0.4))
                        AxisValueLabel { value.as(Int.self).map { Text("\($0)").font(.caption2) } }
                    }
                }
                .chartOverlay { proxy in
                    if let plotFrame = proxy.plotFrame {
                        GeometryReader { geo in
                            let rect = geo[plotFrame]
                            Text("Sweet spot ↗")
                                .font(.system(size: 9, weight: .semibold))
                                .foregroundStyle(Color.semanticSuccess.opacity(0.6))
                                .position(x: rect.maxX - 36, y: rect.minY + 12)
                            Text("Underperforming ↙")
                                .font(.system(size: 9, weight: .semibold))
                                .foregroundStyle(Color.semanticError.opacity(0.5))
                                .position(x: rect.minX + 52, y: rect.maxY - 12)
                        }
                    }
                }
                .frame(height: 220)
            }
        }
    }

    private func categoryColor(_ category: String, in stats: [CategoryRevenueStat]) -> Color {
        let palette: [Color] = [.accentPrimary, .semanticSuccess, .accentGold, .orange, .teal, .semanticError, .yellow, .pink]
        let idx = stats.firstIndex(where: { $0.category == category }) ?? 0
        return palette[idx % palette.count]
    }
}

// MARK: - Best Seller Row

private struct BestSellerRow: View {
    let item: ProductStatItem
    let maxUnits: Int

    var body: some View {
        VStack(spacing: 6) {
            HStack(spacing: 8) {
                // Rank badge
                ZStack {
                    Circle()
                        .fill(rankColor)
                        .frame(width: 22, height: 22)
                    Text("\(item.rank)")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(item.rank <= 3 ? .white : Color.textSecondary)
                }

                VStack(alignment: .leading, spacing: 1) {
                    Text(item.name)
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(Color.textPrimary)
                        .lineLimit(1)
                    Text(item.category)
                        .font(.caption2)
                        .foregroundStyle(Color.textMuted)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Text("\(item.unitsSold)")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.textPrimary)
                    .frame(width: 44, alignment: .trailing)

                Text(item.revenueFormatted)
                    .font(.caption.weight(.medium))
                    .foregroundStyle(Color.textMuted)
                    .frame(width: 72, alignment: .trailing)

                HStack(spacing: 2) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 9))
                        .foregroundStyle(.yellow)
                    Text(item.hasRatings ? item.avgRatingFormatted : "—")
                        .font(.caption)
                        .foregroundStyle(Color.textSecondary)
                }
                .frame(width: 34, alignment: .trailing)
            }

            // Units progress bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.surfaceSub)
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.accentPrimary.opacity(0.55))
                        .frame(width: max(4, geo.size.width * ratio))
                }
            }
            .frame(height: 4)
            .padding(.leading, 30)
        }
        .padding(.vertical, 8)
    }

    private var ratio: CGFloat {
        maxUnits > 0 ? CGFloat(item.unitsSold) / CGFloat(maxUnits) : 0
    }

    private var rankColor: Color {
        switch item.rank {
        case 1: return .accentGold
        case 2: return Color(red: 0.72, green: 0.72, blue: 0.72)
        case 3: return Color(red: 0.78, green: 0.48, blue: 0.18)
        default: return Color.surfaceSub
        }
    }
}
