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
        
        // Get total count first (only on first page)
        if pageNum == 1 {
            db.collection("orders")
                .getDocuments { [weak self] snapshot, error in
                    guard let self = self else { return }
                    if let count = snapshot?.documents.count {
                        self.totalAllOrdersCount = count
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
                    print("Error fetching orders: \(error.localizedDescription)")
                    Task { @MainActor in
                        AlertManager.shared.showError(title: "Error fetching orders", message: error.localizedDescription)
                    }
                    completion?(false)
                    return
                }
                
                guard let docs = snapshot?.documents else {
                    completion?(false)
                    return
                }
                
                // Manual pagination - slice the results
                let endIndex = min(offset + self.pageSize, docs.count)
                guard offset < docs.count else {
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
                
                // Set up listener for real-time updates only on first page
                if pageNum == 1 {
                    self.setupAllOrdersListener()
                }
                
                completion?(true)
            }
    }
    
    private func setupAllOrdersListener() {
        allOrdersListener?.remove()
        
        allOrdersListener = db.collection("orders")
            .order(by: "timestamp", descending: true)
            .limit(to: pageSize)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                guard let changes = snapshot?.documentChanges else { return }
                
                for change in changes {
                    if change.type == .added {
                        if let newOrder = try? change.document.data(as: Order.self) {
                            // Add to beginning if not already present
                            if !self.allOrders.contains(where: { $0.id == newOrder.id }) {
                                self.allOrders.insert(newOrder, at: 0)
                                self.totalAllOrdersCount += 1
                            }
                        }
                    } else if change.type == .modified {
                        if let updatedOrder = try? change.document.data(as: Order.self),
                           let index = self.allOrders.firstIndex(where: { $0.id == updatedOrder.id }) {
                            self.allOrders[index] = updatedOrder
                        }
                    }
                }
            }
    }
    
    func fetchMyOrders(pageNum: Int, completion: ((Bool) -> Void)? = nil) {
        guard let userId = Auth.auth().currentUser?.uid else {
            completion?(false)
            return
        }
        
        let offset = (pageNum - 1) * pageSize
        
        // Get total count first (only on first page)
        if pageNum == 1 {
            db.collection("orders")
                .whereField("userId", isEqualTo: userId)
                .getDocuments { [weak self] snapshot, error in
                    guard let self = self else { return }
                    if let count = snapshot?.documents.count {
                        self.totalMyOrdersCount = count
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
                    print("Error fetching my orders: \(error.localizedDescription)")
                    Task { @MainActor in
                        AlertManager.shared.showError(title: "Error fetching my orders", message: error.localizedDescription)
                    }
                    completion?(false)
                    return
                }
                
                guard let docs = snapshot?.documents else {
                    completion?(false)
                    return
                }
                
                // Manual pagination - slice the results
                let endIndex = min(offset + self.pageSize, docs.count)
                guard offset < docs.count else {
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
                
                // Set up listener for real-time updates only on first page
                if pageNum == 1 {
                    self.setupMyOrdersListener(userId: userId)
                }
                
                completion?(true)
            }
    }
    
    private func setupMyOrdersListener(userId: String) {
        myOrdersListener?.remove()
        
        myOrdersListener = db.collection("orders")
            .whereField("userId", isEqualTo: userId)
            .order(by: "timestamp", descending: true)
            .limit(to: pageSize)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                guard let changes = snapshot?.documentChanges else { return }
                
                for change in changes {
                    if change.type == .added {
                        if let newOrder = try? change.document.data(as: Order.self) {
                            if !self.myOrders.contains(where: { $0.id == newOrder.id }) {
                                self.myOrders.insert(newOrder, at: 0)
                                self.totalMyOrdersCount += 1
                            }
                        }
                    } else if change.type == .modified {
                        if let updatedOrder = try? change.document.data(as: Order.self),
                           let index = self.myOrders.firstIndex(where: { $0.id == updatedOrder.id }) {
                            self.myOrders[index] = updatedOrder
                        }
                    }
                }
            }
    }
    
    func refreshAllOrders(completion: ((Bool) -> Void)? = nil) {
        allOrdersListener?.remove()
        allOrders = []
        totalAllOrdersCount = 0
        fetchAllOrders(pageNum: 1, completion: completion)
    }
    
    func refreshMyOrders(completion: ((Bool) -> Void)? = nil) {
        myOrdersListener?.remove()
        myOrders = []
        totalMyOrdersCount = 0
        fetchMyOrders(pageNum: 1, completion: completion)
    }

    func updateOrderStatus(order: Order, status: String) {
        guard let orderId = order.id else { return }
        db.collection("orders").document(orderId)
            .updateData(["status": status]) { error in
                if let error = error {
                    print("Error updating status: \(error.localizedDescription)")
                    Task { @MainActor in
                        AlertManager.shared.showError(title: "Error updating status", message: error.localizedDescription)
                    }
                }
            }
    }
}
