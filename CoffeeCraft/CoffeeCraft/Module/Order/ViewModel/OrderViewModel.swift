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
    @Published var errorMessage: String?

    private let db = Firestore.firestore()
    private var listener: ListenerRegistration?

    deinit {
        listener?.remove()
    }

    func listenToUserOrders() {
        guard let userId = Auth.auth().currentUser?.uid else { return }

        listener?.remove() // avoid multiple listeners

        listener = db.collection("orders")
            .whereField("userId", isEqualTo: userId)
            .order(by: "timestamp", descending: true)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }

                if let error = error {
                    self.errorMessage = error.localizedDescription
                    print("❌ Listen error:", error)
                    return
                }

                guard let documents = snapshot?.documents else {
                    self.orders = []
                    return
                }

                self.orders = documents.compactMap { doc -> Order? in
                    try? doc.data(as: Order.self)
                }
            }
    }
}
