//
//  AdminOrdersViewModel.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 10/23/25.
//
import SwiftUI
import FirebaseFirestore
import FirebaseAuth

@MainActor
class AdminOrdersViewModel: ObservableObject {
    @Published var allOrders: [Order] = []
    @Published var myOrders: [Order] = []
    @Published var totalAllOrdersCount = 0
    @Published var totalMyOrdersCount = 0
    @Published var isLoadingAllOrders = false
    @Published var isLoadingMyOrders = false
    
    var allOrdersPage = 1  // ← persists across tab switches
    var myOrdersPage = 1
    
    private let db = Firestore.firestore()
    private var allOrdersListener: ListenerRegistration?
    private var myOrdersListener: ListenerRegistration?
    private let pageSize = 10
    
    deinit {
        allOrdersListener?.remove()
        myOrdersListener?.remove()
    }

    func fetchAllOrders(pageNum: Int) async {
        guard pageNum > 1 || allOrders.isEmpty else { return }

        let offset = (pageNum - 1) * pageSize
        AppLog.order.debug("📋 fetchAllOrders — page: \(pageNum)")

        do {
            if pageNum == 1 {
                isLoadingAllOrders = true

                let countSnapshot = try await db.collection("orders")
                    .getDocuments()

                totalAllOrdersCount = countSnapshot.documents.count
            }

            let snapshot = try await db.collection("orders")
                .order(by: "timestamp", descending: true)
                .getDocuments()

            let docs = snapshot.documents

            let endIndex = min(offset + pageSize, docs.count)
            guard offset < docs.count else {
                isLoadingAllOrders = false
                return
            }

            let pageDocuments = Array(docs[offset..<endIndex])

            let newOrders = pageDocuments.compactMap {
                try? $0.data(as: Order.self)
            }

            let existingIds = Set(allOrders.compactMap { $0.id })
            let uniqueNewOrders = newOrders.filter {
                guard let id = $0.id else { return false }
                return !existingIds.contains(id)
            }

            allOrders.append(contentsOf: uniqueNewOrders)
            AppLog.printList(uniqueNewOrders, label: "All Orders Page \(pageNum)", logger: AppLog.order)
            if pageNum == 1 {
                try await MinimumLoadingTime(0.5).waitIfNeeded()
                isLoadingAllOrders = false
                setupAllOrdersListener()
            }

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
        AppLog.order.debug("🔌 setupAllOrdersListener — attaching real-time listener")
        
        allOrdersListener = db.collection("orders")
            .order(by: "timestamp", descending: true)
            .limit(to: pageSize)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }

                if let error = error {
                    AppLog.order.error("❌ setupAllOrdersListener — listener error: \(error.localizedDescription)")
                    return
                }

                guard let changes = snapshot?.documentChanges else { return }
                
                for change in changes {
                    if change.type == .added {
                        if let newOrder = try? change.document.data(as: Order.self) {
                            if !self.allOrders.contains(where: { $0.id == newOrder.id }) {
                                self.allOrders.insert(newOrder, at: 0)
                                self.totalAllOrdersCount += 1
                                AppLog.order.debug("➕ setupAllOrdersListener — new order inserted: \(newOrder.id ?? "nil"), total: \(self.totalAllOrdersCount)")
                            }
                        }
                    } else if change.type == .modified {
                        if let updatedOrder = try? change.document.data(as: Order.self),
                           let index = self.allOrders.firstIndex(where: { $0.id == updatedOrder.id }) {
                            self.allOrders[index] = updatedOrder
                            AppLog.order.debug("✏️ setupAllOrdersListener — order updated: \(updatedOrder.id ?? "nil"), status: \(updatedOrder.status)")
                        }
                    }
                }
            }
    }
    
    func fetchMyOrders(pageNum: Int) async {
        guard let userId = Auth.auth().currentUser?.uid else {
            AppLog.order.warning("⚠️ fetchMyOrders — no authenticated user")
            return
        }

        guard pageNum > 1 || myOrders.isEmpty else { return }

        let offset = (pageNum - 1) * pageSize
//        AppLog.order.debug("📋 fetchMyOrders — uid: \(userId), page: \(pageNum), offset: \(offset)")

        do {
            if pageNum == 1 {
                isLoadingMyOrders = true
                
                let countSnapshot = try await db.collection("orders")
                    .whereField("userId", isEqualTo: userId)
                    .getDocuments()
                
                totalMyOrdersCount = countSnapshot.documents.count
                AppLog.order.debug("📊 totalMyOrdersCount: \(self.totalMyOrdersCount)")
            }

            let snapshot = try await db.collection("orders")
                .whereField("userId", isEqualTo: userId)
                .order(by: "timestamp", descending: true)
                .getDocuments()

            let docs = snapshot.documents
            
            let endIndex = min(offset + pageSize, docs.count)
            guard offset < docs.count else {
                AppLog.order.debug("📋 No more pages")
                isLoadingMyOrders = false
                return
            }

            let pageDocuments = Array(docs[offset..<endIndex])

            let newOrders = pageDocuments.compactMap {
                try? $0.data(as: Order.self)
            }

            let existingIds = Set(myOrders.compactMap { $0.id })
            let uniqueNewOrders = newOrders.filter {
                guard let id = $0.id else { return false }
                return !existingIds.contains(id)
            }

            myOrders.append(contentsOf: uniqueNewOrders)
            AppLog.printList(uniqueNewOrders, label: "My Orders Page \(pageNum)", logger: AppLog.order)

            if pageNum == 1 {
                try await MinimumLoadingTime(0.5).waitIfNeeded()
                isLoadingMyOrders = false
                setupMyOrdersListener(userId: userId)
            }

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
        AppLog.order.debug("🔌 setupMyOrdersListener — attaching real-time listener for uid: \(userId)")
        
        myOrdersListener = db.collection("orders")
            .whereField("userId", isEqualTo: userId)
            .order(by: "timestamp", descending: true)
            .limit(to: pageSize)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }

                if let error = error {
                    AppLog.order.error("❌ setupMyOrdersListener — listener error: \(error.localizedDescription)")
                    return
                }

                guard let changes = snapshot?.documentChanges else { return }
                
                for change in changes {
                    if change.type == .added {
                        if let newOrder = try? change.document.data(as: Order.self) {
                            if !self.myOrders.contains(where: { $0.id == newOrder.id }) {
                                self.myOrders.insert(newOrder, at: 0)
                                self.totalMyOrdersCount += 1
                                AppLog.order.debug("➕ setupMyOrdersListener — new order inserted: \(newOrder.id ?? "nil"), total: \(self.totalMyOrdersCount)")
                            }
                        }
                    } else if change.type == .modified {
                        if let updatedOrder = try? change.document.data(as: Order.self),
                           let index = self.myOrders.firstIndex(where: { $0.id == updatedOrder.id }) {
                            self.myOrders[index] = updatedOrder
                            AppLog.order.debug("✏️ setupMyOrdersListener — order updated: \(updatedOrder.id ?? "nil"), status: \(updatedOrder.status)")
                        }
                    }
                }
            }
    }
    
    func refreshMyOrders() async {
        AppLog.order.debug("🔄 refreshMyOrders")
        myOrdersListener?.remove()
        myOrders = []
        totalMyOrdersCount = 0
        await fetchMyOrders(pageNum: 1)
    }

    func refreshAllOrders() async {
        AppLog.order.debug("🔄 refreshAllOrders")
        allOrdersListener?.remove()
        allOrders = []
        totalAllOrdersCount = 0
        await fetchAllOrders(pageNum: 1)
    }

    func updateOrderStatus(order: Order, status: String) async -> Bool {
        guard let orderId = order.id else { return false }

        do {
            try await db.collection("orders")
                .document(orderId)
                .updateData(["status": status])

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
        // Update in allOrders
        if let index = allOrders.firstIndex(where: { $0.id == orderId }) {
            if status == "Completed" {
                allOrders.remove(at: index)
                AppLog.order.debug("🗑️ applyLocalStatusChange — removed completed order from allOrders: \(orderId)")
            } else {
                allOrders[index].status = status
                AppLog.order.debug("✏️ applyLocalStatusChange — updated allOrders[\(index)] status to: \(status)")
            }
        }

        // Update in myOrders if needed
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
