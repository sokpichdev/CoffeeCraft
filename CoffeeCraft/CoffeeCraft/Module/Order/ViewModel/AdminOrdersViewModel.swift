//
//  AdminOrdersViewModel.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 10/23/25.
//
import SwiftUI
import FirebaseFirestore

class AdminOrdersViewModel: ObservableObject {
    @Published var orders: [Order] = []
    private let db = Firestore.firestore()

    init() {
        fetchOrders()
    }

    func fetchOrders() {
        db.collection("orders")
            .order(by: "timestamp", descending: true)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let docs = snapshot?.documents else { return }
                self?.orders = docs.compactMap { doc -> Order? in
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

