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
}
