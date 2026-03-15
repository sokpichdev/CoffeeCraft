//
//  OrderEnvironment.swift
//  CoffeeCraft
//
//  Created by Sok Pich
//  Map Module — Phase 3 (Simplified)
//
//  Shared bridge: Map writes the selected branch, every other module reads it.
//  Injected at app root so it's available everywhere without direct coupling.
//
//  Write (Map):   orderEnv.select(branch: branch)
//  Read (Order):  orderEnv.selectedBranch
//  Clear (Cart):  orderEnv.clear()  ← call this after a successful order
//

import SwiftUI

// MARK: - FulfillmentMode

/// Determines how an order will be fulfilled.
/// Set when the user taps "Pickup from Here" or "Deliver to Me" in BranchDetailSheet.
enum FulfillmentMode {
    case pickup   // User collects from branch
    case delivery // Rider delivers to user address
}

// MARK: - OrderEnvironment

final class OrderEnvironment: ObservableObject {

    static let shared = OrderEnvironment()

    // Full Branch object so downstream modules (Menu, Cart, Order)
    // can display name/address without a separate Firestore lookup.
    @Published var selectedBranch: Branch?

    // MARK: - Fulfillment Mode
    // Written by BranchDetailSheet CTA taps. Read by CartView + OrderService.

    @Published var fulfillmentMode: FulfillmentMode = .pickup

    // Delivery destination address label — shown in CartView delivery info card.
    @Published var deliveryAddressLabel: String?

    // MARK: - Active delivery (Phase 4)
    // Hoisted here so DeliveryMapView can be re-entered from Order History
    // without losing the live simulator state.

    @Published var activeDeliverySession: DeliverySession?
    var activeDeliveryVM: DeliveryViewModel?

    // MARK: - Convenience accessors

    var selectedBranchId: String?   { selectedBranch?.id   }
    var selectedBranchName: String? { selectedBranch?.name }
    var isDelivery: Bool            { fulfillmentMode == .delivery }
    var isPickup:   Bool            { fulfillmentMode == .pickup   }

    // MARK: - Actions

    /// Call when user taps "Pickup from Here".
    func selectPickup(branch: Branch) {
        selectedBranch    = branch
        fulfillmentMode   = .pickup
        deliveryAddressLabel = nil
        clearDelivery()
    }

    /// Call when user confirms delivery destination in DeliveryDestinationPicker.
    func selectDelivery(branch: Branch, addressLabel: String) {
        selectedBranch       = branch
        fulfillmentMode      = .delivery
        deliveryAddressLabel = addressLabel
    }

    /// Legacy — kept for backward compat with MenuBranchSelectionSheet.
    func select(branch: Branch) {
        selectedBranch  = branch
        fulfillmentMode = .pickup
    }

    func clear() {
        selectedBranch       = nil
        deliveryAddressLabel = nil
        fulfillmentMode      = .pickup
    }

    func startDelivery(session: DeliverySession) {
        let vm = DeliveryViewModel()
        activeDeliverySession = session
        activeDeliveryVM      = vm
        vm.startDelivery(session: session, useSimulator: true)
    }

    func clearDelivery() {
        activeDeliveryVM?.stopDelivery()
        activeDeliveryVM      = nil
        activeDeliverySession = nil
    }
}
