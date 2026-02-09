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
            completion?(false)
            return
        }

        let offset = (pageNum - 1) * pageSize
        
        // Get total count
        if pageNum == 1 {
            db.collection("orders")
                .whereField("userId", isEqualTo: userId)
                .getDocuments { [weak self] snapshot, error in
                    guard let self = self else { return }
                    if let count = snapshot?.documents.count {
                        Task { @MainActor in
                            self.totalOrdersCount = count
                        }
                    }
                }
        }

        listener?.remove() // avoid multiple listeners

        db.collection("orders")
            .whereField("userId", isEqualTo: userId)
            .order(by: "timestamp", descending: true)
            .getDocuments { [weak self] snapshot, error in
                guard let self = self else {
                    completion?(false)
                    return
                }

                if let error = error {
                    Task { @MainActor in
                        AlertManager.shared.showError(message: error.localizedDescription)
                    }
                    print("❌ Fetch error:", error)
                    completion?(false)
                    return
                }

                guard let documents = snapshot?.documents else {
                    completion?(false)
                    return
                }

                // Manual pagination - slice the results
                let endIndex = min(offset + self.pageSize, documents.count)
                guard offset < documents.count else {
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

        listener = db.collection("orders")
            .whereField("userId", isEqualTo: userId)
            .order(by: "timestamp", descending: true)
            .limit(to: pageSize)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }

                if let error = error {
                    AlertManager.shared.showError(title: "Realtime listener error", message: error.localizedDescription)
                    print("❌ Realtime listener error:", error)
                    return
                }

                guard let changes = snapshot?.documentChanges else { return }

                for change in changes {
                    if change.type == .added {
                        if let newOrder = try? change.document.data(as: Order.self) {
                            // Add to beginning if not already present
                            if !self.orders.contains(where: { $0.id == newOrder.id }) {
                                self.orders.insert(newOrder, at: 0)
                                self.totalOrdersCount += 1
                            }
                        }
                    } else if change.type == .modified {
                        if let updatedOrder = try? change.document.data(as: Order.self),
                           let index = self.orders.firstIndex(where: { $0.id == updatedOrder.id }) {
                            self.orders[index] = updatedOrder
                        }
                    }
                }
            }
    }
    
    func refreshOrders(completion: ((Bool) -> Void)? = nil) {
        listener?.remove()
        orders = []
        totalOrdersCount = 0
        fetchOrders(pageNum: 1, completion: completion)
    }
    
    // Keep this for backward compatibility
    func listenToUserOrders() {
        fetchOrders(pageNum: 1)
    }
}
