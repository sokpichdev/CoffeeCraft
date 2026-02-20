//
//  PushedScreen.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 2/19/26.
//

import SwiftUI

// ============================================================
// MARK: - PushedScreen
// ============================================================
// A type-erased, Hashable wrapper around any SwiftUI View.
//
// Why we need this:
//   NavigationStack's path is typed — it needs Hashable values to track
//   which screens are on the stack. AnyView is not Hashable on its own,
//   so we wrap it with a UUID that provides identity.
//
// Each call to push() creates a new PushedScreen with a unique UUID,
// so even pushing the same View type twice results in two distinct entries.
// ============================================================

struct PushedScreen: Hashable {
    // Stable identity for this specific push event.
    let id = UUID()

    // The actual SwiftUI view to display, type-erased so any View works.
    let view: AnyView

    // Hashable conformance uses only the UUID — AnyView itself is not Hashable.
    func hash(into hasher: inout Hasher) { hasher.combine(id) }

    // Equality is purely identity-based: two pushes of the same view are different screens.
    static func == (lhs: PushedScreen, rhs: PushedScreen) -> Bool { lhs.id == rhs.id }
}
