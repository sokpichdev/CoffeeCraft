import FirebaseAuth
import FirebaseFirestore
//
//  OrderService.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 10/22/25.
//
//  added paymentMethod parameter.
//  If paymentMethod == .wallet, wallet is deducted atomically
//  BEFORE the order document is written. If the order write fails
//  after deduction, a refund is issued automatically.
//
import Foundation

@MainActor
class OrderService: ObservableObject {
    private let db = Firestore.firestore()

    func placeOrder(
        cartItems: [CartItem],
        total: Double,
        paymentMethod: PaymentMethod = .cash,
        onSuccess: (() async -> Void)? = nil
    ) {
        Task {
            LoaderManager.shared.showLoading()

            AppLog.order.info("Placing order — items: \(cartItems.count), total: \(total), payment: \(paymentMethod.rawValue)")

            do {
                let userId = try getUserId()

                let orderNumber = try await generateOrderNumber()
                let formattedOrderId = orderNumber.formattedDailyOrderId

                try await handleWalletPayment(
                    paymentMethod: paymentMethod,
                    userId: userId,
                    total: total,
                    orderId: formattedOrderId
                )

                let orderData = buildOrderData(
                    cartItems: cartItems,
                    total: total,
                    paymentMethod: paymentMethod,
                    userId: userId,
                    orderNumber: orderNumber
                )

                try await writeOrder(
                    orderData: orderData,
                    paymentMethod: paymentMethod,
                    userId: userId,
                    total: total,
                    orderId: formattedOrderId
                )

                try await finalizeSuccess(orderNumber: orderNumber)

                await onSuccess?()
            } catch {
                LoaderManager.shared.hideLoading()
                AppLog.order.error("Order failed: \(error.localizedDescription)")
                AlertManager.shared.showError(title: "Order failed", message: error.localizedDescription)
            }
        }
    }

    // MARK: - Private helpers

    private func getUserId() throws -> String {
        guard let userId = Auth.auth().currentUser?.uid else {
            throw NSError(
                domain: "Auth",
                code: 401,
                userInfo: [NSLocalizedDescriptionKey: "User not logged in"]
            )
        }
        return userId
    }

    private func generateOrderNumber() async throws -> Int {
        let counterId = String.todayCounterId
        let counterRef = db.collection("counters").document(counterId)

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
            throw NSError(
                domain: "OrderService",
                code: 500,
                userInfo: [NSLocalizedDescriptionKey: "Failed to generate order number"]
            )
        }

        return orderNumber
    }
    
    private func handleWalletPayment(
        paymentMethod: PaymentMethod,
        userId: String,
        total: Double,
        orderId: String
    ) async throws {

        guard paymentMethod == .wallet else { return }

        AppLog.order.debug("Deducting \(total) from wallet — userId: \(userId), orderId: \(orderId)")

        try await WalletService.shared.deductForOrder(
            userId: userId,
            amount: total,
            orderId: orderId
        )

        AppLog.order.debug("Wallet deduction successful — ledger linked to orderId: \(orderId)")
    }
    
    private func buildOrderData(
        cartItems: [CartItem],
        total: Double,
        paymentMethod: PaymentMethod,
        userId: String,
        orderNumber: Int
    ) -> [String: Any] {

        // MARK: Phase 7 — Flat productIds array for arrayContains proof-of-purchase query.
        // compactMap drops any item whose product.id is nil (shouldn't happen in practice).
        let productIds: [String] = cartItems.compactMap { $0.product.id }

        var orderData: [String: Any] = [
            "orderId": orderNumber,
            "userId": userId,
            "timestamp": Timestamp(date: Date()),
            "totalPrice": total,
            "status": "Pending",
            "paymentMethod": paymentMethod.rawValue,
            "productIds": productIds,          // ← Phase 7 addition
            "items": cartItems.map { item -> [String: Any] in
                var dict: [String: Any] = [
                    "productId": item.product.id,
                    "name": item.product.name,
                    "price": item.totalPrice,
                    "imageURL": item.product.imageURL,
                    "quantity": item.quantity
                ]

                if !item.selections.isEmpty { dict["selections"] = item.selections }
                if !item.extras.isEmpty { dict["extras"]     = item.extras }

                return dict
            }
        ]

        if paymentMethod == .wallet {
            orderData["walletAmountPaid"] = total
        }

        if let branch = OrderEnvironment.shared.selectedBranch {
            orderData["branchId"]   = branch.id
            orderData["branchName"] = branch.name
            AppLog.order.debug("Order tagged with branch: \(branch.name)")
        }

        return orderData
    }

    private func writeOrder(
        orderData: [String: Any],
        paymentMethod: PaymentMethod,
        userId: String,
        total: Double,
        orderId: String
    ) async throws {

        do {
            try await db.collection("orders").document(orderId).setData(orderData)
        } catch {
            if paymentMethod == .wallet {
                AppLog.order.error("Order write failed after wallet deduction — issuing refund")

                try? await WalletService.shared.refund(
                    userId: userId,
                    amount: total,
                    orderId: orderId
                )
            }

            throw error
        }
    }

    private func finalizeSuccess(orderNumber: Int) async throws {

        AppLog.order.info("Order saved: #\(orderNumber)")

        try await MinimumLoadingTime(2.0).waitIfNeeded()

        LoaderManager.shared.hideLoading()

        AlertManager.shared.showSuccess(
            title: "Order placed",
            message: "Your order #\(orderNumber) is being prepared."
        )
    }
}
