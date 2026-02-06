//
//  OrderService.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 10/22/25.
//
import Foundation
import FirebaseFirestore
import FirebaseAuth
import FirebaseMessaging

@MainActor
class OrderService: ObservableObject {
    private let db = Firestore.firestore()

    func placeOrder(
        cartItems: [CartItem],
        total: Double,
        onSuccess: (() async -> Void)? = nil
    ) {
        Task {
            LoaderManager.shared.showLoading()
            
            do {
                guard let userId = Auth.auth().currentUser?.uid else {
                    AlertManager.shared.showError(message: "User not logged in")
                    throw NSError(domain: "OrderService", code: 401, userInfo: [NSLocalizedDescriptionKey: "User not logged in"])
                }

                // Get FCM token
                let fcmToken = try? await Messaging.messaging().token()

                let orderData: [String: Any] = [
                    "userId": userId,
                    "timestamp": Timestamp(date: Date()),
                    "totalPrice": total,
                    "status": "Pending",
                    "deviceToken": fcmToken ?? "",
                    "items": cartItems.map { item in
                        var dict: [String: Any] = [
                            "name": item.product.name,
                            "price": item.totalPrice
                        ]

                        if !item.selections.isEmpty {
                            dict["selections"] = item.selections
                        }
                        if !item.extras.isEmpty {
                            dict["extras"] = item.extras
                        }
                        return dict
                    }
                ]

                let ref = try await db.collection("orders").addDocument(data: orderData)
                try await MinimumLoadingTime(2.0).waitIfNeeded() // sleep for 2s
                LoaderManager.shared.hideLoading()
                AlertManager.shared.showSuccess(title: "Order placed ☕️", message: "Your order #\(ref.documentID.prefix(6)) is being prepared.")

                await onSuccess?()

            } catch {
                LoaderManager.shared.hideLoading()
                AlertManager.shared.showError(title: "Order failed", message: error.localizedDescription)
            }
        }
    }
}
