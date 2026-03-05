//
//  OrderEnvironment.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 06/03/2026.
//  Map Module — Phase 3: Branch Selection + Routing
//
//  Injected into the root environment so the Map module can write
//  the selected branch and the Order module can read it — no direct coupling.
//
//  Usage:
//    Write (Map):  orderEnv.select(branch: branch)
//    Read  (Order): orderEnv.selectedBranchId
//    Wire  (App):  .environmentObject(OrderEnvironment.shared)
//

import SwiftUI

// MARK: - OrderEnvironment

final class OrderEnvironment: ObservableObject {

    static let shared = OrderEnvironment()

    @Published var selectedBranchId: String?
    @Published var selectedBranchName: String?

    // MARK: - Actions

    func select(branch: Branch) {
        selectedBranchId   = branch.id
        selectedBranchName = branch.name
    }

    func clear() {
        selectedBranchId   = nil
        selectedBranchName = nil
    }
}
