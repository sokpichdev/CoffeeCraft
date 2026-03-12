//
//  AdminDashboardHomeView.swift
//  CoffeeCraft
//

import SwiftUI

// MARK: - Admin Dashboard Home View

struct AdminDashboardHomeView: View {

    @StateObject private var vm = DashboardHomeViewModel()

    /// 30-second tick — shared with all LiveActivityRow instances so relative
    /// timestamps update simultaneously (same pattern as before).
    @State private var now = Date()

    var body: some View {
        CustomRefreshScrollView({
            VStack(alignment: .leading, spacing: 20) {

                headerSection
                revenuePeriodPicker
                kpiGrid
                liveActivitySection

            }
            .padding(.horizontal, 16)
            .padding(.bottom, 32)
        }, onRefresh: {
            await vm.refresh()
        })
        .background(Color.bgPrimary.ignoresSafeArea())
        .navigationTitle("Dashboard")
        .navigationBarTitleDisplayMode(.large)
        .onAppear  { vm.onAppear() }
        .onDisappear { vm.onDisappear() }
        .onReceive(Timer.publish(every: 30, on: .main, in: .common).autoconnect()) { tick in
            now = tick
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 2) {
                Text(greetingText)
                    .font(.subheadline)
                    .foregroundColor(.textSecondary)
                Text("Here's what's brewing")
                    .font(.title3.weight(.semibold))
                    .foregroundColor(.textPrimary)
            }
            Spacer()
            // Coffee cup icon badge
            ZStack {
                Circle()
                    .fill(LinearGradient.brandPrimary)
                    .frame(width: 42, height: 42)
                Image(systemName: "cup.and.saucer.fill")
                    .font(.system(size: 18))
                    .foregroundStyle(.white)
            }
            .shadow(color: Color.accentPrimary.opacity(0.35), radius: 6, x: 0, y: 3)
        }
        .padding(.top, 6)
    }

    private var greetingText: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 0..<12:  return "Good morning ☕"
        case 12..<17: return "Good afternoon ☀️"
        default:      return "Good evening 🌙"
        }
    }

    // MARK: - Period Picker + Revenue Card

    private var revenuePeriodPicker: some View {
        VStack(alignment: .leading, spacing: 12) {

            // Title row
            HStack {
                Label("Revenue", systemImage: "chart.line.uptrend.xyaxis")
                    .font(.headline.weight(.semibold))
                    .foregroundColor(.textPrimary)
                Spacer()
            }

            // Segmented picker
            Picker("Period", selection: $vm.selectedPeriod) {
                ForEach(DashboardPeriod.allCases, id: \.self) { period in
                    Text(period.rawValue).tag(period)
                }
            }
            .pickerStyle(.segmented)

            // Revenue amount
            HStack(alignment: .lastTextBaseline, spacing: 6) {
                if vm.isLoading {
                    ShimmerView()
                        .frame(width: 150, height: 44)
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                } else {
                    Text(vm.displayRevenue)
                        .font(.system(size: 40, weight: .bold, design: .rounded))
                        .foregroundColor(.textPrimary)
                    Text(vm.displayRevenueLabel)
                        .font(.subheadline.weight(.medium))
                        .foregroundColor(.textMuted)
                        .padding(.bottom, 5)
                }
            }

            // Mini stats row
            if !vm.isLoading, let summary = vm.summary {
                Divider()
                    .background(Color.borderColor)

                HStack(spacing: 0) {
                    miniStat(
                        label: "Today",
                        value: summary.revenue.todayFormatted,
                        color: .accentPrimary
                    )
                    Divider()
                        .frame(height: 28)
                        .background(Color.borderColor)
                    miniStat(
                        label: "Week",
                        value: summary.revenue.thisWeekFormatted,
                        color: .accentPrimary
                    )
                    Divider()
                        .frame(height: 28)
                        .background(Color.borderColor)
                    miniStat(
                        label: "Month",
                        value: summary.revenue.thisMonthFormatted,
                        color: .accentPrimary
                    )
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color.surfacePrimary)
                .shadow(color: Color.black.opacity(0.06), radius: 10, x: 0, y: 4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(Color.borderColor, lineWidth: 1)
        )
    }

    private func miniStat(label: String, value: String, color: Color) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.caption.bold())
                .foregroundStyle(color)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text(label)
                .font(.system(size: 10))
                .foregroundColor(.textMuted)
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
                    accentColor: .accentPrimary,
                    isLoading: vm.isLoading
                )
            }
            HStack(spacing: 12) {
                KPICard(
                    title: "New Members",
                    value: vm.isLoading ? "—" : "\(vm.summary?.customers.newThisWeek ?? 0)",
                    icon: "person.badge.plus.fill",
                    accentColor: .accentPrimary,
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

    // MARK: - Live Activity Section

    private var liveActivitySection: some View {
        VStack(alignment: .leading, spacing: 14) {

            // Header
            HStack {
                Label("Live Activity", systemImage: "waveform.path.ecg")
                    .font(.headline.weight(.semibold))
                    .foregroundColor(.textPrimary)
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
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color.surfacePrimary)
                .shadow(color: Color.black.opacity(0.06), radius: 10, x: 0, y: 4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(Color.borderColor, lineWidth: 1)
        )
    }

    // MARK: - Activity List (paginated)

    private var activityList: some View {
        LazyVStack(spacing: 0) {
            ForEach(vm.allActivity) { item in
                LiveActivityRow(item: item, now: now)
                    .onAppear {
                        // Trigger next page when the last visible row appears
                        // — identical trigger pattern to OrderViewModel's loadMore
                        if item.id == vm.allActivity.last?.id {
                            Task { await vm.loadMoreActivity() }
                        }
                    }

                if item.id != vm.allActivity.last?.id {
                    Divider()
                        .background(Color.borderColor)
                        .padding(.leading, 54)
                }
            }

            // Pagination footer
            paginationFooter
        }
    }

    @ViewBuilder
    private var paginationFooter: some View {
        if vm.isLoadingMore {
            HStack {
                Spacer()
                VStack(spacing: 6) {
                    ProgressView()
                        .tint(.accentPrimary)
                    Text("Loading more orders…")
                        .font(.caption2)
                        .foregroundColor(.textMuted)
                }
                .padding(.vertical, 16)
                Spacer()
            }
        } else if !vm.hasMorePages && vm.allActivity.count > 10 {
            HStack(spacing: 6) {
                Image(systemName: "checkmark.seal.fill")
                    .font(.caption)
                    .foregroundColor(.accentPrimary.opacity(0.6))
                Text("All orders loaded")
                    .font(.caption)
                    .foregroundColor(.textMuted)
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
                        .frame(width: 40, height: 40)
                        .clipShape(Circle())
                    VStack(alignment: .leading, spacing: 6) {
                        ShimmerView()
                            .frame(width: 110, height: 14)
                            .clipShape(RoundedRectangle(cornerRadius: 4))
                        ShimmerView()
                            .frame(width: 80, height: 10)
                            .clipShape(RoundedRectangle(cornerRadius: 4))
                    }
                    Spacer()
                    VStack(alignment: .trailing, spacing: 6) {
                        ShimmerView()
                            .frame(width: 52, height: 14)
                            .clipShape(RoundedRectangle(cornerRadius: 4))
                        ShimmerView()
                            .frame(width: 58, height: 18)
                            .clipShape(Capsule())
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
                .foregroundStyle(Color.accentPrimary.opacity(0.4))
            Text("No orders yet today")
                .font(.subheadline.weight(.medium))
                .foregroundColor(.textSecondary)
            Text("Orders will appear here in real time")
                .font(.caption)
                .foregroundColor(.textMuted)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
    }
}
