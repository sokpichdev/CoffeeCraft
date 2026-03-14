//
//  ProductPerformanceView.swift
//  CoffeeCraft — Admin Dashboard Redesign
//

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
        .customNavigationBar("Product Performance") {
            ToolBarButton.back { dismiss() }
        }
        .onAppear { vm.onAppear() }
    }

    /// Rendered once, never re-drawn during scroll.
    private var stickyHeader: some View {
        VStack(spacing: 12) {
            CustomSegmentedControl(
                selectedSegment: $vm.selectedPeriod,
                segments: SalesPeriod.allCases,
                onClick: { Task { await vm.periodChanged() } }
            )

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
