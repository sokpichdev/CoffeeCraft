//
//  OrderAnalyticsDashboardView.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 13/03/2026.
//

import Charts
import SwiftUI

// MARK: - Order Analytics Dashboard View

struct OrderAnalyticsDashboardView: View {

    @StateObject private var vm = OrderAnalyticsViewModel()
    @State private var now = Date()

    var body: some View {
        VStack(spacing: 0) {
            sectionPicker
            contentArea
        }
        .background(Color.bgPrimary.ignoresSafeArea())
        .customNavigationBar("Order Analytics", displayMode: .large)
        .onAppear { vm.onAppear() }
        .onDisappear { vm.onDisappear() }
        .onReceive(Timer.publish(every: 30, on: .main, in: .common).autoconnect()) {
            now = $0
        }
    }

    // MARK: - Section Picker

    private var sectionPicker: some View {
        Picker("Section", selection: $vm.selectedSection) {
            ForEach(OrderAnalyticsSection.allCases) { section in
                Label(section.rawValue, systemImage: section.icon).tag(section)
            }
        }
        .pickerStyle(.segmented)
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Color.bgSecondary)
    }

    // MARK: - Content Router

    @ViewBuilder
    private var contentArea: some View {
        switch vm.selectedSection {
        case .queue:   queueSection
        case .history: historySection
        case .funnel:  funnelSection
        }
    }

    // MARK: - QUEUE ─

    private var queueSection: some View {
        CustomRefreshScrollView( {
            LazyVStack(spacing: 12) {
                if vm.queueItems.isEmpty {
                    DashboardEmptyState(
                        icon: "tray.fill",
                        title: "Queue is clear",
                        message: "No pending or preparing orders right now."
                    )
                } else {
                    // Queue header
                    HStack {
                        Text("\(vm.queueItems.count) active order\(vm.queueItems.count == 1 ? "" : "s")")
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(Color.textSecondary)
                        Spacer()
                        LiveBadge()
                    }
                    .padding(.top, 4)

                    ForEach(vm.queueItems) { item in
                        OrderQueueCard(
                            item: item,
                            now: now,
                            isUpdating: vm.isUpdatingStatus.contains(item.id),
                            onAdvance: { await vm.advanceStatus(for: item) }
                        )
                    }
                }
            }
            .padding(16)
        })
    }

    // MARK: ─ HISTORY ─

    private var historySection: some View {
        CustomRefreshScrollView({
            VStack(spacing: 0) {
                historyFilterBar
                Divider().background(Color.borderColor)

                if vm.isLoadingHistory {
                    DashboardLoadingPlaceholder(count: 2).padding(16)
                } else if vm.historyItems.isEmpty {
                    DashboardEmptyState(
                        icon: "clock.arrow.circlepath",
                        title: "No orders found",
                        message: "Try adjusting your filters."
                    )
                } else {
                    historyList
                }
            }
        })
    }

    private var historyFilterBar: some View {
        VStack(spacing: 10) {
            // Search field
            HStack(spacing: 10) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 14))
                    .foregroundStyle(Color.textMuted)
                TextField("Search by name or order ID", text: $vm.filter.searchText)
                    .autocorrectionDisabled()
                    .font(.subheadline)
                    .onSubmit { Task { await vm.applyFilter() } }
                if !vm.filter.searchText.isEmpty {
                    Button {
                        vm.filter.searchText = ""
                        Task { await vm.applyFilter() }
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(Color.textMuted)
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(Color.surfaceSub, in: RoundedRectangle(cornerRadius: 12))
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.borderColor, lineWidth: 1))

            // Status chips
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    FilterChip(label: "All", isSelected: vm.filter.status == nil,
                               color: .accentPrimary) {
                        vm.filter.status = nil
                        Task { await vm.applyFilter() }
                    }
                    ForEach(OrderStatus.allCases) { status in
                        FilterChip(label: status.rawValue, isSelected: vm.filter.status == status,
                                   color: status.color) {
                            vm.filter.status = (vm.filter.status == status) ? nil : status
                            Task { await vm.applyFilter() }
                        }
                    }
                }
            }

            // Result count + sort
            HStack {
                Text("\(vm.historyItems.count) result\(vm.historyItems.count == 1 ? "" : "s")")
                    .font(.caption)
                    .foregroundStyle(Color.textMuted)
                Spacer()
                Menu {
                    ForEach(HistorySortOrder.allCases, id: \.self) { order in
                        Button {
                            vm.filter.sortOrder = order
                            Task { await vm.applyFilter() }
                        } label: {
                            Label(order.rawValue,
                                  systemImage: vm.filter.sortOrder == order ? "checkmark" : "")
                        }
                    }
                } label: {
                    Label(vm.filter.sortOrder.rawValue, systemImage: "arrow.up.arrow.down")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color.accentPrimary)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.bgSecondary)
    }

    private var historyList: some View {
            LazyVStack(spacing: 0) {
                ForEach(vm.historyItems) { item in
                    HistoryOrderRow(item: item, now: now)
                        .padding(.horizontal, 16)
                        .onAppear {
                            if item.id == vm.historyItems.last?.id {
                                Task { await vm.loadMoreHistory() }
                            }
                        }
                    Divider().padding(.leading, 37).background(Color.borderColor)
                }

                if vm.isLoadingMoreHistory {
                    ProgressView().tint(.accentPrimary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                } else if !vm.canLoadMoreHistory && vm.historyItems.count >= 20 {
                    Text("All orders loaded")
                        .font(.caption)
                        .foregroundStyle(Color.textMuted)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                }
            }
    }

    // MARK: ─── FUNNEL ────────────────────────────────────────────────────────

    private var funnelSection: some View {
        CustomRefreshScrollView( {
            VStack(spacing: 20) {
                if vm.isLoadingFunnel {
                    DashboardLoadingPlaceholder(count: 2)
                } else {
                    funnelStatCards
                    funnelBarChart
                    funnelFulfillmentCard
                }
            }
            .padding(16)
        })
    }

    private var funnelStatCards: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                StatCard(
                    title: "Completion Rate",
                    value: vm.funnelData.completionRateFormatted,
                    icon: "checkmark.seal.fill",
                    color: completionColor,
                    tintBackground: true
                )
                StatCard(
                    title: "Cancellation Rate",
                    value: vm.funnelData.cancellationRateFormatted,
                    icon: "xmark.seal.fill",
                    color: cancellationColor,
                    tintBackground: true
                )
            }
            HStack(spacing: 12) {
                StatCard(
                    title: "Total Orders",
                    value: "\(vm.funnelData.totalOrders)",
                    icon: "bag.fill",
                    color: .accentPrimary
                )
                StatCard(
                    title: "Avg Fulfillment",
                    value: vm.funnelData.avgFulfillmentFormatted,
                    icon: "timer",
                    color: .accentGold
                )
            }
        }
    }

    private var funnelBarChart: some View {
        ChartCard(title: "Order Breakdown", subtitle: "Last 30 days") {
            let data: [(String, Int, Color)] = [
                ("Completed", vm.funnelData.completedCount, .semanticSuccess),
                ("Active", vm.funnelData.activeCount, .accentPrimary),
                ("Cancelled", vm.funnelData.cancelledCount, .semanticError)
            ]

            Chart(data, id: \.0) { label, count, color in
                BarMark(
                    x: .value("Count", count),
                    y: .value("Status", label)
                )
                .foregroundStyle(color)
                .cornerRadius(6)
                .annotation(position: .trailing, alignment: .leading) {
                    Text("\(count)")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color.textSecondary)
                        .padding(.leading, 4)
                }
            }
            .chartXAxis(.hidden)
            .frame(height: 140)
        }
    }

    private var funnelFulfillmentCard: some View {
        ChartCard(title: "Avg Fulfillment Time",
                  subtitle: "Only orders with completedAt field") {
            HStack(spacing: 20) {
                ZStack {
                    Circle()
                        .fill(Color.accentGold.opacity(0.10))
                        .frame(width: 60, height: 60)
                    Image(systemName: "timer")
                        .font(.system(size: 26))
                        .foregroundStyle(Color.accentGold.opacity(0.80))
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(vm.funnelData.avgFulfillmentFormatted)
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.textPrimary)
                    Text(vm.funnelData.avgFulfillmentMinutes == nil
                         ? "Add completedAt to orders to enable this metric"
                         : "from order placed to Ready")
                        .font(.caption)
                        .foregroundStyle(Color.textMuted)
                }
            }
            .padding(.vertical, 8)
        }
    }

    // MARK: - Colour Helpers

    private var completionColor: Color {
        vm.funnelData.completionRate >= 80 ? .semanticSuccess :
        vm.funnelData.completionRate >= 50 ? .orange : .semanticError
    }

    private var cancellationColor: Color {
        vm.funnelData.cancellationRate < 5 ? .semanticSuccess :
        vm.funnelData.cancellationRate < 15 ? .orange : .semanticError
    }
}

// MARK: - Filter Chip

private struct FilterChip: View {
    let label: String
    let isSelected: Bool
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.caption.weight(.semibold))
                .foregroundStyle(isSelected ? .white : color)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? color : color.opacity(0.10), in: Capsule())
                .overlay(Capsule().stroke(color.opacity(isSelected ? 0 : 0.25), lineWidth: 1))
        }
        .buttonStyle(.plain)
    }
}
