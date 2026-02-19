//
//  NavigationRouter.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 2/19/26.
//
import SwiftUI

// ============================================================
// MARK: - NavigationRouter
// ============================================================
// The single source of truth for what screens are on the stack.
//
// NavigationStack(path: $router.path) reads this path and renders
// a destination view for every PushedScreen in it.
//
// When push() is called, it appends a new PushedScreen — NavigationStack
// sees the path change and animates the new screen in.
//
// When the user swipes back or UIKit pops a view controller, UIKit removes
// the last entry from the path automatically, keeping SwiftUI in sync.
// ============================================================

final class NavigationRouter: ObservableObject {

    // The live stack of pushed screens. NavigationStack observes this directly.
    @Published var path = NavigationPath()

    /// Pushes any SwiftUI view onto the navigation stack.
    /// Call via @Environment(\.pushScreen) — do not call this directly from views.
    func push(_ view: AnyView) {
        path.append(PushedScreen(view: view))
    }
}
