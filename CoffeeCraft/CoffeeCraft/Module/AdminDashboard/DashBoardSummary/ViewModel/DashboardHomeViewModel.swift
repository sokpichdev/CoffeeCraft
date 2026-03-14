//
//  DashboardHomeViewModel.swift
//  CoffeeCraft
//
//  Pagination fix — root cause of "sometimes works":
//
//  Before: loadSummary() seeded liveItems from summary.liveActivity but
//          NEVER set lastDocument. So loadMoreActivity()'s first call used
//          cursor = nil → fetched the same top-10 → all deduped → zero items
//          added → cursor finally set, but the .onAppear trigger on the last
//          row was already consumed and never fires again.
//
//  Fix:    loadSummary() calls fetchFirstActivityPage() in parallel with the
//          KPI summary fetch. This returns an ActivityPage which includes the
//          DocumentSnapshot cursor, so lastDocument is set BEFORE the first
//          scroll event — identical to how OrderViewModel.fetchOrders() works.
//
//  Strategy (mirrors OrderViewModel / AdminOrdersViewModel exactly):
//  ┌──────────────────────────────────────────────────────────────────┐
//  │  loadSummary()      → KPIs + page 1 in parallel                 │
//  │                       sets lastDocument from page-1 cursor ✓    │
//  │  loadMoreActivity() → cursor-based page 2, 3… dedupes vs live   │
//  │  refresh()          → full reset + re-fetch                     │
//  │  liveListener       → growing-window; re-attaches after page    │
//  └──────────────────────────────────────────────────────────────────┘

import FirebaseFirestore
import Foundation

@MainActor
final class DashboardHomeViewModel: ObservableObject {

    // MARK: - Published State

    @Published var summary: DashboardSummary?
    @Published var selectedPeriod: Segment = .today
    @Published var isLoading: Bool = false
    @Published var isLoadingMore: Bool = false
    @Published var hasMorePages: Bool = true

    /// Top-10 from the real-time listener (always newest).
    @Published private(set) var liveItems: [LiveOrderItem] = []
    /// Cursor-paginated older history (page 2+).
    @Published private(set) var historicalItems: [LiveOrderItem] = []

    /// Unified feed: live top-10 + deduplicated older pages.
    var allActivity: [LiveOrderItem] {
        let liveIds = Set(liveItems.map(\.id))
        let older   = historicalItems.filter { !liveIds.contains($0.id) }
        return liveItems + older
    }

    // MARK: - Private

    private let service = AnalyticsService.shared
    private let pageSize = 10
    private var liveListener: ListenerRegistration?

    /// Firestore cursor pointing at the last document fetched.
    /// Set during loadSummary() (page 1), advanced on every loadMoreActivity().
    private var lastDocument: DocumentSnapshot?

    // MARK: - Computed

    var displayRevenue: String {
        guard let summary else { return "$0.00" }
        switch selectedPeriod {
        case .today: return summary.revenue.todayFormatted
        case .week: return summary.revenue.thisWeekFormatted
        case .month: return summary.revenue.thisMonthFormatted
        default: return ""
        }
    }
    var displayRevenueLabel: String { selectedPeriod.rawValue }

    // MARK: - Lifecycle

    func onAppear() {
        guard summary == nil else { return }   // skip re-fetch on tab switch
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
        historicalItems = []
        lastDocument = nil
        hasMorePages = true

        do {
            // Run KPI summary AND page-1 activity fetch in parallel.
            // fetchFirstActivityPage() returns ActivityPage which includes the
            // DocumentSnapshot cursor — this is the critical fix.
            async let summaryResult = service.fetchDashboardSummary()
            async let firstPage = service.fetchFirstActivityPage(pageSize: pageSize)

            let (fetchedSummary, page) = try await (summaryResult, firstPage)

            summary      = fetchedSummary
            liveItems    = page.items         // seed the visible feed
            lastDocument = page.lastDocument  // ← cursor set on load, not on first scroll
            hasMorePages = page.hasMore

            AppLog.dashboard.debug("✅ loadSummary — items: \(page.items.count), hasMore: \(page.hasMore), cursor: \(page.lastDocument?.documentID ?? "nil")")
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

    // MARK: - Infinite Scroll (mirrors OrderViewModel.loadMore exactly)

    /// Triggered when the last visible row calls `.onAppear`.
    /// `lastDocument` is guaranteed non-nil after loadSummary() succeeds,
    /// so the guard will always pass on the first real scroll event.
    func loadMoreActivity() async {
        guard !isLoadingMore, hasMorePages, let cursor = lastDocument else { return }

        AppLog.dashboard.debug("📋 loadMoreActivity — cursor: \(cursor.documentID), loaded: \(self.allActivity.count)")
        isLoadingMore = true

        do {
            let page = try await service.fetchMoreActivity(after: cursor, pageSize: pageSize)

            // Deduplicate against the full current feed
            let existingIds = Set(allActivity.map(\.id))
            let newItems    = page.items.filter { !existingIds.contains($0.id) }

            historicalItems.append(contentsOf: newItems)
            lastDocument = page.lastDocument
            hasMorePages = page.hasMore

            AppLog.dashboard.debug("✅ loadMoreActivity — added \(newItems.count), total: \(self.allActivity.count), hasMore: \(page.hasMore)")

            // Grow the listener window to cover all loaded orders
            reattachLiveListener()
        } catch {
            AppLog.dashboard.error("❌ loadMoreActivity: \(error.localizedDescription)")
        }

        isLoadingMore = false
    }

    // MARK: - Live Listener (growing-window, mirrors AdminOrdersViewModel)

    private func attachLiveListener() {
        liveListener?.remove()
        let limit = max(allActivity.count, pageSize)
        AppLog.dashboard.debug("🔌 attachLiveListener — limit: \(limit)")

        liveListener = service.listenToLiveActivity(limit: limit) { [weak self] items in
            Task { @MainActor [weak self] in
                self?.liveItems = items
            }
        }
    }

    private func reattachLiveListener() {
        attachLiveListener()
    }
}
