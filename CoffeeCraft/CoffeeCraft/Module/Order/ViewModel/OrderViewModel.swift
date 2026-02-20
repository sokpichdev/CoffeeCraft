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

    private let db = Firestore.firestore()
    private var listener: ListenerRegistration?
    private let pageSize = 5

    deinit {
        listener?.remove()
    }

    @MainActor
    func fetchOrders(pageNum: Int, completion: ((Bool) -> Void)? = nil) {
        guard let userId = Auth.auth().currentUser?.uid else {
            AppLog.order.warning("⚠️ fetchOrders — no authenticated user, skipping")
            completion?(false)
            return
        }

        let offset = (pageNum - 1) * pageSize
        AppLog.order.debug("📋 fetchOrders — uid: \(userId), page: \(pageNum), offset: \(offset)")

        // Get total count
        if pageNum == 1 {
            db.collection("orders")
                .whereField("userId", isEqualTo: userId)
                .getDocuments { [weak self] snapshot, error in
                    guard let self = self else { return }
                    if let count = snapshot?.documents.count {
                        Task { @MainActor in
                            self.totalOrdersCount = count
                            AppLog.order.debug("📊 fetchOrders — totalOrdersCount: \(count)")
                        }
                    }
                }
        }

        listener?.remove()

        db.collection("orders")
            .whereField("userId", isEqualTo: userId)
            .order(by: "timestamp", descending: true)
            .getDocuments { [weak self] snapshot, error in
                guard let self = self else {
                    completion?(false)
                    return
                }

                if let error = error {
                    AppLog.order.error("❌ fetchOrders — error: \(error.localizedDescription)")
                    Task { @MainActor in
                        AlertManager.shared.showError(message: error.localizedDescription)
                    }
                    completion?(false)
                    return
                }

                guard let documents = snapshot?.documents else {
                    AppLog.order.warning("⚠️ fetchOrders — snapshot has no documents")
                    completion?(false)
                    return
                }

                // Manual pagination - slice the results
                let endIndex = min(offset + self.pageSize, documents.count)
                guard offset < documents.count else {
                    AppLog.order.debug("📋 fetchOrders — offset \(offset) beyond docs.count \(documents.count), no more pages")
                    completion?(true)
                    return
                }

                let pageDocuments = Array(documents[offset..<endIndex])
                let newOrders = pageDocuments.compactMap { doc -> Order? in
                    try? doc.data(as: Order.self)
                }

                // Avoid duplicates
                Task { @MainActor in
                    let existingIds = Set(self.orders.compactMap { $0.id })
                    let uniqueNewOrders = newOrders.filter { order in
                        guard let id = order.id else { return false }
                        return !existingIds.contains(id)
                    }
                    self.orders.append(contentsOf: uniqueNewOrders)
                    AppLog.order.debug("✅ fetchOrders — appended \(uniqueNewOrders.count) unique order(s) on page \(pageNum), total loaded: \(self.orders.count)")
                    AppLog.printList(uniqueNewOrders, label: "Orders Page \(pageNum)", logger: AppLog.order)
                }

                // Set up real-time listener for new orders only on first page
                if pageNum == 1 {
                    Task { @MainActor in
                        self.setupRealtimeListener(userId: userId)
                    }
                }

                completion?(true)
            }
    }

    @MainActor
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
                            AppLog.order.debug("✏️ setupRealtimeListener — order updated: \(updatedOrder.id ?? "nil"), status: \(updatedOrder.status)")
                        }
                    }
                }
            }
    }
    
    func refreshOrders(completion: ((Bool) -> Void)? = nil) {
        AppLog.order.debug("🔄 refreshOrders — clearing and re-fetching from page 1")
        listener?.remove()
        orders = []
        totalOrdersCount = 0
        fetchOrders(pageNum: 1, completion: completion)
    }
    
    // Keep this for backward compatibility
    func listenToUserOrders() {
        AppLog.order.debug("🔁 listenToUserOrders — delegating to fetchOrders page 1")
        fetchOrders(pageNum: 1)
    }
}
