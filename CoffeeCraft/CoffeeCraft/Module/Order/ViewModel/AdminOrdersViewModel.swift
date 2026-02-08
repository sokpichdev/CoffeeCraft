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
    private let db = Firestore.firestore()
    private var allOrdersListener: ListenerRegistration?
    private var myOrdersListener: ListenerRegistration?

    init() {
        fetchAllOrders()
        fetchMyOrders()
    }
    
    deinit {
        allOrdersListener?.remove()
        myOrdersListener?.remove()
    }

    func fetchAllOrders() {
        allOrdersListener?.remove()
        
        allOrdersListener = db.collection("orders")
            .order(by: "timestamp", descending: true)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let docs = snapshot?.documents else { return }
                self?.allOrders = docs.compactMap { doc -> Order? in
                    try? doc.data(as: Order.self)
                }
            }
    }
    
    func fetchMyOrders() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        myOrdersListener?.remove()
        
        myOrdersListener = db.collection("orders")
            .whereField("userId", isEqualTo: userId)
            .order(by: "timestamp", descending: true)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let docs = snapshot?.documents else { return }
                self?.myOrders = docs.compactMap { doc -> Order? in
                    try? doc.data(as: Order.self)
                }
            }
    }

    func updateOrderStatus(order: Order, status: String) {
        guard let orderId = order.id else { return }
        db.collection("orders").document(orderId)
            .updateData(["status": status]) { error in
                if let error = error {
                    print("Error updating status: \(error.localizedDescription)")
                }
            }
    }
}
