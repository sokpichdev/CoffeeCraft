//
//  OrderEnvironment.swift
//  CoffeeCraft
//
//  Shared environment object: Map writes selected branch, Order/Cart/Menu reads it.
//  Injected at app root so it's available to all modules without direct coupling.
//
//  Usage:
//    Write (Map):    orderEnv.select(branch: branch)
//    Read  (Order):  orderEnv.selectedBranch
//    Clear (Cart):   orderEnv.clear()   ← call after order is placed
//

import SwiftUI

// MARK: - OrderEnvironment

final class OrderEnvironment: ObservableObject {

    static let shared = OrderEnvironment()

    // Full Branch stored so downstream modules (Menu, Cart, Order)
    // can display the branch name without a separate lookup.
    @Published var selectedBranch: Branch?

    // MARK: - Convenience

    var selectedBranchId: String?   { selectedBranch?.id }
    var selectedBranchName: String? { selectedBranch?.name }

    // MARK: - Actions

    func select(branch: Branch) {
        selectedBranch = branch
    }

    func clear() {
        selectedBranch = nil
    }
}
