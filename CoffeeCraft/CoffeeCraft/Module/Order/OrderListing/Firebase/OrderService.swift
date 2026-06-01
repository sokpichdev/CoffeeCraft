//
//  OrderService.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 10/22/25.
//
//  Sprint 2: Firestore removed — data access goes through injected protocols.
//  Performance trace wraps the full placeOrder flow (order_placement).
//  buildOrderData() stays here — it is pure logic with no I/O.
//
//  OrderRepositoryProtocol  — generateOrderNumber(), writeOrder()
//  WalletRepositoryProtocol — topUp / deductForOrder / refund via WalletService
//
//  Note: WalletRepositoryProtocol only exposes topUp for the VM.
//  OrderService still calls WalletService.shared for deductForOrder / refund
//  because those are atomic Firestore transactions that don't require mocking
//  at this stage — they will be covered in Sprint 3 wallet-specific tests.
//

import FirebaseAuth
import FirebaseCrashlytics
import FirebaseFirestore
import Foundation

@MainActor
class OrderService: ObservableObject {

    private let orderRepo: OrderRepositoryProtocol

    init(orderRepo: OrderRepositoryProtocol = FirestoreOrderRepository()) {
        self.orderRepo = orderRepo
    }

    func placeOrder(
        cartItems: [CartItem],
        total: Double,
        paymentMethod: PaymentMethod = .cash,
        onSuccess: (() async -> Void)? = nil
    ) {
        Task {
            guard NetworkMonitor.shared.isConnected else {
                AlertManager.shared.showError(
                    title: "No Connection",
                    message: "Please check your internet connection and try again."
                )
                AppLog.order.warning("⚠️ placeOrder blocked — device is offline")
                return
            }

            LoaderManager.shared.showLoading()

            AppLog.order.info("Placing order — items: \(cartItems.count), total: \(total), payment: \(paymentMethod.rawValue)")

            AnalyticsService.shared.log(.beginCheckout(
                total: total,
                itemCount: cartItems.count,
                paymentMethod: paymentMethod.rawValue
            ))

            do {
                // Wrap full placement in a performance trace
                try await PerformanceService.shared.trace(.orderPlacement) {
                    let userId = try getUserId()

                    let orderNumber    = try await orderRepo.generateOrderNumber()
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

                    try await writeOrderWithRefundGuard(
                        orderData: orderData,
                        paymentMethod: paymentMethod,
                        userId: userId,
                        total: total,
                        orderId: formattedOrderId
                    )

                    try await finalizeSuccess(
                        orderNumber: orderNumber,
                        total: total,
                        paymentMethod: paymentMethod
                    )

                    await onSuccess?()
                }
            } catch {
                Crashlytics.crashlytics().record(error: error)
                LoaderManager.shared.hideLoading()
                AppLog.order.error("Order failed: \(error.localizedDescription)")
                AlertManager.shared.showError(title: "Order failed", message: error.localizedDescription)
            }
        }
    }

    // MARK: - Private helpers

    private func getUserId() throws -> String {
        guard let userId = Auth.auth().currentUser?.uid else {
            throw NSError(domain: "Auth", code: 401,
                          userInfo: [NSLocalizedDescriptionKey: "User not logged in"])
        }
        return userId
    }

    private func handleWalletPayment(
        paymentMethod: PaymentMethod,
        userId: String,
        total: Double,
        orderId: String
    ) async throws {
        guard paymentMethod == .wallet else { return }
        AppLog.order.debug("Deducting \(total) from wallet — userId: \(userId), orderId: \(orderId)")
        try await WalletService.shared.deductForOrder(userId: userId, amount: total, orderId: orderId)
        AppLog.order.debug("Wallet deduction successful — orderId: \(orderId)")
    }

    private func buildOrderData(
        cartItems: [CartItem],
        total: Double,
        paymentMethod: PaymentMethod,
        userId: String,
        orderNumber: Int
    ) -> [String: Any] {
        let productIds: [String] = cartItems.compactMap { $0.product.id }

        var orderData: [String: Any] = [
            "\(Firebase.Orders.orderId)": orderNumber,
            "\(Firebase.Orders.userId)": userId,
            "\(Firebase.Orders.timestamp)": Timestamp(date: Date()),
            "\(Firebase.Orders.totalPrice)": total,
            "\(Firebase.Orders.status)": OrderStatus.pending.rawValue,
            "\(Firebase.Orders.paymentMethod)": paymentMethod.rawValue,
            "\(Firebase.Orders.productIds)": productIds,
            "\(Firebase.Orders.items)": cartItems.map { item -> [String: Any] in
                var dict: [String: Any] = [
                    Firebase.Orders.ItemField.productId: item.product.id,
                    Firebase.Orders.ItemField.name: item.product.name,
                    Firebase.Orders.ItemField.price: item.totalPrice,
                    Firebase.Orders.ItemField.imageURL: item.product.imageURL,
                    Firebase.Orders.ItemField.quantity: item.quantity,
                    Firebase.Orders.ItemField.pointsValue: item.product.pointsValue
                ]
                if !item.selections.isEmpty { dict[Firebase.Orders.ItemField.selections] = item.selections }
                if !item.extras.isEmpty { dict[Firebase.Orders.ItemField.extras]     = item.extras }
                return dict
            }
        ]

        if paymentMethod == .wallet {
            orderData[Firebase.Orders.walletAmountPaid] = total
        }
        if let branch = OrderEnvironment.shared.selectedBranch {
            orderData[Firebase.Orders.branchId] = branch.id
            orderData[Firebase.Orders.branchName] = branch.name
        }
        // Tag fulfillment mode. deliveryType drives the OnDelivery-trigger in OrderDetailView.
        // deliverySessionId is not written here — the session is created when status
        // reaches "OnDelivery" and activateDelivery() is called with the Firestore order id.
        orderData[Firebase.Orders.deliveryType] = OrderEnvironment.shared.isDelivery ? "delivery" : "pickup"
        if OrderEnvironment.shared.isDelivery {
            // Snapshot delivery coordinates into Firestore so activateDelivery()
            // can reconstruct the session after OrderEnvironment.clear() wipes memory.
            if let addr = OrderEnvironment.shared.deliveryAddressLabel {
                orderData[Firebase.Orders.deliveryAddress] = addr
            }
            if let dest = OrderEnvironment.shared.pendingDeliveryDestination {
                orderData[Firebase.Orders.deliveryDestinationLat] = dest.latitude
                orderData[Firebase.Orders.deliveryDestinationLng] = dest.longitude
            }
            if let branch = OrderEnvironment.shared.pendingDeliveryBranchCoordinate {
                orderData[Firebase.Orders.deliveryBranchLat] = branch.latitude
                orderData[Firebase.Orders.deliveryBranchLng] = branch.longitude
            }
        }
        return orderData
    }

    private func writeOrderWithRefundGuard(
        orderData: [String: Any],
        paymentMethod: PaymentMethod,
        userId: String,
        total: Double,
        orderId: String
    ) async throws {
        do {
            try await orderRepo.writeOrder(orderData: orderData, orderId: orderId)
        } catch {
            if paymentMethod == .wallet {
                AppLog.order.error("Order write failed after wallet deduction — issuing refund")
                try? await WalletService.shared.refund(userId: userId, amount: total, orderId: orderId)
            }
            throw error
        }
    }

    private func finalizeSuccess(
        orderNumber: Int,
        total: Double,
        paymentMethod: PaymentMethod
    ) async throws {
        AppLog.order.info("Order saved: #\(orderNumber)")

        AnalyticsService.shared.log(.purchase(
            orderId: String(orderNumber),
            total: total,
            paymentMethod: paymentMethod.rawValue
        ))

        try await MinimumLoadingTime(2.0).waitIfNeeded()
        LoaderManager.shared.hideLoading()
        AlertManager.shared.showSuccess(
            title: "Order placed",
            message: "Your order #\(orderNumber) is being prepared."
        )
    }
}
