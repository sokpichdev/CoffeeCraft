//
//  DashboardHomeViewModel.swift
//  CoffeeCraft
//
//  Pagination aligned with OrderViewModel / AdminOrdersViewModel pattern:
//  ┌──────────────────────────────────────────────────────────────────┐
//  │  loadSummary()     → seeds liveItems (top-10) + resets cursor   │
//  │  loadMoreActivity()→ cursor-based next page, dedupes vs live    │
//  │  refresh()         → full reset + re-fetch                      │
//  │  attachLiveListener→ real-time top-10; grows window on load     │
//  └──────────────────────────────────────────────────────────────────┘

import Foundation
import FirebaseFirestore

@MainActor
final class DashboardHomeViewModel: ObservableObject {

    // MARK: - Published State

    @Published var summary: DashboardSummary?
    @Published var selectedPeriod: DashboardPeriod = .today
    @Published var isLoading: Bool = false
    @Published var isLoadingMore: Bool = false
    @Published var hasMorePages: Bool = true          // mirrors OrderViewModel naming

    /// Live top-10 from the real-time listener.
    @Published private(set) var liveItems: [LiveOrderItem] = []
    /// Cursor-paginated history (page 2+).
    @Published private(set) var historicalItems: [LiveOrderItem] = []

    /// Unified feed: live top-10 + deduplicated older pages, newest first.
    var allActivity: [LiveOrderItem] {
        let liveIds = Set(liveItems.map(\.id))
        let olderOnly = historicalItems.filter { !liveIds.contains($0.id) }
        return liveItems + olderOnly
    }

    // MARK: - Private

    private let service     = AnalyticsService.shared
    private let pageSize    = 10
    private var liveListener: ListenerRegistration?

    /// Cursor for the next history page — nil means "start from beginning".
    private var lastDocument: DocumentSnapshot?

    // MARK: - Computed — Revenue for selected period

    var displayRevenue: String {
        guard let summary else { return "$0.00" }
        switch selectedPeriod {
        case .today:  return summary.revenue.todayFormatted
        case .week:   return summary.revenue.thisWeekFormatted
        case .month:  return summary.revenue.thisMonthFormatted
        }
    }

    var displayRevenueLabel: String { selectedPeriod.rawValue }

    // MARK: - Lifecycle

    func onAppear() {
        // Guard against re-fetching on tab-switch (mirrors OrderViewModel)
        guard summary == nil else { return }
        Task { await loadSummary() }
        attachLiveListener()
    }

    func onDisappear() {
        liveListener?.remove()
        liveListener = nil
    }

    // MARK: - Initial Load

    func loadSummary() async {
        isLoading = true
        // Full reset — mirrors refreshOrders() in OrderViewModel
        historicalItems  = []
        lastDocument     = nil
        hasMorePages     = true

        do {
            summary  = try await service.fetchDashboardSummary()
            liveItems = summary?.liveActivity ?? []

            AppLog.dashboard.debug("✅ loadSummary — live items: \(self.liveItems.count)")
        } catch {
            AlertManager.shared.showConfirmation(
                title: "Failed to load dashboard",
                message: error.localizedDescription,
                type: .error,
                confirmTitle: "Retry",
                cancelTitle: "Dismiss",
                onConfirm: { Task { await self.loadSummary() } }
            )
            AppLog.dashboard.error("❌ loadSummary: \(error.localizedDescription)")
        }

        isLoading = false
    }

    func refresh() async {
        liveListener?.remove()
        liveListener = nil
        await loadSummary()
        attachLiveListener()
    }

    // MARK: - Infinite-Scroll Pagination (mirrors loadMore in OrderViewModel)

    /// Called when the last visible row triggers `.onAppear`.
    /// Fetches the next page using the stored Firestore cursor.
    func loadMoreActivity() async {
        guard !isLoadingMore, hasMorePages else { return }
        // If no cursor yet we haven't finished the initial load — skip
        guard lastDocument != nil || liveItems.isEmpty == false else { return }

        AppLog.dashboard.debug("📋 loadMoreActivity — cursor: \(self.lastDocument?.documentID ?? "none")")
        isLoadingMore = true

        do {
            let page = try await service.fetchMoreActivity(
                after: lastDocument,
                pageSize: pageSize
            )

            // Deduplicate against liveItems (same pattern as AdminOrdersViewModel)
            let liveIds = Set(liveItems.map(\.id))
            let existingHistoricalIds = Set(historicalItems.map(\.id))
            let newItems = page.items.filter {
                !liveIds.contains($0.id) && !existingHistoricalIds.contains($0.id)
            }

            historicalItems.append(contentsOf: newItems)
            lastDocument = page.lastDocument
            hasMorePages = page.hasMore

            AppLog.dashboard.debug("✅ loadMoreActivity — appended \(newItems.count), total historical: \(self.historicalItems.count), hasMore: \(page.hasMore)")

            // Re-attach live listener so its window grows to cover all loaded items
            // (same growing-window pattern as AdminOrdersViewModel.setupAllOrdersListener)
            reattachLiveListener()

        } catch {
            AppLog.dashboard.error("❌ loadMoreActivity: \(error.localizedDescription)")
        }

        isLoadingMore = false
    }

    // MARK: - Live Listener (growing-window, mirrors AdminOrdersViewModel)

    private func attachLiveListener() {
        liveListener?.remove()
        let listenLimit = max(allActivity.count, pageSize)
        AppLog.dashboard.debug("🔌 attachLiveListener — limit: \(listenLimit)")

        liveListener = service.listenToLiveActivity(limit: listenLimit) { [weak self] items in
            Task { @MainActor [weak self] in
                self?.liveItems = items
            }
        }
    }

    /// Re-attaches with updated limit after each page load.
    private func reattachLiveListener() {
        attachLiveListener()
    }
}
