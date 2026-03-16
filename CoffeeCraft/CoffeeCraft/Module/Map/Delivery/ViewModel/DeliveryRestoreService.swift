//
//  DeliveryRestoreService.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 3/16/26.
//
//  Queries Firestore for any orders still in "OnDelivery" status
//  and re-activates their DeliveryViewModel in OrderEnvironment.
//
//  Called in two places:
//    1. AuthViewModel.checkUser()  — app relaunch with an existing session
//    2. AuthViewModel.login()      — fresh login
//
//  This is the fix for the bug where closing the app while a delivery
//  is in progress causes the live tracking to disappear on relaunch.
//  Since OrderEnvironment is in-memory only, it starts empty every launch.
//  This service bridges that gap by reading the ground-truth from Firestore.
//

import FirebaseFirestore
import Foundation

final class DeliveryRestoreService {

    static let shared = DeliveryRestoreService()
    private init() {}

    private let db = Firestore.firestore()

    // MARK: - Restore

    /// Fetches all orders with status "OnDelivery" for the given user
    /// and activates a DeliveryViewModel for each one that isn't already running.
    ///
    /// Safe to call multiple times — OrderEnvironment guards against
    /// double-activation with `guard activeDeliveryVMs[orderId] == nil`.
    func restoreActiveDeliveries(for userId: String) async {
        AppLog.order.info("[DeliveryRestoreService] Checking for active deliveries — uid: \(userId)")

        do {
            let snapshot = try await db
                .collection("orders")
                .whereField("userId", isEqualTo: userId)
                .whereField("status", isEqualTo: OrderStatus.onDelivery.rawValue)
                .getDocuments()

            let activeOrders = snapshot.documents.compactMap { try? $0.data(as: Order.self) }

            guard !activeOrders.isEmpty else {
                AppLog.order.debug("[DeliveryRestoreService] No active deliveries found.")
                return
            }

            AppLog.order.info("[DeliveryRestoreService] Found \(activeOrders.count) active delivery order(s) — restoring.")

            await MainActor.run {
                for order in activeOrders {
                    OrderEnvironment.shared.activateDelivery(order: order)
                    AppLog.order.debug("[DeliveryRestoreService] Restored delivery for order: \(order.id ?? "?")")
                }
            }

        } catch {
            AppLog.order.error("[DeliveryRestoreService] Failed to fetch active deliveries: \(error.localizedDescription)")
        }
    }
}
