//
//  AdminOrdersViewModel.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 10/23/25.
//
import SwiftUI
import FirebaseFirestore
import FirebaseAuth

class AdminOrdersViewModel: ObservableObject {
    @Published var allOrders: [Order] = []
    @Published var myOrders: [Order] = []
    @Published var totalAllOrdersCount = 0
    @Published var totalMyOrdersCount = 0
    
    private let db = Firestore.firestore()
    private var allOrdersListener: ListenerRegistration?
    private var myOrdersListener: ListenerRegistration?
    private let pageSize = 5
    
    deinit {
        allOrdersListener?.remove()
        myOrdersListener?.remove()
    }

    func fetchAllOrders(pageNum: Int, completion: ((Bool) -> Void)? = nil) {
        let offset = (pageNum - 1) * pageSize
        AppLog.order.debug("📋 fetchAllOrders — page: \(pageNum), offset: \(offset)")

        // Get total count first (only on first page)
        if pageNum == 1 {
            db.collection("orders")
                .getDocuments { [weak self] snapshot, error in
                    guard let self = self else { return }
                    if let count = snapshot?.documents.count {
                        self.totalAllOrdersCount = count
                        AppLog.order.debug("📊 fetchAllOrders — totalAllOrdersCount: \(count)")
                    }
                }
        }
        
        // Fetch paginated data
        db.collection("orders")
            .order(by: "timestamp", descending: true)
            .getDocuments { [weak self] snapshot, error in
                guard let self = self else {
                    completion?(false)
                    return
                }
                
                if let error = error {
                    AppLog.order.error("❌ fetchAllOrders — error: \(error.localizedDescription)")
                    Task { @MainActor in
                        AlertManager.shared.showError(title: "Error fetching orders", message: error.localizedDescription)
                    }
                    completion?(false)
                    return
                }
                
                guard let docs = snapshot?.documents else {
                    AppLog.order.warning("⚠️ fetchAllOrders — snapshot has no documents")
                    completion?(false)
                    return
                }
                
                // Manual pagination - slice the results
                let endIndex = min(offset + self.pageSize, docs.count)
                guard offset < docs.count else {
                    AppLog.order.debug("📋 fetchAllOrders — offset \(offset) beyond docs.count \(docs.count), no more pages")
                    completion?(true)
                    return
                }
                
                let pageDocuments = Array(docs[offset..<endIndex])
                let newOrders = pageDocuments.compactMap { doc -> Order? in
                    try? doc.data(as: Order.self)
                }
                
                // Avoid duplicates
                let existingIds = Set(self.allOrders.compactMap { $0.id })
                let uniqueNewOrders = newOrders.filter { order in
                    guard let id = order.id else { return false }
                    return !existingIds.contains(id)
                }
                
                self.allOrders.append(contentsOf: uniqueNewOrders)
                AppLog.order.debug("✅ fetchAllOrders — appended \(uniqueNewOrders.count) unique order(s) on page \(pageNum), total loaded: \(self.allOrders.count)")
                AppLog.printList(uniqueNewOrders, label: "All Orders Page \(pageNum)", logger: AppLog.order)

                // Set up listener for real-time updates only on first page
                if pageNum == 1 {
                    self.setupAllOrdersListener()
                }
                
                completion?(true)
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
    
    func fetchMyOrders(pageNum: Int, completion: ((Bool) -> Void)? = nil) {
        guard let userId = Auth.auth().currentUser?.uid else {
            AppLog.order.warning("⚠️ fetchMyOrders — no authenticated user, skipping")
            completion?(false)
            return
        }
        
        let offset = (pageNum - 1) * pageSize
        AppLog.order.debug("📋 fetchMyOrders — uid: \(userId), page: \(pageNum), offset: \(offset)")

        // Get total count first (only on first page)
        if pageNum == 1 {
            db.collection("orders")
                .whereField("userId", isEqualTo: userId)
                .getDocuments { [weak self] snapshot, error in
                    guard let self = self else { return }
                    if let count = snapshot?.documents.count {
                        self.totalMyOrdersCount = count
                        AppLog.order.debug("📊 fetchMyOrders — totalMyOrdersCount: \(count)")
                    }
                }
        }
        
        // Fetch paginated data
        db.collection("orders")
            .whereField("userId", isEqualTo: userId)
            .order(by: "timestamp", descending: true)
            .getDocuments { [weak self] snapshot, error in
                guard let self = self else {
                    completion?(false)
                    return
                }
                
                if let error = error {
                    AppLog.order.error("❌ fetchMyOrders — error: \(error.localizedDescription)")
                    Task { @MainActor in
                        AlertManager.shared.showError(title: "Error fetching my orders", message: error.localizedDescription)
                    }
                    completion?(false)
                    return
                }
                
                guard let docs = snapshot?.documents else {
                    AppLog.order.warning("⚠️ fetchMyOrders — snapshot has no documents")
                    completion?(false)
                    return
                }
                
                // Manual pagination - slice the results
                let endIndex = min(offset + self.pageSize, docs.count)
                guard offset < docs.count else {
                    AppLog.order.debug("📋 fetchMyOrders — offset \(offset) beyond docs.count \(docs.count), no more pages")
                    completion?(true)
                    return
                }
                
                let pageDocuments = Array(docs[offset..<endIndex])
                let newOrders = pageDocuments.compactMap { doc -> Order? in
                    try? doc.data(as: Order.self)
                }
                
                // Avoid duplicates
                let existingIds = Set(self.myOrders.compactMap { $0.id })
                let uniqueNewOrders = newOrders.filter { order in
                    guard let id = order.id else { return false }
                    return !existingIds.contains(id)
                }
                
                self.myOrders.append(contentsOf: uniqueNewOrders)
                AppLog.order.debug("✅ fetchMyOrders — appended \(uniqueNewOrders.count) unique order(s) on page \(pageNum), total loaded: \(self.myOrders.count)")
                AppLog.printList(uniqueNewOrders, label: "My Orders Page \(pageNum)", logger: AppLog.order)

                // Set up listener for real-time updates only on first page
                if pageNum == 1 {
                    self.setupMyOrdersListener(userId: userId)
                }
                
                completion?(true)
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
    
    func refreshAllOrders(completion: ((Bool) -> Void)? = nil) {
        AppLog.order.debug("🔄 refreshAllOrders — clearing and re-fetching from page 1")
        allOrdersListener?.remove()
        allOrders = []
        totalAllOrdersCount = 0
        fetchAllOrders(pageNum: 1, completion: completion)
    }
    
    func refreshMyOrders(completion: ((Bool) -> Void)? = nil) {
        AppLog.order.debug("🔄 refreshMyOrders — clearing and re-fetching from page 1")
        myOrdersListener?.remove()
        myOrders = []
        totalMyOrdersCount = 0
        fetchMyOrders(pageNum: 1, completion: completion)
    }

    @MainActor
    func updateOrderStatus(
        order: Order,
        status: String,
        completion: @escaping (Bool) -> Void
    ) {
        guard let orderId = order.id else {
            AppLog.order.warning("⚠️ updateOrderStatus — order has no id, skipping")
            completion(false)
            return
        }

        AppLog.order.debug("✏️ updateOrderStatus — orderId: \(orderId), newStatus: \(status)")

        db.collection("orders")
            .document(orderId)
            .updateData(["status": status]) { [weak self] error in
                if let error = error {
                    AppLog.order.error("❌ updateOrderStatus — failed for orderId: \(orderId): \(error.localizedDescription)")
                    Task { @MainActor in
                        AlertManager.shared.showError(
                            title: "Error updating status",
                            message: error.localizedDescription
                        )
                    }
                    completion(false)
                    return
                }

                AppLog.order.debug("✅ updateOrderStatus — orderId: \(orderId) updated to: \(status)")

                Task { @MainActor in
                    self?.applyLocalStatusChange(orderId: orderId, status: status)
                    completion(true)
                }
            }
    }

    @MainActor
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
