//
//  AnalyticsService+OrderQueue.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 13/03/2026.
//

import FirebaseFirestore
import Foundation

// MARK: - AnalyticsService — Order Analytics (Phase 8.4)

extension AnalyticsService {

    // MARK: - Real-time Queue Listener

    /// Attaches a live listener to all active orders (Pending, InProgress, Ready, OnDelivery),
    /// sorted oldest-first so the longest-waiting order is always at the top.
    func listenToOrderQueue(onChange: @escaping ([OrderQueueItem]) -> Void) -> ListenerRegistration {
        db.collection(Firebase.Orders.collection)
            .whereField(Firebase.Orders.status, in: OrderStatus.activeRawValues)
            .order(by: Firebase.Orders.timestamp, descending: false) // oldest first
            .addSnapshotListener { snapshot, _ in
                guard let snapshot else { return }
                onChange(snapshot.documents.compactMap(self.mapToQueueItem))
            }
    }

    // MARK: - History (Paginated)

    /// Fetches the first page of order history, optionally filtered.
    /// Returns an `OrderHistoryPage` with cursor for subsequent pages.
    func fetchOrderHistory(filter: OrderHistoryFilter,
                           pageSize: Int = 20) async throws -> OrderHistoryPage {
        var query: Query = db.collection(Firebase.Orders.collection)
            .order(by: Firebase.Orders.timestamp, descending: filter.sortOrder == .newest || filter.sortOrder == .oldest
                   ? filter.sortOrder != .oldest
                   : true)

        if let status = filter.status {
            query = query.whereField(Firebase.Orders.status, isEqualTo: status.rawValue)
        }

        if let r = filter.dateRange {
            query = query
                .whereField(Firebase.Orders.timestamp, isGreaterThanOrEqualTo: Timestamp(date: r.start))
                .whereField(Firebase.Orders.timestamp, isLessThanOrEqualTo: Timestamp(date: r.end))
        }

        // Fetch page + 1 to detect hasMore
        query = query.limit(to: pageSize + 1)

        let snapshot = try await query.getDocuments()
        var items = snapshot.documents.compactMap(mapToQueueItem)

        // Client-side search filter — Firestore doesn't support full-text
        if !filter.searchText.isEmpty {
            let term = filter.searchText.lowercased()
            items = items.filter {
                $0.customerName.lowercased().contains(term) ||
                $0.id.lowercased().contains(term)
            }
        }

        // Amount sorting (client-side, after text filter)
        switch filter.sortOrder {
        case .highest: items.sort { $0.totalPrice > $1.totalPrice }
        case .lowest: items.sort { $0.totalPrice < $1.totalPrice }
        default: break
        }

        let hasMore = snapshot.documents.count > pageSize
        let pageDocs = hasMore ? Array(snapshot.documents.prefix(pageSize)) : snapshot.documents

        return OrderHistoryPage(
            items: Array(items.prefix(pageSize)),
            lastDocument: pageDocs.last,
            hasMore: hasMore
        )
    }

    /// Fetches the next page using a cursor from a previous `fetchOrderHistory` call.
    func fetchMoreOrderHistory(filter: OrderHistoryFilter,
                               after cursor: DocumentSnapshot,
                               pageSize: Int = 20) async throws -> OrderHistoryPage {
        var query: Query = db.collection(Firebase.Orders.collection)
            .order(by: Firebase.Orders.timestamp, descending: filter.sortOrder != .oldest)
            .start(afterDocument: cursor)
            .limit(to: pageSize + 1)

        if let status = filter.status {
            query = query.whereField(Firebase.Orders.status, isEqualTo: status.rawValue)
        }

        if let r = filter.dateRange {
            query = query
                .whereField(Firebase.Orders.timestamp, isGreaterThanOrEqualTo: Timestamp(date: r.start))
                .whereField(Firebase.Orders.timestamp, isLessThanOrEqualTo: Timestamp(date: r.end))
        }

        let snapshot = try await query.getDocuments()
        var items = snapshot.documents.compactMap(mapToQueueItem)

        if !filter.searchText.isEmpty {
            let term = filter.searchText.lowercased()
            items = items.filter {
                $0.customerName.lowercased().contains(term) ||
                $0.id.lowercased().contains(term)
            }
        }

        switch filter.sortOrder {
        case .highest: items.sort { $0.totalPrice > $1.totalPrice }
        case .lowest: items.sort { $0.totalPrice < $1.totalPrice }
        default: break
        }

        let hasMore = snapshot.documents.count > pageSize
        let pageDocs = hasMore ? Array(snapshot.documents.prefix(pageSize)) : snapshot.documents

        return OrderHistoryPage(
            items: Array(items.prefix(pageSize)),
            lastDocument: pageDocs.last,
            hasMore: hasMore
        )
    }

    // MARK: - Order Funnel

    /// Computes funnel metrics over the given date range.
    func fetchOrderFunnel(range: DateRange = .last30Days) async throws -> OrderFunnelData {
        let startTimestamp = Timestamp(date: range.start)
        let endTimestamp = Timestamp(date: range.end)
        let ordersRef = db.collection(Firebase.Orders.collection)

        async let totalCountAgg = ordersRef
            .whereField(Firebase.Orders.timestamp, isGreaterThanOrEqualTo: startTimestamp)
            .whereField(Firebase.Orders.timestamp, isLessThanOrEqualTo: endTimestamp)
            .count
            .getAggregation(source: .server)

        async let completedCountAgg = ordersRef
            .whereField(Firebase.Orders.status, isEqualTo: OrderStatus.completed.rawValue)
            .whereField(Firebase.Orders.timestamp, isGreaterThanOrEqualTo: startTimestamp)
            .whereField(Firebase.Orders.timestamp, isLessThanOrEqualTo: endTimestamp)
            .count
            .getAggregation(source: .server)

        async let cancelledCountAgg = ordersRef
            .whereField(Firebase.Orders.status, isEqualTo: OrderStatus.cancelled.rawValue)
            .whereField(Firebase.Orders.timestamp, isGreaterThanOrEqualTo: startTimestamp)
            .whereField(Firebase.Orders.timestamp, isLessThanOrEqualTo: endTimestamp)
            .count
            .getAggregation(source: .server)

        // ── Fulfillment time (still needs document content) ───────────────────
        // Capped at 100 most-recent completed orders so cost is bounded.
        async let recentCompletedSnap = ordersRef
            .whereField(Firebase.Orders.status, isEqualTo: OrderStatus.completed.rawValue)
            .whereField(Firebase.Orders.completedAt, isGreaterThanOrEqualTo: startTimestamp)
            .whereField(Firebase.Orders.completedAt, isLessThanOrEqualTo: endTimestamp)
            .order(by: Firebase.Orders.completedAt, descending: true)
            .limit(to: 100)
            .getDocuments()

        let (totalResult, completedResult, cancelledResult, completedDocs) =
            try await (totalCountAgg, completedCountAgg, cancelledCountAgg, recentCompletedSnap)

        let totalOrders = Int(truncating: totalResult.count)
        let completedCount = Int(truncating: completedResult.count)
        let cancelledCount = Int(truncating: cancelledResult.count)
        let activeCount = max(0, totalOrders - completedCount - cancelledCount)

        // Average fulfillment time computed from the ≤100 document sample
        let fulfillmentTimes: [Double] = completedDocs.documents.compactMap { doc in
            let data = doc.data()
            guard
                let placedTs = (data[Firebase.Orders.timestamp] as? Timestamp)?.dateValue(),
                let completedTs = (data[Firebase.Orders.completedAt] as? Timestamp)?.dateValue()
            else { return nil }
            return completedTs.timeIntervalSince(placedTs) / 60 // minutes
        }

        let avgFulfillment: Double? = fulfillmentTimes.isEmpty
            ? nil
            : fulfillmentTimes.reduce(0, +) / Double(fulfillmentTimes.count)

        return OrderFunnelData(
            totalOrders: totalOrders,
            completedCount: completedCount,
            cancelledCount: cancelledCount,
            activeCount: activeCount,
            avgFulfillmentMinutes: avgFulfillment
        )
    }

    // MARK: - Status Update (Manager Action)

    /// Advances an order to the given status.
    /// Automatically sets `completedAt` when advancing to Completed,
    /// enabling fulfillment-time analytics in the funnel.
    func updateOrderStatus(orderId: String, to status: OrderStatus) async throws {
        var fields: [String: Any] = ["status": status.rawValue]

        if status == .completed {
            fields["completedAt"] = Timestamp(date: Date())
        }

        try await db.collection(Firebase.Orders.collection).document(orderId).updateData(fields)
    }

    // MARK: - Shared Mapper

    /// Maps a Firestore document to `OrderQueueItem`.
    /// Uses the same defensive field access pattern as the existing mapToLiveOrderItem.
    private func mapToQueueItem(_ doc: DocumentSnapshot) -> OrderQueueItem? {
        let data = doc.data() ?? [:]
        guard
            let timestamp = (data[Firebase.Orders.timestamp] as? Timestamp)?.dateValue(),
            let totalPrice = data[Firebase.Orders.totalPrice] as? Double,
            let statusRaw = data[Firebase.Orders.status] as? String,
            let status = OrderStatus(rawValue: statusRaw)
        else { return nil }

        let items = data[Firebase.Orders.items] as? [[String: Any]] ?? []
        let itemNames: [String] = items.compactMap { $0[Firebase.Orders.ItemField.name] as? String }

        return OrderQueueItem(
            id: doc.documentID,
            customerName: data[Firebase.Orders.customerName] as? String ?? "Customer",
            userId: data[Firebase.Orders.userId] as? String ?? "",
            totalPrice: totalPrice,
            status: status,
            isDeliveryOrder: (data[Firebase.Orders.deliveryType] as? String) == "delivery",
            timestamp: timestamp,
            completedAt: (data[Firebase.Orders.completedAt] as? Timestamp)?.dateValue(),
            itemCount: items.count,
            itemNames: itemNames,
            branchId: data[Firebase.Orders.branchId] as? String ?? ""
        )
    }
}

struct OrderHistoryPage {
    let items: [OrderQueueItem]
    let lastDocument: DocumentSnapshot?
    let hasMore: Bool
}
