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

    /// Cancels a Pending order atomically using a Firestore transaction.
    /// The transaction reads the current server-side status, marks the order
    /// Cancelled, and issues a wallet refund ledger entry in a single atomic write —
    /// preventing refund loss if the app is killed between the two operations.
    func cancelOrder() async {
        guard let orderId = order.id else { return }
        guard order.orderStatus == .pending else {
            AlertManager.shared.showError(message: "Only Pending orders can be cancelled.")
            return
        }

        isCancelling = true
        defer { isCancelling = false }

        AppLog.order.info("Cancelling order \(orderId) — payment: \(self.order.paymentMethod ?? "cash")")

        let wasWalletPayment = order.wasWalletPayment
        let userId = order.userId
        let walletAmountPaid = order.walletAmountPaid ?? 0

        do {
            try await db.runTransaction { transaction, errorPointer in
                // 1. Read current order status server-side (prevents stale local state)
                let orderRef = self.db.collection(Firebase.Orders.collection).document(orderId)
                let orderSnap: DocumentSnapshot
                do {
                    orderSnap = try transaction.getDocument(orderRef)
                } catch let fetchError as NSError {
                    errorPointer?.pointee = fetchError
                    return nil
                }
                guard let currentStatus = orderSnap.data()?[Firebase.Orders.status] as? String,
                      currentStatus == OrderStatus.pending.rawValue else {
                    let err = NSError(domain: "CoffeeCraft", code: 409,
                                      userInfo: [NSLocalizedDescriptionKey: "Order is no longer Pending and cannot be cancelled."])
                    errorPointer?.pointee = err
                    return nil
                }

                // 2. Mark order Cancelled
                transaction.updateData([Firebase.Orders.status: OrderStatus.cancelled.rawValue], forDocument: orderRef)

                // 3. Atomic wallet refund (if wallet-paid)
                if wasWalletPayment, let uid = userId, walletAmountPaid > 0 {
                    let walletRef = self.db.collection(Firebase.Wallets.collection).document(uid)
                    transaction.updateData([Firebase.Wallets.balance: FieldValue.increment(walletAmountPaid)], forDocument: walletRef)

                    let txRef = self.db.collection(Firebase.WalletTransactions.collection).document()
                    transaction.setData([
                        Firebase.WalletTransactions.userId: uid,
                        Firebase.WalletTransactions.amount: walletAmountPaid,
                        Firebase.WalletTransactions.type: WalletTransactionType.refund.rawValue,
                        Firebase.WalletTransactions.orderId: orderId,
                        Firebase.WalletTransactions.createdAt: Timestamp(date: Date())
                    ], forDocument: txRef)
                }
                return nil
            }

            AppLog.order.debug("Order \(orderId) cancelled atomically")

            if wasWalletPayment, walletAmountPaid > 0 {
                ToastManager.shared.showTop(
                    message: "Order cancelled · +\(walletAmountPaid.currencyFormatted) refunded to wallet",
                    type: .success
                )
            } else {
                ToastManager.shared.showTop(message: "Order cancelled", type: .success)
            }
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
        Task {
            defer { isLoadingUser = false }
            isLoadingUser = true
            do {
                let snapshot = try await db.collection(Firebase.Users.collection).document(userId).getDocument()
                if let name = snapshot.data()?[Firebase.Users.name] as? String {
                    self.userName = name
                } else {
                    self.userName = "User #\(userId.suffix(6))"
                }
            } catch {
                AppLog.order.error("Failed to fetch user: \(error.localizedDescription)")
                self.userName = "Unknown User"
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
