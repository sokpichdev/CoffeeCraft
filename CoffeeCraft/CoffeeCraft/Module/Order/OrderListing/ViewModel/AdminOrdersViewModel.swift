import FirebaseAuth
import FirebaseFirestore
//
//  AdminOrdersViewModel.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 10/23/25.
//
import SwiftUI

@MainActor
class AdminOrdersViewModel: ObservableObject {
    @Published var allOrders: [Order] = []
    @Published var myOrders: [Order] = []
    @Published var hasMoreAllOrders = true
    @Published var hasMoreMyOrders = true
    @Published var isLoadingAllOrders = false
    @Published var isLoadingMyOrders = false

    var allOrdersPage = 1
    var myOrdersPage = 1

    private let db = Firestore.firestore()
    private var allOrdersListener: ListenerRegistration?
    private var myOrdersListener: ListenerRegistration?
    private let pageSize = 10

    private var lastAllOrdersDocument: DocumentSnapshot?
    private var lastMyOrdersDocument: DocumentSnapshot?

    deinit {
        allOrdersListener?.remove()
        myOrdersListener?.remove()
    }

    // MARK: - All Orders

    func fetchAllOrders(pageNum: Int) async {
        guard pageNum > 1 || allOrders.isEmpty else { return }
        guard hasMoreAllOrders || pageNum == 1 else { return }

        AppLog.order.debug("""
                           📋 fetchAllOrders — page: \(pageNum), \
                           cursor: \(self.lastAllOrdersDocument?.documentID ?? "none")
                           """)

        if pageNum == 1 { isLoadingAllOrders = true }

        do {
            var query: Query = db.collection("orders")
                .order(by: "timestamp", descending: true)
                .limit(to: pageSize)

            if pageNum > 1, let cursor = lastAllOrdersDocument {
                query = query.start(afterDocument: cursor)
            }

            let snapshot = try await query.getDocuments()
            let newOrders = snapshot.documents.compactMap { try? $0.data(as: Order.self) }

            lastAllOrdersDocument = snapshot.documents.last
            hasMoreAllOrders = snapshot.documents.count == pageSize

            let existingIds = Set(allOrders.compactMap { $0.id })
            let unique = newOrders.filter { !existingIds.contains($0.id ?? "") }
            allOrders.append(contentsOf: unique)

            AppLog.printList(unique, label: "All Orders Page \(pageNum)", logger: AppLog.order)
            AppLog.order.debug("✅ fetchAllOrders — appended \(unique.count), total: \(self.allOrders.count), hasMore: \(self.hasMoreAllOrders)")

            if pageNum == 1 {
                try await MinimumLoadingTime(0.5).waitIfNeeded()
                isLoadingAllOrders = false
            }

            // Re-attach after every page so the listener window always covers
            // all loaded orders. If we only attached on page 1 (limit = 10),
            // a status change on order 11 would never fire .modified on admin2.
            setupAllOrdersListener()
        } catch {
            isLoadingAllOrders = false
            AppLog.order.error("❌ fetchAllOrders error: \(error.localizedDescription)")
            AlertManager.shared.showError(
                title: "Error fetching orders",
                message: error.localizedDescription
            )
        }
    }

    private func setupAllOrdersListener() {
        allOrdersListener?.remove()

        let listenLimit = max(allOrders.count, pageSize)
        AppLog.order.debug("🔌 setupAllOrdersListener — limit: \(listenLimit)")

        allOrdersListener = db.collection("orders")
            .order(by: "timestamp", descending: true)
            .limit(to: listenLimit)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self else { return }

                if let error {
                    AppLog.order.error("❌ setupAllOrdersListener — \(error.localizedDescription)")
                    return
                }

                guard let changes = snapshot?.documentChanges else { return }

                for change in changes {
                    switch change.type {
                    case .added:
                        if let newOrder = try? change.document.data(as: Order.self),
                           !self.allOrders.contains(where: { $0.id == newOrder.id }) {
                            self.allOrders.insert(newOrder, at: 0)
                            AppLog.order.debug("➕ allOrders listener — new order: \(newOrder.id ?? "nil")")
                        }
                    case .modified:
                        if let updated = try? change.document.data(as: Order.self),
                           let index = self.allOrders.firstIndex(where: { $0.id == updated.id }) {
                            self.allOrders[index] = updated
                            AppLog.order.debug("✏️ allOrders listener — updated: \(updated.id ?? "nil"), status: \(updated.status ?? "")")
                        }
                    default:
                        break
                    }
                }
            }
    }

    // MARK: - My Orders

    func fetchMyOrders(pageNum: Int) async {
        guard let userId = Auth.auth().currentUser?.uid else {
            AppLog.order.warning("⚠️ fetchMyOrders — no authenticated user")
            return
        }

        guard pageNum > 1 || myOrders.isEmpty else { return }
        guard hasMoreMyOrders || pageNum == 1 else { return }

        AppLog.order.debug("📋 fetchMyOrders — uid: \(userId), page: \(pageNum), cursor: \(self.lastMyOrdersDocument?.documentID ?? "none")")

        if pageNum == 1 { isLoadingMyOrders = true }

        do {
            var query: Query = db.collection("orders")
                .whereField("userId", isEqualTo: userId)
                .order(by: "timestamp", descending: true)
                .limit(to: pageSize)

            if pageNum > 1, let cursor = lastMyOrdersDocument {
                query = query.start(afterDocument: cursor)
            }

            let snapshot = try await query.getDocuments()
            let newOrders = snapshot.documents.compactMap { try? $0.data(as: Order.self) }

            lastMyOrdersDocument = snapshot.documents.last
            hasMoreMyOrders = snapshot.documents.count == pageSize

            let existingIds = Set(myOrders.compactMap { $0.id })
            let unique = newOrders.filter { !existingIds.contains($0.id ?? "") }
            myOrders.append(contentsOf: unique)

            AppLog.printList(unique, label: "My Orders Page \(pageNum)", logger: AppLog.order)
            AppLog.order.debug("✅ fetchMyOrders — appended \(unique.count), total: \(self.myOrders.count), hasMore: \(self.hasMoreMyOrders)")

            if pageNum == 1 {
                try await MinimumLoadingTime(0.5).waitIfNeeded()
                isLoadingMyOrders = false
            }

            // Same growing-window pattern — re-attach after every page so
            // order11, order12... all receive live status updates.
            setupMyOrdersListener(userId: userId)
        } catch {
            isLoadingMyOrders = false
            AppLog.order.error("❌ fetchMyOrders error: \(error.localizedDescription)")
            AlertManager.shared.showError(
                title: "Error fetching my orders",
                message: error.localizedDescription
            )
        }
    }

    private func setupMyOrdersListener(userId: String) {
        myOrdersListener?.remove()

        let listenLimit = max(myOrders.count, pageSize)
        AppLog.order.debug("🔌 setupMyOrdersListener — uid: \(userId), limit: \(listenLimit)")

        myOrdersListener = db.collection("orders")
            .whereField("userId", isEqualTo: userId)
            .order(by: "timestamp", descending: true)
            .limit(to: listenLimit)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self else { return }

                if let error {
                    AppLog.order.error("❌ setupMyOrdersListener — \(error.localizedDescription)")
                    return
                }

                guard let changes = snapshot?.documentChanges else { return }

                for change in changes {
                    switch change.type {
                    case .added:
                        if let newOrder = try? change.document.data(as: Order.self),
                           !self.myOrders.contains(where: { $0.id == newOrder.id }) {
                            self.myOrders.insert(newOrder, at: 0)
                            AppLog.order.debug("➕ myOrders listener — new order: \(newOrder.id ?? "nil")")
                        }
                    case .modified:
                        if let updated = try? change.document.data(as: Order.self),
                           let index = self.myOrders.firstIndex(where: { $0.id == updated.id }) {
                            self.myOrders[index] = updated
                            AppLog.order.debug("✏️ myOrders listener — updated: \(updated.id ?? "nil"), status: \(updated.status ?? "")")
                        }
                    default:
                        break
                    }
                }
            }
    }

    // MARK: - Refresh

    func refreshMyOrders() async {
        AppLog.order.debug("🔄 refreshMyOrders")
        myOrdersListener?.remove()
        myOrdersListener = nil
        myOrders = []
        lastMyOrdersDocument = nil
        hasMoreMyOrders = true
        await fetchMyOrders(pageNum: 1)
    }

    func refreshAllOrders() async {
        AppLog.order.debug("🔄 refreshAllOrders")
        allOrdersListener?.remove()
        allOrdersListener = nil
        allOrders = []
        lastAllOrdersDocument = nil
        hasMoreAllOrders = true
        await fetchAllOrders(pageNum: 1)
    }

    // MARK: - Update Status

    func updateOrderStatus(order: Order, status: String) async -> Bool {
        guard NetworkMonitor.shared.isConnected else {
            AlertManager.shared.showNoInternet()
            AppLog.order.warning("⚠️ updateOrderStatus blocked — device is offline")
            return false
        }
        
        guard let orderId = order.id else { return false }

        do {
            var fields: [String: Any] = ["status": status]
            if status == "Completed" {
                // Write server-side timestamp so avg fulfillment time in
                // the Order Funnel is calculated from a reliable clock.
                fields["completedAt"] = FieldValue.serverTimestamp()
            }
            try await db.collection("orders")
                .document(orderId)
                .updateData(fields)

            applyLocalStatusChange(orderId: orderId, status: status)
            return true
        } catch {
            AppLog.order.error("❌ updateOrderStatus error: \(error.localizedDescription)")
            AlertManager.shared.showError(
                title: "Error updating status",
                message: error.localizedDescription
            )
            return false
        }
    }

    func applyLocalStatusChange(orderId: String, status: String) {
        if let index = allOrders.firstIndex(where: { $0.id == orderId }) {
            if status == "Completed" {
                allOrders.remove(at: index)
                AppLog.order.debug("🗑️ applyLocalStatusChange — removed completed order from allOrders: \(orderId)")
            } else {
                allOrders[index].status = status
                AppLog.order.debug("✏️ applyLocalStatusChange — updated allOrders[\(index)] status to: \(status)")
            }
        }

        if let index = myOrders.firstIndex(where: { $0.id == orderId }) {
            if status == "Completed" {
                myOrders.remove(at: index)
                AppLog.order.debug("🗑️ applyLocalStatusChange — removed completed order from myOrders: \(orderId)")
            } else {
                myOrders[index].status = status
                AppLog.order.debug("✏️ applyLocalStatusChange — updated myOrders[\(index)] status to: \(status)")
            }
        }
    }
}
