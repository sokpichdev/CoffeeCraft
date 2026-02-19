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

    // No longer needed for pushing — kept only so NavigationStack
    // has a path binding and can still receive UIKit-driven pops.
    @Published var path = NavigationPath()

    // Weak ref to the UIKit nav controller, set by SwipeBackCoordinator
    // once it installs itself.
    weak var navigationController: UINavigationController?

    func push(_ view: AnyView) {
        guard let nav = navigationController else {
            // Fallback: if UIKit nav isn't wired yet, use SwiftUI path.
            path.append(PushedScreen(view: view))
            return
        }
        let host = UIHostingController(rootView: view)
        host.navigationItem.hidesBackButton = true
        // Re-inject push so deeply nested screens can push further.
        host.rootView = AnyView(
            view.environment(\.pushScreen, push)
        )
        nav.pushViewController(host, animated: true)
    }
}
