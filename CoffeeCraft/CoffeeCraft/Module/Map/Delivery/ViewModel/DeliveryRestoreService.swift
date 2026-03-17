//
//  DeliveryRestoreService.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 3/16/26.
//
//

import FirebaseFirestore
import Foundation

final class DeliveryRestoreService {

    static let shared = DeliveryRestoreService()
    private init() {}

    private let db = Firestore.firestore()

    // MARK: - Restore

    /// Fetches all orders with status "OnDelivery" for the given user,
    /// loads their corresponding DeliverySession from Firestore,
    /// and resumes each one from the correct mid-route position.
    ///
    /// Safe to call multiple times — OrderEnvironment guards against
    /// double-activation with `guard activeDeliveryVMs[orderId] == nil`.
    func restoreActiveDeliveries(for userId: String) async {
        AppLog.order.info("[DeliveryRestoreService] Checking for active deliveries — uid: \(userId)")

        // Raise the restore flag BEFORE any await so activateDelivery() is blocked
        // from the moment this function starts until all restores complete.
        await MainActor.run { OrderEnvironment.shared.beginRestoring() }

        defer {
            Task { @MainActor in
                OrderEnvironment.shared.endRestoring()
                AppLog.order.debug("[DeliveryRestoreService] Restore complete — activateDelivery unblocked")
            }
        }

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

            for order in activeOrders {
                guard let orderId = order.id else { continue }

                do {
                    // Fetch the deliveries/{orderId} document which holds the real
                    // last-known riderLatitude/riderLongitude written every simulator tick.
                    let deliveryDoc = try await db
                        .collection("deliveries")
                        .document(orderId)
                        .getDocument()

                    if let data = deliveryDoc.data(),
                       let session = DeliverySession(firestoreData: data) {
                        // Insert the VM and start it on the MainActor in a single
                        // synchronous block — no async gap for OrderDetailView.onChange
                        // to sneak in and call activateDelivery.
                        await MainActor.run {
                            OrderEnvironment.shared.resumeDelivery(order: order, session: session)
                            AppLog.order.info("""
                                            [DeliveryRestoreService] Restored order \(orderId) at \
                                            (\(session.riderLatitude), \(session.riderLongitude))
                                            """)
                        }
                    } else {
                        // No delivery doc found — start fresh from branch.
                        await MainActor.run {
                            OrderEnvironment.shared.activateDelivery(order: order)
                            AppLog.order.warning("""
                                                [DeliveryRestoreService] No delivery doc for \(orderId) \
                                                — fresh start from branch
                                                """)
                        }
                    }
                } catch {
                    await MainActor.run {
                        OrderEnvironment.shared.activateDelivery(order: order)
                        AppLog.order.error("""
                                        [DeliveryRestoreService] Fetch failed for \(orderId): \
                                        \(error.localizedDescription) — fresh start from branch
                                        """)
                    }
                }
            }
        } catch {
            AppLog.order.error(
                "[DeliveryRestoreService] Failed to fetch active deliveries: \(error.localizedDescription)")
        }
    }
}
