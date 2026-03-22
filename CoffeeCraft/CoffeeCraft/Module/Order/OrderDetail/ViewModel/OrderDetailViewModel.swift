//
//  OrderDetailViewModel.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 2/24/26.
//

import FirebaseAuth
import FirebaseFirestore
import SwiftUI

@MainActor
class OrderDetailViewModel: ObservableObject {
    @Published var order: Order
    @Published var userName: String = "Loading..."
    @Published var isLoadingUser = true
    @Published var isUpdatingStatus = false
    @Published var isCancelling = false
    @Published var lastStatusUpdate: String?
    
    private let db = Firestore.firestore()
    private var orderListener: ListenerRegistration?
    private var hasAppeared = false
    
    init(order: Order) {
        self.order = order
    }

    deinit { orderListener?.remove() }

    /// Cancels a Pending order and refunds wallet balance if it was wallet-paid.
    /// Guard: only callable when status == .pending — enforced in UI and here.
    func cancelOrder() async {
        guard let orderId = order.id else { return }
        guard order.orderStatus == .pending else {
            AlertManager.shared.showError(message: "Only Pending orders can be cancelled.")
            return
        }

        isCancelling = true
        defer { isCancelling = false }

        AppLog.order.info("Cancelling order \(orderId) — payment: \(self.order.paymentMethod ?? "cash")")

        do {
            // Step 1: Mark order Cancelled in Firestore
            try await db.collection(Firebase.Orders.collection)
                .document(orderId)
                .updateData([Firebase.Orders.status: OrderStatus.cancelled.rawValue])

            AppLog.order.debug("Order \(orderId) marked Cancelled")

            // Step 2: Refund wallet if this was wallet-paid
            if order.wasWalletPayment,
               let userId = order.userId,
               let amount = order.walletAmountPaid,
               amount > 0 {

                AppLog.order.info("Issuing refund: +\(amount.currencyFormatted) for orderId: \(orderId)")

                try await WalletService.shared.refund(
                    userId: userId,
                    amount: amount,
                    orderId: orderId
                )

                ToastManager.shared.showTop(
                    message: "Order cancelled · +\(amount.currencyFormatted) refunded to wallet",
                    type: .success
                )
            } else {
                // Cash order — just confirm cancellation
                ToastManager.shared.showTop(message: "Order cancelled", type: .success)
            }

            // Real-time listener picks up the status change automatically
        } catch {
            AppLog.order.error("cancelOrder failed: \(error.localizedDescription)")
            AlertManager.shared.showError(
                title: "Cancellation failed",
                message: error.localizedDescription
            )
        }
    }

    // MARK: - Computed Helpers

    /// True only when the logged-in user owns this Pending order.
    /// Drives the Cancel button visibility in ActionButtonsSection.
    var canCancel: Bool {
        order.orderStatus == .pending &&
        order.userId == UserSession.shared.userId
    }

    /// Label shown in the Cancel confirmation dialog.
    var cancelConfirmationMessage: String {
        if order.wasWalletPayment, let amount = order.walletAmountPaid {
            return "This will cancel your order and refund \(amount.currencyFormatted) to your wallet."
        }
        return "Are you sure you want to cancel this order?"
    }

    func startListening(orderId: String) {
        guard !hasAppeared else { return }
        hasAppeared = true
        
        // Listen to order changes in real-time
        orderListener = db.collection(Firebase.Orders.collection)
            .document(orderId)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self else { return }
                if let error {
                    AppLog.order.error("OrderDetail listener error: \(error.localizedDescription)")
                    return
                }
                guard let snapshot else { return }
                do {
                    let updatedOrder = try snapshot.data(as: Order.self)
                    if updatedOrder.status != self.order.status {
                        self.lastStatusUpdate = updatedOrder.status
                        let haptic = UINotificationFeedbackGenerator()
                        haptic.notificationOccurred(.success)
                    }
                    self.order = updatedOrder
                } catch {
                    AppLog.order.error("Failed to decode order: \(error.localizedDescription)")
                }
            }
    }
    
    func fetchUserInfo(userId: String) {
        isLoadingUser = true
        db.collection(Firebase.Users.collection).document(userId).getDocument { [weak self] snapshot, error in
            guard let self else { return }
            Task { @MainActor in
                defer { self.isLoadingUser = false }
                if let error {
                    AppLog.order.error("Failed to fetch user: \(error.localizedDescription)")
                    self.userName = "Unknown User"
                    return
                }
                if let name = snapshot?.data()?["name"] as? String {
                    self.userName = name
                } else {
                    self.userName = "User #\(userId.suffix(6))"
                }
            }
        }
    }
    
    func updateOrderStatus(to status: String) async {
        guard NetworkMonitor.shared.isConnected else {
            AlertManager.shared.showNoInternet()
            AppLog.order.warning("⚠️ updateOrderStatus blocked — device is offline")
            return
        }
        guard let orderId = order.id else { return }
        isUpdatingStatus = true
        defer { isUpdatingStatus = false }
        do {
            var fields: [String: Any] = [Firebase.Orders.status: status]
            if OrderStatus.from(status) == .completed {
                // Write server-side timestamp so avg fulfillment time in
                // the Order Funnel is calculated from a reliable clock.
                fields[Firebase.Orders.completedAt] = FieldValue.serverTimestamp()
            }
            try await db.collection(Firebase.Orders.collection).document(orderId).updateData(fields)
            AppLog.order.debug("updateOrderStatus — \(orderId) → \(status)")
        } catch {
            AppLog.order.error("updateOrderStatus error: \(error.localizedDescription)")
            AlertManager.shared.showError(title: "Error updating status", message: error.localizedDescription)
        }
    }
    
    func stopListening() {
        orderListener?.remove()
        orderListener = nil
    }
}
