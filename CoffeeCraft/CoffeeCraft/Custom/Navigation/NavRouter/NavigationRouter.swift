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
