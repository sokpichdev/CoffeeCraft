import Charts
//
//  AnalyticsTab.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 3/14/26.
//
import SwiftUI
// MARK: - Analytics Tab (Donut + Scatter)

struct AnalyticsTab: View {
    @ObservedObject var vm: ProductPerformanceViewModel

    var body: some View {
        CustomRefreshScrollView({
            VStack(alignment: .leading, spacing: 20) {
                if vm.isLoading {
                    DashboardLoadingPlaceholder(count: 2)
                } else if !vm.hasData {
                    DashboardEmptyState(
                        icon: "chart.pie",
                        title: "No data yet",
                        message: "Complete some orders to see analytics."
                    )
                } else {
                    categoryDonutSection
                    ratingScatterSection
                }
            }
            .padding(EdgeInsets(top: 16, leading: 16, bottom: 32, trailing: 16))
        }, onRefresh: {
            await vm.loadPerformance()
        })
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
                            if let value = value.as(Double.self) {
                                HStack(spacing: 2) {
                                    Text(String(format: "%.0f", value))
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
            let palette: [Color] = [.accentPrimary, .semanticSuccess,
                                    .accentGold, .orange, .teal,
                                    .semanticError, .yellow, .pink]
            let idx = stats.firstIndex(where: { $0.category == category }) ?? 0
            return palette[idx % palette.count]
        }
}
