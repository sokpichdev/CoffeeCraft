//
//  OrderEnvironment.swift
//  CoffeeCraft
//
//  Created by Sok Pich
//
//  Shared order state injected at the app root.
//
//  Flow:
//    1. Branch + fulfillment → MenuBranchSelectionSheet triggers FulfillmentPickerSheet
//    2. Map shortcut         → MapView calls preSelectBranch(branch:)
//                             MenuView detects pendingMapBranch and presents FulfillmentPickerSheet
//    3. Change in cart       → CartView re-presents FulfillmentPickerSheet
//    4. Order placed         → CartView calls clear()
//    5. Order ready (delivery) → OrderDetailView calls activateDelivery(firestoreOrderId:)
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
    // Simulator starts only when order status reaches "Ready".

    @Published var pendingDeliveryDestination: CLLocationCoordinate2D?
    @Published var pendingDeliveryBranchCoordinate: CLLocationCoordinate2D?
    @Published var pendingDeliveryBranchId: String?

    // MARK: - Active deliveries
    // Keyed by Firestore orderId so multiple concurrent delivery orders are each
    // tracked independently. Populated when order status reaches "Ready".

    @Published var activeDeliverySessions: [String: DeliverySession] = [:]
    private(set) var activeDeliveryVMs: [String: DeliveryViewModel] = [:]

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

    /// Called by OrderDetailView when a delivery order reaches "Ready".
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

        // Guard: don't restart a session that's already running for this order
        guard activeDeliveryVMs[orderId] == nil else { return }

        let dest        = CLLocationCoordinate2D(latitude: destLat, longitude: destLng)
        let branchCoord = CLLocationCoordinate2D(latitude: branchLat, longitude: branchLng)

        let session = DeliverySession(
            orderId: orderId,
            branchId: branchId,
            branchCoordinate: branchCoord,
            destinationCoordinate: dest
        )
        let vm = DeliveryViewModel()
        activeDeliverySessions[orderId] = session
        activeDeliveryVMs[orderId]      = vm
        vm.startDelivery(session: session, useSimulator: true)
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
