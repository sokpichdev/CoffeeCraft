//
//  OrderService.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 10/22/25.
//
import Foundation
import FirebaseFirestore
import FirebaseAuth

class OrderService {
    private let db = Firestore.firestore()
    
    func placeOrder(cartItems: [CartItem], total: Double) async throws {
        guard let userId = Auth.auth().currentUser?.uid else {
            throw NSError(domain: "OrderService", code: 401, userInfo: [NSLocalizedDescriptionKey: "User not logged in"])
        }
        
        let orderData: [String: Any] = [
            "userId": userId,
            "timestamp": Timestamp(date: Date()),
            "totalPrice": total,
            "status": "Pending",
            "items": cartItems.map { item in
                return [
                    "name": item.product.name,
                    "size": item.size,
                    "milk": item.milk,
                    "sugar": item.sugar,
                    "ice": item.ice,
                    "extras": item.extras,
                    "price": item.totalPrice
                ]
            }
        ]
        
        try await db.collection("orders").addDocument(data: orderData)
    }
}
