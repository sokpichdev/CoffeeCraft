//
//  ProductPerformanceView.swift
//  CoffeeCraft — Admin Dashboard Redesign
//

import Charts
import SwiftUI

// MARK: - Tab Enum

enum PerformanceTab: CaseIterable, Identifiable {
    case analytics, bestSellers
    var id: Self { self }
    var title: String {
        switch self {
        case .analytics: return "Analytics"
        case .bestSellers: return "Best Sellers"
        }
    }
    var icon: String {
        switch self {
        case .analytics: return "chart.pie.fill"
        case .bestSellers: return "trophy.fill"
        }
    }
}

struct ProductPerformanceView: View {

    @StateObject private var vm = ProductPerformanceViewModel()
    @Environment(\.dismiss) private var dismiss

    /// Drives conditional rendering — only one tab's subtree exists at a time.
    @State private var activeTab: PerformanceTab = .analytics

    var body: some View {
        VStack(spacing: 0) {

            // Sticky header
            stickyHeader
            tabBar

            Group {
                if activeTab == .analytics {
                    AnalyticsTab(vm: vm)
                        .transition(.opacity) // cheap; avoids layout animation
                } else {
                    BestSellersTab(vm: vm)
                        .transition(.opacity)
                }
            }
            .animation(.easeInOut(duration: 0.18), value: activeTab)
        }
        .background(Color.bgPrimary.ignoresSafeArea())
        .customNavigationBar("Product Performance", displayMode: .large) {
            ToolBarButton.back { dismiss() }
        }
        .onAppear { vm.onAppear() }
    }

    /// Rendered once, never re-drawn during scroll.
    private var stickyHeader: some View {
        VStack(spacing: 12) {
            Picker("Period", selection: $vm.selectedPeriod) {
                ForEach(SalesPeriod.allCases) { p in
                    Text(p.rawValue).tag(p)
                }
            }
            .pickerStyle(.segmented)
            .onChange(of: vm.selectedPeriod) { _, _ in
                Task { await vm.periodChanged() }
            }

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
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.bgPrimary)
    }

    private var tabBar: some View {
        HStack(spacing: 0) {
            ForEach(PerformanceTab.allCases) { tab in
                Button {
                    activeTab = tab
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: tab.icon)
                            .font(.system(size: 13, weight: .semibold))
                        Text(tab.title)
                            .font(.subheadline.weight(.semibold))
                    }
                    .foregroundStyle(activeTab == tab ? Color.accentPrimary : Color.textMuted)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .overlay(alignment: .bottom) {
                        if activeTab == tab {
                            Rectangle()
                                .fill(Color.accentPrimary)
                                .frame(height: 2)
                                .matchedGeometryEffect(id: "tabUnderline", in: tabNS)
                        }
                    }
                }
                .buttonStyle(.plain)
            }
        }
        .background(
            Divider(), alignment: .bottom
        )
        .padding(.horizontal, 16)
    }

    @Namespace private var tabNS
}

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
            let palette: [Color] = [.accentPrimary, .semanticSuccess, .accentGold, .orange, .teal, .semanticError, .yellow, .pink]
            let idx = stats.firstIndex(where: { $0.category == category }) ?? 0
            return palette[idx % palette.count]
        }
}

// MARK: - Best Sellers Tab

/// LazyVStack means rows are only instantiated as they scroll into view.
/// For very long lists this is the single biggest win.
struct BestSellersTab: View {
    @ObservedObject var vm: ProductPerformanceViewModel

    var body: some View {
        CustomRefreshScrollView({
            if vm.isLoading {
                DashboardLoadingPlaceholder(count: 5)
                    .padding(EdgeInsets(top: 16, leading: 16, bottom: 32, trailing: 16))
            } else if !vm.hasData {
                DashboardEmptyState(
                    icon: "trophy",
                    title: "No sales data yet",
                    message: "Complete some orders to see product performance."
                )
                .padding(EdgeInsets(top: 16, leading: 16, bottom: 32, trailing: 16))
            } else {
                LazyVStack(spacing: 0, pinnedViews: [.sectionHeaders]) {
                    Section {
                        let products = vm.performanceData?.topProducts ?? []
                        ForEach(Array(products.enumerated()), id: \.element.id) { index, item in
                            BestSellerRow(item: item, maxUnits: vm.maxUnitsSold)
                                .id(item.id)

                            if index < products.count - 1 {
                                Divider()
                                    .padding(.leading, 28)
                                    .background(Color.borderColor)
                            }
                        }
                    } header: {
                        listHeader
                    }
                }
                .background(Color.surfacePrimary)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .padding(EdgeInsets(top: 16, leading: 16, bottom: 32, trailing: 16))
            }
        }, onRefresh: {
            await vm.loadPerformance()
        })
    }

    private var listHeader: some View {
        VStack(spacing: 0) {
            HStack {
                Text("#").frame(width: 22, alignment: .center)
                Text("Product").frame(maxWidth: .infinity, alignment: .leading)
                Text("Sold").frame(width: 44, alignment: .trailing)
                Text("Revenue").frame(width: 72, alignment: .trailing)
                Text("★").frame(width: 34, alignment: .trailing)
            }
            .font(.caption.weight(.semibold))
            .foregroundStyle(Color.textMuted)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)

            Divider().background(Color.borderColor)
        }
        // Opaque background is required — without it, rows scroll
        // visibly behind the header as they pass underneath it.
        .background(Color.surfacePrimary)
    }
}

struct BestSellerRow: View {
    let item: ProductStatItem
    let maxUnits: Int

    // Pre-compute ratio once — not recalculated on scroll
    private var ratio: Double {
        maxUnits > 0 ? min(Double(item.unitsSold) / Double(maxUnits), 1.0) : 0
    }

    var body: some View {
        VStack(spacing: 6) {
            HStack(spacing: 8) {
                rankBadge
                productInfo
                Text("\(item.unitsSold)")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.textPrimary)
                    .frame(width: 44, alignment: .trailing)
                Text(item.revenueFormatted)
                    .font(.caption.weight(.medium))
                    .foregroundStyle(Color.textMuted)
                    .frame(width: 72, alignment: .trailing)
                ratingView
            }

            progressBar
                .padding(.leading, 30)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 16)
    }

    private var rankBadge: some View {
        ZStack {
            Circle().fill(rankColor).frame(width: 22, height: 22)
            Text("\(item.rank)")
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(item.rank <= 3 ? .white : Color.textSecondary)
        }
    }

    private var productInfo: some View {
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
    }

    private var ratingView: some View {
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

    /// Canvas-based bar: one Metal draw call instead of two Views + HStack layout.
    private var progressBar: some View {
        Canvas { ctx, size in
            let filled = size.width * ratio
            // Background track
            ctx.fill(
                Path(roundedRect: CGRect(origin: .zero, size: size), cornerRadius: 2),
                with: .color(Color.surfaceSub)
            )
            // Filled portion (only draw if non-zero to skip GPU work)
            if filled > 0 {
                ctx.fill(
                    Path(roundedRect: CGRect(x: 0, y: 0, width: filled, height: size.height),
                         cornerRadius: 2),
                    with: .color(Color.accentPrimary.opacity(0.55))
                )
            }
        }
        .frame(height: 4)
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
