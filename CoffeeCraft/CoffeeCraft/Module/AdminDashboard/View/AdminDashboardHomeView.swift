//
//  AdminDashboardHomeView.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 3/12/26.
//

import SwiftUI

// MARK: - Admin Dashboard Home View

struct AdminDashboardHomeView: View {

    @StateObject private var vm = DashboardHomeViewModel()

    var body: some View {
        CustomRefreshScrollView(onRefresh: {
            await vm.refresh()
        }) {
            VStack(alignment: .leading, spacing: 20) {

                headerSection
                revenuePeriodPicker
                kpiGrid
                liveActivitySection

            }
            .padding(.horizontal, 16)
            .padding(.bottom, 24)
        }
        .navigationTitle("Dashboard")
        .navigationBarTitleDisplayMode(.large)
        .onAppear { vm.onAppear() }
        .onDisappear { vm.onDisappear() }
        .alert("Error", isPresented: Binding(
            get: { vm.errorMessage != nil },
            set: { if !$0 { vm.errorMessage = nil } }
        )) {
            Button("Retry") { Task { await vm.loadSummary() } }
            Button("Dismiss", role: .cancel) { vm.errorMessage = nil }
        } message: {
            Text(vm.errorMessage ?? "")
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(greetingText)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text("Here's what's happening")
                .font(.title3.weight(.semibold))
        }
        .padding(.top, 8)
    }

    private var greetingText: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 0..<12:  return "Good morning ☕"
        case 12..<17: return "Good afternoon ☀️"
        default:      return "Good evening 🌙"
        }
    }

    // MARK: - Period Picker

    private var revenuePeriodPicker: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Revenue")
                .font(.headline)

            Picker("Period", selection: $vm.selectedPeriod) {
                ForEach(DashboardPeriod.allCases, id: \.self) { period in
                    Text(period.rawValue).tag(period)
                }
            }
            .pickerStyle(.segmented)

            // Revenue value
            HStack(alignment: .lastTextBaseline, spacing: 4) {
                if vm.isLoading {
                    ShimmerView()
                        .frame(width: 140, height: 40)
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                } else {
                    Text(vm.displayRevenue)
                        .font(.system(size: 38, weight: .bold, design: .rounded))
                        .foregroundStyle(.primary)
                    Text(vm.displayRevenueLabel)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .padding(.bottom, 4)
                }
            }
        }
        .padding(16)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - KPI Grid (2×2)

    private var kpiGrid: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                KPICard(
                    title: "Orders Today",
                    value: vm.isLoading ? "—" : "\(vm.summary?.orders.todayCount ?? 0)",
                    icon: "bag.fill",
                    accentColor: .blue,
                    subtitle: vm.summary?.orders.dailyChangeLabel,
                    subtitleIsPositive: vm.summary?.orders.dailyChangeIsPositive,
                    isLoading: vm.isLoading
                )

                KPICard(
                    title: "Active Now",
                    value: vm.isLoading ? "—" : "\(vm.summary?.orders.activeCount ?? 0)",
                    icon: "clock.fill",
                    accentColor: .orange,
                    isLoading: vm.isLoading
                )
            }

            HStack(spacing: 12) {
                KPICard(
                    title: "New Customers",
                    value: vm.isLoading ? "—" : "\(vm.summary?.customers.newThisWeek ?? 0)",
                    icon: "person.badge.plus.fill",
                    accentColor: .purple,
                    subtitle: "This week",
                    isLoading: vm.isLoading
                )

                KPICard(
                    title: "Total Customers",
                    value: vm.isLoading ? "—" : "\(vm.summary?.customers.totalCount ?? 0)",
                    icon: "person.2.fill",
                    accentColor: .teal,
                    isLoading: vm.isLoading
                )
            }
        }
    }

    // MARK: - Live Activity

    private var liveActivitySection: some View {
        VStack(alignment: .leading, spacing: 12) {

            // Section header
            HStack {
                Text("Live Activity")
                    .font(.headline)
                Spacer()
                LiveBadge()
            }

            if vm.isLoading {
                loadingActivityPlaceholder
            } else if vm.liveActivity.isEmpty {
                emptyActivityView
            } else {
                activityList
            }
        }
        .padding(16)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    private var activityList: some View {
        LazyVStack(spacing: 0) {
            ForEach(vm.liveActivity) { item in
                LiveActivityRow(item: item)
                if item.id != vm.liveActivity.last?.id {
                    Divider().padding(.leading, 22)
                }
            }
        }
    }

    private var loadingActivityPlaceholder: some View {
        VStack(spacing: 12) {
            ForEach(0..<5, id: \.self) { _ in
                HStack(spacing: 12) {
                    ShimmerView().frame(width: 10, height: 10).clipShape(Circle())
                    VStack(alignment: .leading, spacing: 6) {
                        ShimmerView().frame(width: 120, height: 14).clipShape(RoundedRectangle(cornerRadius: 4))
                        ShimmerView().frame(width: 80, height: 10).clipShape(RoundedRectangle(cornerRadius: 4))
                    }
                    Spacer()
                    ShimmerView().frame(width: 50, height: 14).clipShape(RoundedRectangle(cornerRadius: 4))
                }
                .padding(.vertical, 6)
            }
        }
    }

    private var emptyActivityView: some View {
        VStack(spacing: 8) {
            Image(systemName: "tray")
                .font(.largeTitle)
                .foregroundStyle(.tertiary)
            Text("No recent orders")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
    }
}
