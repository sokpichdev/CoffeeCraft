//
//  OrderService.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 10/22/25.
//
import Foundation
import FirebaseFirestore
import FirebaseAuth

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
            
            AppLog.order.info("🛒 Placing order with \(cartItems.count) item(s), total: \(total)")

            do {
                guard let userId = Auth.auth().currentUser?.uid else {
                    AppLog.auth.error("❌ placeOrder failed: user not logged in")
                    throw NSError(
                        domain: "Auth",
                        code: 401,
                        userInfo: [NSLocalizedDescriptionKey: "User not logged in"]
                    )
                }

                AppLog.order.debug("👤 UserID: \(userId)")

                let counterId = String.todayCounterId
                let counterRef = db.collection("counters").document(counterId)

                AppLog.firestore.debug("🔢 Starting counter transaction for \(counterId)")

                let result = try await db.runTransaction { transaction, errorPointer -> Any? in
                    do {
                        let snapshot = try transaction.getDocument(counterRef)

                        if !snapshot.exists {
                            transaction.setData(["current": 1], forDocument: counterRef)
                            return 1
                        }

                        let current = snapshot.data()?["current"] as? Int ?? 0
                        let next = current + 1
                        transaction.updateData(["current": next], forDocument: counterRef)
                        return next
                    } catch {
                        errorPointer?.pointee = error as NSError
                        return nil
                    }
                }

                guard let orderNumber = result as? Int else {
                    AppLog.order.error("❌ Failed to generate order number")
                    throw NSError(
                        domain: "OrderService",
                        code: 500,
                        userInfo: [NSLocalizedDescriptionKey: "Failed to generate order number"]
                    )
                }

                AppLog.order.debug("🔢 Generated order number: \(orderNumber)")

                let formattedOrderId = orderNumber.formattedDailyOrderId

                let orderData: [String: Any] = [
                    "orderId": orderNumber,
                    "userId": userId,
                    "timestamp": Timestamp(date: Date()),
                    "totalPrice": total,
                    "status": "Pending",
                    "items": cartItems.map { item in
                        var dict: [String: Any] = [
                            "name": item.product.name,
                            "price": item.totalPrice,
                            "imageURL": item.product.imageURL
                        ]
                        if !item.selections.isEmpty { dict["selections"] = item.selections }
                        if !item.extras.isEmpty { dict["extras"] = item.extras }
                        return dict
                    }
                ]

                AppLog.firestore.debug("💾 Saving order document: \(formattedOrderId)")

                try await db
                    .collection("orders")
                    .document(formattedOrderId)
                    .setData(orderData)

                AppLog.order.info("✅ Order saved successfully: #\(orderNumber)")
                AppLog.printItem(orderData, label: "Order #\(orderNumber) Info", logger: AppLog.order)
                try await MinimumLoadingTime(2.0).waitIfNeeded()
                LoaderManager.shared.hideLoading()

                AlertManager.shared.showSuccess(
                    title: "Order placed ☕️",
                    message: "Your order #\(orderNumber) is being prepared."
                )

                await onSuccess?()

            } catch {
                LoaderManager.shared.hideLoading()

                AppLog.order.error("❌ Order failed: \(error.localizedDescription)")

                AlertManager.shared.showError(
                    title: "Order failed",
                    message: error.localizedDescription
                )
            }
        }
    }
}
