//
//  OrderViewModel.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 10/23/25.
//
import SwiftUI
import FirebaseFirestore
import FirebaseAuth

@MainActor
class OrderViewModel: ObservableObject {
    @Published var orders: [Order] = []
    @Published var totalOrdersCount = 0
    @Published var isLoading = false

    private let db = Firestore.firestore()
    private var listener: ListenerRegistration?
    private let pageSize = 5

    deinit {
        listener?.remove()
    }

    func fetchOrders(pageNum: Int) async {
        guard let userId = Auth.auth().currentUser?.uid else {
            AppLog.order.warning("⚠️ fetchOrders — no authenticated user, skipping")
            return
        }

        guard pageNum > 1 || orders.isEmpty else { return }

        let offset = (pageNum - 1) * pageSize
        AppLog.order.debug("📋 fetchOrders — uid: \(userId), page: \(pageNum), offset: \(offset)")

        do {
            if pageNum == 1 {
                isLoading = true

                let countSnapshot = try await db.collection("orders")
                    .whereField("userId", isEqualTo: userId)
                    .getDocuments()

                totalOrdersCount = countSnapshot.documents.count
                AppLog.order.debug("📊 fetchOrders — totalOrdersCount: \(self.totalOrdersCount)")
            }

            let snapshot = try await db.collection("orders")
                .whereField("userId", isEqualTo: userId)
                .order(by: "timestamp", descending: true)
                .getDocuments()

            let docs = snapshot.documents

            let endIndex = min(offset + pageSize, docs.count)
            guard offset < docs.count else {
                AppLog.order.debug("📋 fetchOrders — offset \(offset) beyond docs.count \(docs.count), no more pages")
                isLoading = false
                return
            }

            let pageDocuments = Array(docs[offset..<endIndex])
            let newOrders = pageDocuments.compactMap {
                try? $0.data(as: Order.self)
            }

            let existingIds = Set(orders.compactMap { $0.id })
            let uniqueNewOrders = newOrders.filter {
                guard let id = $0.id else { return false }
                return !existingIds.contains(id)
            }

            orders.append(contentsOf: uniqueNewOrders)
            AppLog.order.debug("✅ fetchOrders — appended \(uniqueNewOrders.count) unique order(s) on page \(pageNum), total loaded: \(self.orders.count)")
            AppLog.printList(uniqueNewOrders, label: "Orders Page \(pageNum)", logger: AppLog.order)

            if pageNum == 1 {
                try await MinimumLoadingTime(0.5).waitIfNeeded()
                isLoading = false
                setupRealtimeListener(userId: userId)
            }

        } catch {
            isLoading = false
            AppLog.order.error("❌ fetchOrders error: \(error.localizedDescription)")
            AlertManager.shared.showError(
                title: "Error fetching orders",
                message: error.localizedDescription
            )
        }
    }

    private func setupRealtimeListener(userId: String) {
        listener?.remove()
        AppLog.order.debug("🔌 setupRealtimeListener — attaching listener for uid: \(userId)")

        listener = db.collection("orders")
            .whereField("userId", isEqualTo: userId)
            .order(by: "timestamp", descending: true)
            .limit(to: pageSize)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }

                if let error = error {
                    AppLog.order.error("❌ setupRealtimeListener — error: \(error.localizedDescription)")
                    AlertManager.shared.showError(title: "Realtime listener error", message: error.localizedDescription)
                    return
                }

                guard let changes = snapshot?.documentChanges else { return }

                for change in changes {
                    if change.type == .added {
                        if let newOrder = try? change.document.data(as: Order.self) {
                            if !self.orders.contains(where: { $0.id == newOrder.id }) {
                                self.orders.insert(newOrder, at: 0)
                                self.totalOrdersCount += 1
                                AppLog.order.debug("➕ setupRealtimeListener — new order inserted: \(newOrder.id ?? "nil"), total: \(self.totalOrdersCount)")
                            }
                        }
                    } else if change.type == .modified {
                        if let updatedOrder = try? change.document.data(as: Order.self),
                           let index = self.orders.firstIndex(where: { $0.id == updatedOrder.id }) {
                            self.orders[index] = updatedOrder
                            AppLog.order.debug("✏️ setupRealtimeListener — order updated: \(updatedOrder.id ?? "nil"), status: \(updatedOrder.status ?? "")")
                        }
                    }
                }
            }
    }

    func refreshOrders() async {
        AppLog.order.debug("🔄 refreshOrders — clearing and re-fetching from page 1")
        listener?.remove()
        orders = []
        totalOrdersCount = 0
        await fetchOrders(pageNum: 1)
    }
}
