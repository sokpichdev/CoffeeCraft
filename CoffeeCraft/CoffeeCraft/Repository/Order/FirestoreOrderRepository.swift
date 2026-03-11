//
//  FirestoreOrderRepository.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 3/11/26.
//
//  Live Firestore implementation of OrderRepositoryProtocol.
//  The atomic counter transaction and document write that previously
//  lived inside private methods of OrderService now live here.
//

import FirebaseFirestore
import Foundation

struct FirestoreOrderRepository: OrderRepositoryProtocol {

    private let db = Firestore.firestore()

    // MARK: - Order Number Generation

    /// Atomically increments today's counter and returns the next order number.
    /// Uses a Firestore transaction so concurrent orders never get the same number.
    func generateOrderNumber() async throws -> Int {
        let counterId  = String.todayCounterId
        let counterRef = db.collection("counters").document(counterId)

        let result = try await db.runTransaction { transaction, errorPointer -> Any? in
            do {
                let snapshot = try transaction.getDocument(counterRef)
                if !snapshot.exists {
                    transaction.setData(["current": 1], forDocument: counterRef)
                    return 1
                }
                let current = snapshot.data()?["current"] as? Int ?? 0
                let next    = current + 1
                transaction.updateData(["current": next], forDocument: counterRef)
                return next
            } catch {
                errorPointer?.pointee = error as NSError
                return nil
            }
        }

        guard let orderNumber = result as? Int else {
            throw NSError(
                domain: "OrderRepository",
                code: 500,
                userInfo: [NSLocalizedDescriptionKey: "Failed to generate order number"]
            )
        }
        return orderNumber
    }

    // MARK: - Write Order

    func writeOrder(orderData: [String: Any], orderId: String) async throws {
        try await db.collection("orders").document(orderId).setData(orderData)
    }
}
