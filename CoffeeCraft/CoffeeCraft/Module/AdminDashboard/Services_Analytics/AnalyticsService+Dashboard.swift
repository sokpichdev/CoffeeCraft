//
//  AnalyticsService+Dashboard.swift
//  CoffeeCraft
//
//  Dashboard analytics — drop-in replacement for the extension section.
//  Changes vs original:
//    • listenToLiveActivity now accepts a `limit` param so the view-model
//      can grow the listener window as pages load (mirrors AdminOrdersViewModel).
//    • fetchMoreActivity pageSize param kept for clarity.
//

import FirebaseFirestore
import Foundation

// MARK: - Pagination Model

struct ActivityPage {
    let items: [LiveOrderItem]
    let lastDocument: DocumentSnapshot?
    let hasMore: Bool
}

// MARK: - Analytics Service — Dashboard

extension AnalyticsService {

    // MARK: - Dashboard Summary

    /// Fetches KPI stats only. Live activity is fetched separately in the
    /// view-model via `fetchFirstActivityPage()` so the Firestore cursor
    /// (lastDocument) is captured on the initial load — identical to how
    /// OrderViewModel.fetchOrders() sets `lastDocument` on page 1.
    func fetchDashboardSummary() async throws -> DashboardSummary {
        async let revenue = fetchRevenueSummary()
        async let orders = fetchOrderSummary()
        async let customers = fetchCustomerSummary()

        return try await DashboardSummary(
            revenue: revenue,
            orders: orders,
            customers: customers
        )
    }

    // MARK: - Revenue

    private func fetchRevenueSummary() async throws -> RevenueSummary {
        let now = Date()
        let todayStart = Calendar.current.startOfDay(for: now)
        let weekStart = Calendar.current.date(byAdding: .day, value: -6, to: todayStart)!
        let monthStart = Calendar.current.date(byAdding: .day, value: -29, to: todayStart)!

        async let todayRevenue = revenueInRange(from: todayStart, to: now)
        async let weekRevenue = revenueInRange(from: weekStart, to: now)
        async let monthRevenue = revenueInRange(from: monthStart, to: now)

        return try await RevenueSummary(
            today: todayRevenue,
            thisWeek: weekRevenue,
            thisMonth: monthRevenue
        )
    }

    private func revenueInRange(from start: Date, to end: Date) async throws -> Double {
        let snapshot = try await db.collection("orders")
            .whereField("status", isEqualTo: OrderStatus.completed.rawValue)
            .whereField("timestamp", isGreaterThanOrEqualTo: Timestamp(date: start))
            .whereField("timestamp", isLessThanOrEqualTo: Timestamp(date: end))
            .getDocuments()

        return snapshot.documents.reduce(0.0) { sum, doc in
            sum + (doc.data()["totalPrice"] as? Double ?? 0)
        }
    }

    // MARK: - Orders

    private func fetchOrderSummary() async throws -> OrderSummary {
        let now = Date()
        let todayStart = Calendar.current.startOfDay(for: now)
        let yesterdayStart = Calendar.current.date(byAdding: .day, value: -1, to: todayStart)!

        async let todaySnap = db.collection("orders")
            .whereField("timestamp", isGreaterThanOrEqualTo: Timestamp(date: todayStart))
            .getDocuments()

        async let yesterdaySnap = db.collection("orders")
            .whereField("timestamp", isGreaterThanOrEqualTo: Timestamp(date: yesterdayStart))
            .whereField("timestamp", isLessThan: Timestamp(date: todayStart))
            .getDocuments()

        async let activeSnap = db.collection("orders")
            .whereField("status", in: OrderStatus.activeRawValues)
            .getDocuments()

        let (today, yesterday, active) = try await (todaySnap, yesterdaySnap, activeSnap)

        return OrderSummary(
            todayCount: today.documents.count,
            yesterdayCount: yesterday.documents.count,
            activeCount: active.documents.count
        )
    }

    // MARK: - Customers

    private func fetchCustomerSummary() async throws -> CustomerSummary {
        let weekStart = Calendar.current.date(byAdding: .day, value: -6, to: Date())!

        async let newSnap = db.collection("users")
            .whereField("role", isEqualTo: "customer")
            .whereField("createdAt", isGreaterThanOrEqualTo: Timestamp(date: weekStart))
            .getDocuments()

        async let totalSnap = db.collection("users")
            .whereField("role", isEqualTo: "customer")
            .getDocuments()

        let (newUsers, totalUsers) = try await (newSnap, totalSnap)

        return CustomerSummary(
            newThisWeek: newUsers.documents.count,
            totalCount: totalUsers.documents.count
        )
    }

    // MARK: - Live Activity Feed

    /// Page-1 fetch that also captures the Firestore cursor, so the VM can
    /// immediately do `fetchMoreActivity(after: lastDocument)` on scroll.
    /// Mirrors OrderViewModel.fetchOrders() which sets lastDocument on page 1.
    func fetchFirstActivityPage(pageSize: Int = 10) async throws -> ActivityPage {
        return try await fetchMoreActivity(after: nil, pageSize: pageSize)
    }

    /// Cursor-based next page. Always pass a non-nil cursor obtained from
    /// a previous page's `lastDocument`. Use fetchFirstActivityPage() for
    /// the very first load.
    func fetchMoreActivity(after cursor: DocumentSnapshot?, pageSize: Int = 10) async throws -> ActivityPage {
        var query: Query = db.collection("orders")
            .order(by: "timestamp", descending: true)
            .limit(to: pageSize + 1) // +1 to detect hasMore

        if let cursor { query = query.start(afterDocument: cursor) }

        let snapshot = try await query.getDocuments()
        let hasMore  = snapshot.documents.count > pageSize
        let pageDocs = hasMore ? Array(snapshot.documents.prefix(pageSize)) : snapshot.documents

        return ActivityPage(
            items: pageDocs.compactMap(mapToLiveOrderItem),
            lastDocument: pageDocs.last,
            hasMore: hasMore
        )
    }

    // MARK: - Real-time Listener (growing-window)

    /// `limit` grows each time the user loads another page, matching the
    /// AdminOrdersViewModel pattern so every visible order gets live updates.
    func listenToLiveActivity(
        limit: Int = 10,
        onChange: @escaping ([LiveOrderItem]) -> Void
    ) -> ListenerRegistration {
        db.collection("orders")
            .order(by: "timestamp", descending: true)
            .limit(to: limit)
            .addSnapshotListener { snapshot, _ in
                guard let snapshot else { return }
                onChange(snapshot.documents.compactMap(self.mapToLiveOrderItem))
            }
    }

    // MARK: - Shared Mapper

    private func mapToLiveOrderItem(_ doc: DocumentSnapshot) -> LiveOrderItem? {
        let data = doc.data() ?? [:]
        guard
            let timestamp = (data["timestamp"] as? Timestamp)?.dateValue(),
            let totalPrice = data["totalPrice"] as? Double,
            let status = data["status"] as? String
        else { return nil }

        let items = data["items"] as? [[String: Any]] ?? []
        return LiveOrderItem(
            id: doc.documentID,
            customerName: data["customerName"] as? String ?? "Customer",
            totalPrice: totalPrice,
            status: status,
            timestamp: timestamp,
            itemCount: items.count
        )
    }
}
