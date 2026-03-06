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
import FirebaseFirestore
import FirebaseAuth

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
                guard let userId = Auth.auth().currentUser?.uid else {
                    throw NSError(domain: "Auth", code: 401, userInfo: [NSLocalizedDescriptionKey: "User not logged in"])
                }

                // MARK: - Step 1: Generate order number
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
                    throw NSError(domain: "OrderService", code: 500, userInfo: [NSLocalizedDescriptionKey: "Failed to generate order number"])
                }

                let formattedOrderId = orderNumber.formattedDailyOrderId

                // MARK: - Step 2: Deduct wallet — real orderId is now known
                if paymentMethod == .wallet {
                    AppLog.order.debug("Deducting \(total) from wallet — userId: \(userId), orderId: \(formattedOrderId)")
                    try await WalletService.shared.deductForOrder(
                        userId: userId,
                        amount: total,
                        orderId: formattedOrderId
                    )
                    AppLog.order.debug("Wallet deduction successful — ledger linked to orderId: \(formattedOrderId)")
                }

                // MARK: - Step 3: Build order document
                var orderData: [String: Any] = [
                    "orderId":        orderNumber,
                    "userId":         userId,
                    "timestamp":      Timestamp(date: Date()),
                    "totalPrice":     total,
                    "status":         "Pending",
                    "paymentMethod":  paymentMethod.rawValue,
                    "items": cartItems.map { item -> [String: Any] in
                        var dict: [String: Any] = [
                            "productId": item.product.id,
                            "name":      item.product.name,
                            "price":     item.totalPrice,
                            "imageURL":  item.product.imageURL,
                            "quantity":  item.quantity
                        ]
                        if !item.selections.isEmpty { dict["selections"] = item.selections }
                        if !item.extras.isEmpty     { dict["extras"]     = item.extras     }
                        return dict
                    }
                ]

                // Store wallet amount paid so Phase 5 can refund the exact amount
                if paymentMethod == .wallet {
                    orderData["walletAmountPaid"] = total
                }

                // MARK: - Branch tagging (Phase 4 — Map module)
                // Tag the order with the branch the user selected on the Map tab.
                // Optional: old orders and orders placed without visiting the Map
                // tab will simply have no branchId field — that is valid.
                if let branch = OrderEnvironment.shared.selectedBranch {
                    orderData["branchId"]   = branch.id
                    orderData["branchName"] = branch.name
                    AppLog.order.debug("Order tagged with branch: \(branch.name ?? "unknown")")
                }

                // MARK: - Step 4: Write order — refund if this fails (deduction already happened)
                do {
                    try await db.collection("orders").document(formattedOrderId).setData(orderData)
                } catch {
                    // Order write failed — refund wallet if we already deducted
                    if paymentMethod == .wallet {
                        AppLog.order.error("Order write failed after wallet deduction — issuing refund")
                        try? await WalletService.shared.refund(userId: userId, amount: total, orderId: formattedOrderId)
                    }
                    throw error
                }

                AppLog.order.info("Order saved: #\(orderNumber), payment: \(paymentMethod.rawValue)")
                try await MinimumLoadingTime(2.0).waitIfNeeded()
                LoaderManager.shared.hideLoading()

                AlertManager.shared.showSuccess(
                    title: "Order placed",
                    message: "Your order #\(orderNumber) is being prepared."
                )

                await onSuccess?()

            } catch {
                LoaderManager.shared.hideLoading()
                AppLog.order.error("Order failed: \(error.localizedDescription)")
                AlertManager.shared.showError(title: "Order failed", message: error.localizedDescription)
            }
        }
    }
}
