//
//  OrderEnvironment.swift
//  CoffeeCraft
//
//  Created by Sok Pich
//

import CoreLocation
import SwiftUI

// MARK: - FulfillmentMode

/// Determines how an order will be fulfilled.
enum FulfillmentMode {
    case pickup   // User collects from branch
    case delivery // Rider delivers to user address
}

// MARK: - OrderEnvironment

final class OrderEnvironment: ObservableObject {

    static let shared = OrderEnvironment()

    // MARK: - Branch

    /// The branch the user is ordering from. Nil until fulfillment is confirmed.
    @Published var selectedBranch: Branch?

    /// Set by the Map tab "Order from here" button.
    /// MenuView watches this: when non-nil it presents FulfillmentPickerSheet
    /// with this branch pre-loaded, then clears it.
    @Published var pendingMapBranch: Branch?

    // MARK: - Fulfillment Mode
    // Written only by FulfillmentPickerSheet (and CartView's "Change" flow).

    @Published var fulfillmentMode: FulfillmentMode = .pickup

    /// Delivery destination label shown in CartView.
    @Published var deliveryAddressLabel: String?

    // MARK: - Pending delivery intent
    // Set when FulfillmentPickerSheet confirms delivery address.
    // Simulator starts only when order status reaches "OnDelivery".

    @Published var pendingDeliveryDestination: CLLocationCoordinate2D?
    @Published var pendingDeliveryBranchCoordinate: CLLocationCoordinate2D?
    @Published var pendingDeliveryBranchId: String?

    // MARK: - Active deliveries
    // Keyed by Firestore orderId so multiple concurrent delivery orders are each
    // tracked independently. Populated when order status reaches "OnDelivery".

    @Published var activeDeliverySessions: [String: DeliverySession] = [:]
    @Published private(set) var activeDeliveryVMs: [String: DeliveryViewModel] = [:]

    /// True while DeliveryRestoreService is fetching active deliveries on app launch.
    /// activateDelivery() silently skips when this is true — the restore flow
    /// will populate the VM with the correct mid-route position instead.
    @Published private(set) var isRestoring: Bool = false

    // MARK: - Legacy single-session accessors (used by views that track one order at a time)

    /// The session for a specific order, or nil if not active.
    func deliverySession(for orderId: String) -> DeliverySession? {
        activeDeliverySessions[orderId]
    }

    /// The VM for a specific order, or nil if not active.
    func deliveryVM(for orderId: String) -> DeliveryViewModel? {
        activeDeliveryVMs[orderId]
    }

    /// Whether any delivery is currently active (used by legacy checks).
    var hasActiveDelivery: Bool { !activeDeliveryVMs.isEmpty }

    // MARK: - Convenience

    var selectedBranchId: String? { selectedBranch?.id   }
    var selectedBranchName: String? { selectedBranch?.name }
    var isDelivery: Bool { fulfillmentMode == .delivery }
    var isPickup: Bool { fulfillmentMode == .pickup   }

    // MARK: - Actions

    // MARK: - Restore lifecycle

    /// Called by DeliveryRestoreService at the start of restoreActiveDeliveries.
    /// While true, activateDelivery() is blocked so it cannot race the restore.
    func beginRestoring() { isRestoring = true }

    /// Called by DeliveryRestoreService when all restores are complete.
    func endRestoring() { isRestoring = false }

    /// Map tab "Order from here" — stores a pending branch for MenuView to pick up.
    /// Does NOT set selectedBranch; that happens only after fulfillment is confirmed.
    func preSelectBranch(_ branch: Branch) {
        pendingMapBranch = branch
    }

    /// FulfillmentPickerSheet confirmed Pickup.
    func selectPickup(branch: Branch) {
        selectedBranch       = branch
        fulfillmentMode      = .pickup
        deliveryAddressLabel = nil
        pendingMapBranch     = nil
        clearDelivery()
    }

    /// FulfillmentPickerSheet confirmed Delivery + address.
    func selectDelivery(branch: Branch, addressLabel: String,
                        destination: CLLocationCoordinate2D) {
        selectedBranch                  = branch
        fulfillmentMode                 = .delivery
        deliveryAddressLabel            = addressLabel
        pendingDeliveryDestination      = destination
        pendingDeliveryBranchCoordinate = branch.coordinate
        pendingDeliveryBranchId         = branch.id
        pendingMapBranch                = nil
    }

    /// Clears everything after a successful order is placed.
    func clear() {
        selectedBranch                  = nil
        deliveryAddressLabel            = nil
        fulfillmentMode                 = .pickup
        pendingDeliveryDestination      = nil
        pendingDeliveryBranchCoordinate = nil
        pendingDeliveryBranchId         = nil
        pendingMapBranch                = nil
    }

    /// Called by OrderDetailView when a delivery order reaches "OnDelivery".
    /// Coordinates are read from the Order model (written to Firestore at checkout)
    /// so this works even after OrderEnvironment.clear() has been called.
    /// Each order gets its own DeliveryViewModel — multiple concurrent deliveries are supported.
    func activateDelivery(order: Order) {
        guard let orderId   = order.id,
              let destLat   = order.deliveryDestinationLat,
              let destLng   = order.deliveryDestinationLng,
              let branchLat = order.deliveryBranchLat,
              let branchLng = order.deliveryBranchLng,
              let branchId  = order.branchId
        else {
            AppLog.firestore.error("[OrderEnvironment] activateDelivery: missing coordinates on order \(order.id ?? "?")")
            return
        }

        // Block activation during restore — DeliveryRestoreService will populate
        // the VM with the correct mid-route position. Without this guard, the
        // Firestore snapshot listener in OrderDetailView fires before restoreActiveDeliveries
        // completes and calls activateDelivery, resetting the rider to the branch.
        guard !isRestoring else {
            AppLog.firestore.debug("[OrderEnvironment] activateDelivery skipped — restore in progress for order \(orderId)")
            return
        }

        // Guard: don't restart a session that's already running for this order
        guard activeDeliveryVMs[orderId] == nil else { return }

        let dest        = CLLocationCoordinate2D(latitude: destLat, longitude: destLng)
        let branchCoord = CLLocationCoordinate2D(latitude: branchLat, longitude: branchLng)

        let session = DeliverySession(
            orderId: orderId,
            branchId: branchId,
            userId: order.userId ?? "",
            branchCoordinate: branchCoord,
            destinationCoordinate: dest
        )
        let vm = DeliveryViewModel()
        activeDeliverySessions[orderId] = session
        activeDeliveryVMs[orderId]      = vm
        vm.startDelivery(session: session, useSimulator: true)
    }

    /// Called by DeliveryRestoreService on app relaunch.
    /// Inserts the VM into activeDeliveryVMs immediately (so OrderDetailView.onChange
    /// sees it and skips activateDelivery), then calls resumeDelivery with the full
    /// Firestore session so the rider starts at the correct mid-route position.
    func resumeDelivery(order: Order, session: DeliverySession) {
        guard let orderId = order.id else { return }
        guard activeDeliveryVMs[orderId] == nil else { return }
        let vm = DeliveryViewModel()
        activeDeliverySessions[orderId] = session
        activeDeliveryVMs[orderId]      = vm
        vm.resumeDelivery(session: session, useSimulator: true)
        AppLog.firestore.info("""
                            [OrderEnvironment] Resumed delivery for order: \(orderId) at \
                            (\(session.riderLatitude), \(session.riderLongitude))
                            """)
    }

    /// Stop and remove the delivery session for a specific order.
    func clearDelivery(for orderId: String) {
        activeDeliveryVMs[orderId]?.stopDelivery()
        activeDeliveryVMs.removeValue(forKey: orderId)
        activeDeliverySessions.removeValue(forKey: orderId)
    }

    /// Stop all active deliveries (called on logout / full reset).
    func clearDelivery() {
        activeDeliveryVMs.values.forEach { $0.stopDelivery() }
        activeDeliveryVMs.removeAll()
        activeDeliverySessions.removeAll()
    }
}
