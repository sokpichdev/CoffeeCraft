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
        db.collection("orders")
            .whereField("status", in: OrderStatus.activeRawValues)
            .order(by: "timestamp", descending: false) // oldest first
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
        var query: Query = db.collection("orders")
            .order(by: "timestamp", descending: filter.sortOrder == .newest || filter.sortOrder == .oldest
                   ? filter.sortOrder != .oldest
                   : true)

        if let status = filter.status {
            query = query.whereField("status", isEqualTo: status.rawValue)
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
        var query: Query = db.collection("orders")
            .order(by: "timestamp", descending: filter.sortOrder != .oldest)
            .start(afterDocument: cursor)
            .limit(to: pageSize + 1)

        if let status = filter.status {
            query = query.whereField("status", isEqualTo: status.rawValue)
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

    /// Computes funnel metrics from the last 30 days of orders.
    func fetchOrderFunnel() async throws -> OrderFunnelData {
        let thirtyDaysAgo = Calendar.current.date(byAdding: .day, value: -29,
                                                   to: Calendar.current.startOfDay(for: Date()))!
        let snapshot = try await db.collection("orders")
            .whereField("timestamp", isGreaterThanOrEqualTo: Timestamp(date: thirtyDaysAgo))
            .getDocuments()

        let orders = snapshot.documents.map { $0.data() }
        let completed = orders.filter { $0["status"] as? String == OrderStatus.completed.rawValue }
        let cancelled = orders.filter { $0["status"] as? String == OrderStatus.cancelled.rawValue }
        let active = orders.filter { OrderStatus.from($0["status"] as? String).isActive }

        // Average fulfillment time — only for orders that have completedAt stored
        let fulfillmentTimes: [Double] = completed.compactMap { order in
            guard
                let placedTs = (order["timestamp"] as? Timestamp)?.dateValue(),
                let completedTs = (order["completedAt"] as? Timestamp)?.dateValue()
            else { return nil }
            return completedTs.timeIntervalSince(placedTs) / 60 // minutes
        }

        let avgFulfillment: Double? = fulfillmentTimes.isEmpty
            ? nil
            : fulfillmentTimes.reduce(0, +) / Double(fulfillmentTimes.count)

        return OrderFunnelData(
            totalOrders: orders.count,
            completedCount: completed.count,
            cancelledCount: cancelled.count,
            activeCount: active.count,
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

        try await db.collection("orders").document(orderId).updateData(fields)
    }

    // MARK: - Shared Mapper

    /// Maps a Firestore document to `OrderQueueItem`.
    /// Uses the same defensive field access pattern as the existing mapToLiveOrderItem.
    private func mapToQueueItem(_ doc: DocumentSnapshot) -> OrderQueueItem? {
        let data = doc.data() ?? [:]
        guard
            let timestamp = (data["timestamp"] as? Timestamp)?.dateValue(),
            let totalPrice = data["totalPrice"] as? Double,
            let statusRaw = data["status"] as? String,
            let status = OrderStatus(rawValue: statusRaw)
        else { return nil }

        let items = data["items"] as? [[String: Any]] ?? []
        let itemNames: [String] = items.compactMap { $0["name"] as? String }

        return OrderQueueItem(
            id: doc.documentID,
            customerName: data["customerName"] as? String ?? "Customer",
            userId: data["userId"] as? String ?? "",
            totalPrice: totalPrice,
            status: status,
            isDeliveryOrder: (data["deliveryType"] as? String) == "delivery",
            timestamp: timestamp,
            completedAt: (data["completedAt"] as? Timestamp)?.dateValue(),
            itemCount: items.count,
            itemNames: itemNames,
            branchId: data["branchId"] as? String ?? ""
        )
    }
}

struct OrderHistoryPage {
    let items: [OrderQueueItem]
    let lastDocument: DocumentSnapshot?
    let hasMore: Bool
}
