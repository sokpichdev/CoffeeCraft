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

// MARK: - OrderEnvironment

final class OrderEnvironment: ObservableObject {

    static let shared = OrderEnvironment()

    // Full Branch object so downstream modules (Menu, Cart, Order)
    // can display name/address without a separate Firestore lookup.
    @Published var selectedBranch: Branch?

    // MARK: - Active delivery (Phase 4)
    // Hoisted here so DeliveryMapView can be re-entered from Order History
    // without losing the live simulator state. The VM is started by MapView
    // and stopped only when the order reaches .delivered or the user cancels.

    @Published var activeDeliverySession: DeliverySession?
    var activeDeliveryVM: DeliveryViewModel?

    // MARK: - Convenience accessors

    var selectedBranchId: String? { selectedBranch?.id   }
    var selectedBranchName: String? { selectedBranch?.name }

    // MARK: - Actions

    func select(branch: Branch) {
        selectedBranch = branch
    }

    func clear() {
        selectedBranch = nil
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
