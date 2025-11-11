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
                var itemDict: [String: Any] = [
                    "name": item.product.name,
                    "price": item.totalPrice
                ]
                
                if !item.selections.isEmpty {
                    itemDict["selections"] = item.selections
                }
                
                if !item.extras.isEmpty {
                    itemDict["extras"] = item.extras
                }
                
                return itemDict
            }
        ]
        
        try await db.collection("orders").addDocument(data: orderData)
    }
}
