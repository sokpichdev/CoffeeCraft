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

    func fetchUserOrders() async {
        guard let userId = Auth.auth().currentUser?.uid else { return }

        do {
            let snapshot = try await db.collection("orders")
                .whereField("userId", isEqualTo: userId)
                .order(by: "timestamp", descending: true)
                .getDocuments()

            self.orders = snapshot.documents.compactMap { doc -> Order? in
                try? doc.data(as: Order.self)
            }

        } catch {
            self.errorMessage = error.localizedDescription
            print("❌ Fetch error:", error)
        }
    }
}

