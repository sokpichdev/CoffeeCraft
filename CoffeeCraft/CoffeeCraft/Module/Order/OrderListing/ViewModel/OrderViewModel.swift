import FirebaseAuth
import FirebaseFirestore
//
//  OrderViewModel.swift
//  CoffeeCraft
//
//  Rewrote pagination from fake client-side slicing to real Firestore
//  cursor-based pagination using startAfter(lastDocument).
//
//  Strategy:
//  ┌─────────────────────────────────────────────────────────┐
//  │  fetchOrders()  → page 1, stores last doc as cursor     │
//  │  loadMore()     → next page starting after cursor,      │
//  │                   then re-attaches listener to cover    │
//  │                   ALL loaded orders so far              │
//  │  refreshOrders()→ resets cursor + all state, re-fetches │
//  │  listener       → limit grows with orders.count so      │
//  │                   every visible order gets live updates │
//  └─────────────────────────────────────────────────────────┘
//
import SwiftUI

@MainActor
class OrderViewModel: ObservableObject {

    // MARK: - Published State

    @Published var orders: [Order] = []
    @Published var isLoading = false       // true only during first page load
    @Published var isLoadingMore = false   // true while loading page 2+
    @Published var hasMorePages = true     // flips false when Firestore returns < pageSize

    // MARK: - Private

    private let db = Firestore.firestore()
    private let pageSize = 5
    /// Listener window never grows beyond this — prevents O(n²) read cost on scroll.
    private let maxListenerWindow = 50
    private var currentListenerLimit = 0

    /// Cursor pointing to the last document fetched.
    /// The next page query starts *after* this snapshot.
    private var lastDocument: DocumentSnapshot?

    /// Realtime listener attached to the first page (most recent orders).
    /// Used only for status updates — not for loading new pages.
    private var listener: ListenerRegistration?

    deinit {
        listener?.remove()
    }

    // MARK: - Initial Fetch

    /// Fetches page 1. Called from `onAppear`.
    /// Guards against re-fetching if data is already loaded.
    func fetchOrders() async {
        guard let userId = Auth.auth().currentUser?.uid else {
            AppLog.order.warning("⚠️ fetchOrders — no authenticated user, skipping")
            return
        }

        // Don't re-fetch if we already have data (e.g. tab switch)
        guard orders.isEmpty else { return }

        AppLog.order.debug("📋 fetchOrders — uid: \(userId)")
        isLoading = true

        do {
            let snapshot = try await db
                .collection(Firebase.Orders.collection)
                .whereField(Firebase.Orders.userId, isEqualTo: userId)
                .order(by: Firebase.Orders.timestamp, descending: true)
                .limit(to: pageSize)
                .getDocuments()

            let fetched = snapshot.documents.compactMap { try? $0.data(as: Order.self) }

            orders = fetched
            lastDocument = snapshot.documents.last
            hasMorePages = snapshot.documents.count == pageSize

            AppLog.order.debug("✅ fetchOrders — loaded \(fetched.count) order(s), hasMore: \(self.hasMorePages)")
            AppLog.printList(fetched, label: "Orders Page 1", logger: AppLog.order)

            try await MinimumLoadingTime(0.5).waitIfNeeded()
            isLoading = false

            setupRealtimeListener(userId: userId)
        } catch {
            isLoading = false
            AppLog.order.error("❌ fetchOrders error: \(error.localizedDescription)")
            AlertManager.shared.showError(
                title: "Error fetching orders",
                message: error.localizedDescription
            )
        }
    }

    // MARK: - Infinite Scroll — Load Next Page

    /// Called when the last visible card triggers `.onAppear`.
    /// Appends the next page of orders using the stored cursor.
    func loadMore() async {
        guard !isLoadingMore,
              hasMorePages,
              let cursor = lastDocument,
              let userId = Auth.auth().currentUser?.uid
        else { return }

        AppLog.order.debug("📋 loadMore — fetching next page after cursor, loaded so far: \(self.orders.count)")
        isLoadingMore = true

        do {
            let snapshot = try await db
                .collection(Firebase.Orders.collection)
                .whereField(Firebase.Orders.userId, isEqualTo: userId)
                .order(by: Firebase.Orders.timestamp, descending: true)
                .start(afterDocument: cursor)
                .limit(to: pageSize)
                .getDocuments()

            let newOrders = snapshot.documents.compactMap { try? $0.data(as: Order.self) }

            // Deduplicate — listener may have already inserted a new order
            let existingIds = Set(orders.compactMap { $0.id })
            let unique = newOrders.filter { order in
                guard let id = order.id else { return false }
                return !existingIds.contains(id)
            }

            orders.append(contentsOf: unique)
            lastDocument = snapshot.documents.last
            hasMorePages = snapshot.documents.count == pageSize

            AppLog.order.debug("""
                               ✅ loadMore — appended \(unique.count) order(s), \
                               total: \(self.orders.count), hasMore: \(self.hasMorePages)
                               """)
            AppLog.printList(unique, label: "Orders Next Page", logger: AppLog.order)

            // Re-attach listener so it now covers ALL loaded orders, not just the first page.
            // e.g. user has scrolled to 50 orders → listener watches 50, not 5.
            setupRealtimeListener(userId: userId)
        } catch {
            AppLog.order.error("❌ loadMore error: \(error.localizedDescription)")
            AlertManager.shared.showError(
                title: "Error loading more orders",
                message: error.localizedDescription
            )
        }

        isLoadingMore = false
    }

    // MARK: - Pull-to-Refresh

    /// Resets all state and re-fetches from page 1.
    func refreshOrders() async {
        AppLog.order.debug("🔄 refreshOrders — resetting and re-fetching page 1")
        listener?.remove()
        listener = nil
        orders = []
        lastDocument = nil
        hasMorePages = true
        await fetchOrders()
    }

    // MARK: - Realtime Listener

    /// Attaches a listener covering exactly `orders.count` documents — so every
    /// order the user has scrolled to receives live status updates.
    ///
    /// Called after the initial fetch (limit = pageSize) and re-called after
    /// every loadMore() so the limit grows with what's on screen.
    ///
    ///   Loaded 5  orders → listener limit = 5
    ///   Loaded 25 orders → listener limit = 25
    ///   Loaded 50 orders → listener limit = 50
    ///
    /// Handles two change types:
    ///   .added    → new order just placed (insert at top)
    ///   .modified → status change on existing order (update in place)
    private func setupRealtimeListener(userId: String) {
        let newLimit = min(max(orders.count, pageSize), maxListenerWindow)
        // Skip re-attach if the window hasn't grown — saves a full re-read.
        guard newLimit != currentListenerLimit else {
            AppLog.order.debug("🔌 setupRealtimeListener — limit unchanged (\(newLimit)), skipping re-attach")
            return
        }
        currentListenerLimit = newLimit
        listener?.remove()

        AppLog.order.debug("🔌 setupRealtimeListener — attaching for uid: \(userId), limit: \(newLimit)")

        listener = db
            .collection(Firebase.Orders.collection)
            .whereField(Firebase.Orders.userId, isEqualTo: userId)
            .order(by: Firebase.Orders.timestamp, descending: true)
            .limit(to: newLimit)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self else { return }

                if let error {
                    AppLog.order.error("❌ setupRealtimeListener — \(error.localizedDescription)")
                    return
                }

                guard let changes = snapshot?.documentChanges else { return }

                for change in changes {
                    switch change.type {

                    case .added:
                        guard let newOrder = try? change.document.data(as: Order.self),
                              let id = newOrder.id
                        else { continue }

                        // Only insert if not already present (avoids duplicating initial fetch)
                        if !self.orders.contains(where: { $0.id == id }) {
                            self.orders.insert(newOrder, at: 0)
                            AppLog.order.debug("➕ listener — new order inserted: \(id)")
                        }
                        if newOrder.isDeliveryOrder,
                           OrderStatus.from(newOrder.status) == .onDelivery {
                            OrderEnvironment.shared.activateDelivery(order: newOrder)
                            AppLog.order.debug("🛵 listener — activateDelivery for restored order: \(id)")
                        }

                    case .modified:
                        guard let updated = try? change.document.data(as: Order.self),
                              let id = updated.id,
                              let index = self.orders.firstIndex(where: { $0.id == id })
                        else { continue }

                        self.orders[index] = updated
                        AppLog.order.debug("✏️ listener — order updated: \(id), status: \(updated.status ?? "unknown")")

                        if updated.isDeliveryOrder,
                           OrderStatus.from(updated.status) == .onDelivery {
                            OrderEnvironment.shared.activateDelivery(order: updated)
                            AppLog.order.debug("🛵 listener — activateDelivery on status change: \(id)")
                        }

                    default:
                        break
                    }
                }
            }
    }
}
