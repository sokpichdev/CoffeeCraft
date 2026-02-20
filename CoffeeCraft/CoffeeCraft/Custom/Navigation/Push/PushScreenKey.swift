//
//  PushScreenKey.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 2/19/26.
//

import SwiftUI

// ============================================================
// MARK: - pushScreen Environment Key
// ============================================================
// A custom SwiftUI environment key that carries the push action
// down the entire view hierarchy without prop drilling.
//
// Any view at any depth can read it with:
//   @Environment(\.pushScreen) var push
//   push(AnyView(DetailView()))
//
// The default value is a no-op so views compile safely even when
// used outside a CustomNavigationStack (e.g. in Xcode Previews).
// ============================================================

private struct PushScreenKey: EnvironmentKey {
    // No-op default: safe to call but does nothing without a real router.
    static let defaultValue: (AnyView) -> Void = { _ in }
}

extension EnvironmentValues {
    var pushScreen: (AnyView) -> Void {
        get { self[PushScreenKey.self] }
        set { self[PushScreenKey.self] = newValue }
    }
}
