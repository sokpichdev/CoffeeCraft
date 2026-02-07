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
                    throw NSError(
                        domain: "Auth",
                        code: 401,
                        userInfo: [NSLocalizedDescriptionKey: "User not logged in"]
                    )
                }

                let fcmToken = try? await Messaging.messaging().token()
                let counterId = String.todayCounterId
                let counterRef = db.collection("counters").document(counterId)

                let result = try await db.runTransaction { transaction, errorPointer -> Any? in
                    let snapshot: DocumentSnapshot

                    do {
                        snapshot = try transaction.getDocument(counterRef)
                    } catch {
                        errorPointer?.pointee = error as NSError
                        return nil
                    }
                    // First order of the day → start at 1
                    if !snapshot.exists {
                        transaction.setData(["current": 1], forDocument: counterRef)
                        return 1
                    }
                    // incrment
                    let current = snapshot.data()?["current"] as? Int ?? 0
                    let next = current + 1
                    transaction.updateData(["current": next], forDocument: counterRef)
                    return next
                }

                guard let orderNumber = result as? Int else {
                    throw NSError(
                        domain: "OrderService",
                        code: 500,
                        userInfo: [NSLocalizedDescriptionKey: "Failed to generate order number"]
                    )
                }


                let formattedOrderId = orderNumber.formattedDailyOrderId

                let orderData: [String: Any] = [
                    "orderId": orderNumber,
                    "displayOrderId": formattedOrderId,
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

                try await db
                    .collection("orders")
                    .document(formattedOrderId)
                    .setData(orderData)

                try await MinimumLoadingTime(2.0).waitIfNeeded()
                LoaderManager.shared.hideLoading()

                AlertManager.shared.showSuccess(
                    title: "Order placed ☕️",
                    message: "Your order #\(formattedOrderId) is being prepared."
                )

                await onSuccess?()

            } catch {
                LoaderManager.shared.hideLoading()
                AlertManager.shared.showError(
                    title: "Order failed",
                    message: error.localizedDescription
                )
            }
        }
    }
}
