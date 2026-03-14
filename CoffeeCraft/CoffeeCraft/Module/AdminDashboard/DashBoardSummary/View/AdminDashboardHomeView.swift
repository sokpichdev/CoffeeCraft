//
//  AdminDashboardHomeView.swift
//  CoffeeCraft
//

import SwiftUI

// MARK: - Admin Dashboard Home View

struct AdminDashboardHomeView: View {

    @StateObject private var vm = DashboardHomeViewModel()
    @State private var now = Date()

    var body: some View {
        CustomRefreshScrollView({
            VStack(alignment: .leading, spacing: 20) {
                headerSection
                revenueCard
                kpiGrid
                quickLinksSection
                liveActivitySection
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 32)
        }, onRefresh: {
            await vm.refresh()
        })
        .background(Color.bgPrimary.ignoresSafeArea())
        .customNavigationBar("Dashboard", displayMode: .large)
        .onAppear { vm.onAppear() }
        .onDisappear { vm.onDisappear() }
        .onReceive(Timer.publish(every: 30, on: .main, in: .common).autoconnect()) { tick in
            now = tick
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 3) {
                Text(greetingText)
                    .font(.subheadline)
                    .foregroundStyle(Color.textSecondary)
                Text("Here's what's brewing")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(Color.textPrimary)
            }
            Spacer()
            ZStack {
                Circle()
                    .fill(LinearGradient.brandPrimary)
                    .frame(width: 44, height: 44)
                Image(systemName: "cup.and.saucer.fill")
                    .font(.system(size: 18))
                    .foregroundStyle(.white)
            }
            .shadow(color: Color.accentPrimary.opacity(0.35), radius: 7, x: 0, y: 3)
        }
        .padding(.top, 6)
    }

    // MARK: - Revenue Card

    private var revenueCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            CustomSegmentedControl(selectedSegment: $vm.selectedPeriod, segments: [.today, .week, .month], onClick: {})

            // Revenue label + amount
            HStack(alignment: .lastTextBaseline, spacing: 4) {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Color.accentGold)
                Text("Revenue")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color.textSecondary)
                    .tracking(0.4)
            }
            .padding(.bottom, 6)

            if vm.isLoading {
                ShimmerView()
                    .frame(width: 160, height: 46)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .padding(.bottom, 16)
            } else {
                HStack(alignment: .lastTextBaseline, spacing: 6) {
                    Text(vm.displayRevenue)
                        .font(.system(size: 42, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.textPrimary)
                    Text(vm.displayRevenueLabel)
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(Color.textMuted)
                        .padding(.bottom, 5)
                }
                .padding(.bottom, 16)
            }

            // Mini stats row
            if !vm.isLoading, let summary = vm.summary {
                Divider().background(Color.borderColor)

                HStack(spacing: 0) {
                    miniStat(label: "Today", value: summary.revenue.todayFormatted, color: .accentPrimary)
                    revenueStatDivider
                    miniStat(label: "Week", value: summary.revenue.thisWeekFormatted, color: .accentPrimary)
                    revenueStatDivider
                    miniStat(label: "Month", value: summary.revenue.thisMonthFormatted, color: .accentGold)
                }
                .padding(.top, 12)
            }
        }
        .padding(18)
        .background(Color.surfacePrimary)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        // Gold accent top border
        .overlay(alignment: .top) {
            RoundedRectangle(cornerRadius: 3)
                .fill(LinearGradient.brandGold)
                .frame(height: 3)
                .padding(.horizontal, 20)
                .padding(.top, 0)
        }
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.borderColor, lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.06), radius: 12, x: 0, y: 4)
    }

    private var revenueStatDivider: some View {
        Divider()
            .frame(height: 28)
            .background(Color.borderColor)
    }

    private func miniStat(label: String, value: String, color: Color) -> some View {
        VStack(spacing: 3) {
            Text(value)
                .font(.caption.bold())
                .foregroundStyle(color)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text(label)
                .font(.system(size: 10))
                .foregroundStyle(Color.textMuted)
                .tracking(0.3)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - KPI Grid

    private var kpiGrid: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                KPICard(
                    title: "Orders Today",
                    value: vm.isLoading ? "—" : "\(vm.summary?.orders.todayCount ?? 0)",
                    icon: "bag.fill",
                    accentColor: .accentPrimary,
                    subtitle: vm.summary?.orders.dailyChangeLabel,
                    subtitleIsPositive: vm.summary?.orders.dailyChangeIsPositive,
                    isLoading: vm.isLoading
                )
                KPICard(
                    title: "Active Now",
                    value: vm.isLoading ? "—" : "\(vm.summary?.orders.activeCount ?? 0)",
                    icon: "flame.fill",
                    accentColor: .orange,
                    isLoading: vm.isLoading
                )
            }
            HStack(spacing: 12) {
                KPICard(
                    title: "New Members",
                    value: vm.isLoading ? "—" : "\(vm.summary?.customers.newThisWeek ?? 0)",
                    icon: "person.badge.plus.fill",
                    accentColor: .accentGold,
                    subtitle: "This week",
                    isLoading: vm.isLoading
                )
                KPICard(
                    title: "Total Members",
                    value: vm.isLoading ? "—" : "\(vm.summary?.customers.totalCount ?? 0)",
                    icon: "person.2.fill",
                    accentColor: .accentPrimary,
                    isLoading: vm.isLoading
                )
            }
        }
    }

    private var quickLinksSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionHeaderLabel(icon: "square.grid.2x2.fill", title: "Quick Navigation")

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())],
                      spacing: 12) {
                // Sales
                quickNavCell(
                    title: "Sales",
                    subtitle: "Trends",
                    icon: "chart.xyaxis.line",
                    color: .accentPrimary,
                    destination: AnyView(SalesAnalyticsView())
                )
                // Products
                quickNavCell(
                    title: "Products",
                    subtitle: "Top sellers",
                    icon: "trophy.fill",
                    color: .accentGold,
                    destination: AnyView(ProductPerformanceView())
                )
                // Orders
                quickNavCell(
                    title: "Orders",
                    subtitle: "Queue",
                    icon: "bag.fill",
                    color: .orange,
                    destination: AnyView(OrderAnalyticsDashboardView())
                )
                // Users
                quickNavCell(
                    title: "Users",
                    subtitle: "Accounts",
                    icon: "person.2.fill",
                    color: .blue,
                    destination: AnyView(UserManagementView())
                )
                // Reviews
                quickNavCell(
                    title: "Reviews",
                    subtitle: "Moderate",
                    icon: "bubble.left.and.bubble.right.fill",
                    color: Color.semanticSuccess,
                    destination: AnyView(ReviewModerationDashboardView())
                )
            }
        }
    }

    private func quickNavCell(title: String, subtitle: String, icon: String,
                              color: Color, destination: AnyView) -> some View {
        NavigationLink(destination: destination) {
            VStack(spacing: 8) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(color.opacity(0.12))
                        .frame(width: 44, height: 44)
                    Image(systemName: icon)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(color)
                }
                Text(title)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color.textPrimary)
                Text(subtitle)
                    .font(.system(size: 9))
                    .foregroundStyle(Color.textMuted)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(Color.surfacePrimary)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(color.opacity(0.18), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 2)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Live Activity Section

    private var liveActivitySection: some View {
        VStack(alignment: .leading, spacing: 14) {

            HStack {
                SectionHeaderLabel(icon: "waveform.path.ecg", title: "Live Activity")
                Spacer()
                LiveBadge()
            }

            if vm.isLoading {
                loadingPlaceholder
            } else if vm.allActivity.isEmpty {
                emptyActivityView
            } else {
                activityList
            }
        }
        .padding(16)
        .background(Color.surfacePrimary)
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(Color.borderColor, lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 4)
    }

    // MARK: - Activity List (paginated)

    private var activityList: some View {
        LazyVStack(spacing: 0) {
            ForEach(vm.allActivity) { item in
                LiveActivityRow(item: item, now: now)
                    .onAppear {
                        if item.id == vm.allActivity.last?.id {
                            Task { await vm.loadMoreActivity() }
                        }
                    }
                if item.id != vm.allActivity.last?.id {
                    Divider()
                        .background(Color.borderColor)
                        .padding(.leading, 56)
                }
            }
            paginationFooter
        }
    }
}

extension AdminDashboardHomeView {

    @ViewBuilder
    private var paginationFooter: some View {
        if vm.isLoadingMore {
            HStack {
                Spacer()
                VStack(spacing: 6) {
                    ProgressView().tint(.accentPrimary)
                    Text("Loading more orders…")
                        .font(.caption2)
                        .foregroundStyle(Color.textMuted)
                }
                .padding(.vertical, 16)
                Spacer()
            }
        } else if !vm.hasMorePages && vm.allActivity.count > 10 {
            HStack(spacing: 6) {
                Image(systemName: "checkmark.seal.fill")
                    .font(.caption)
                    .foregroundStyle(Color.accentPrimary.opacity(0.6))
                Text("All orders loaded")
                    .font(.caption)
                    .foregroundStyle(Color.textMuted)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
        }
    }

    // MARK: - Loading Skeleton

    private var loadingPlaceholder: some View {
        VStack(spacing: 14) {
            ForEach(0..<5, id: \.self) { _ in
                HStack(spacing: 14) {
                    ShimmerView()
                        .frame(width: 42, height: 42)
                        .clipShape(Circle())
                    VStack(alignment: .leading, spacing: 6) {
                        ShimmerView().frame(width: 110, height: 14).clipShape(RoundedRectangle(cornerRadius: 4))
                        ShimmerView().frame(width: 80, height: 10).clipShape(RoundedRectangle(cornerRadius: 4))
                    }
                    Spacer()
                    VStack(alignment: .trailing, spacing: 6) {
                        ShimmerView().frame(width: 52, height: 14).clipShape(RoundedRectangle(cornerRadius: 4))
                        ShimmerView().frame(width: 58, height: 18).clipShape(Capsule())
                    }
                }
                .padding(.vertical, 4)
            }
        }
    }

    // MARK: - Empty State

    private var emptyActivityView: some View {
        VStack(spacing: 10) {
            Image(systemName: "cup.and.saucer")
                .font(.system(size: 40))
                .foregroundStyle(Color.accentPrimary.opacity(0.35))
            Text("No orders yet today")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(Color.textSecondary)
            Text("Orders will appear here in real time")
                .font(.caption)
                .foregroundStyle(Color.textMuted)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
    }
}
