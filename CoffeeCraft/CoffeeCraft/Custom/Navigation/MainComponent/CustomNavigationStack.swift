//
//  CustomNavigationStack.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 1/30/26.
//
import SwiftUI
import UIKit

// ============================================================
// MARK: - CustomNavigationStack
// ============================================================
// The top-level navigation container for the entire app.
// It replaces a plain NavigationStack with three additions:
//   1. A NavigationRouter that manages the push path programmatically
//   2. The pushScreen environment key injected into every child view
//   3. SwipeBackInstaller wired into SwiftUI's internal UINavigationController
//
// Usage in App entry point:
//   CustomNavigationStack {
//       RootView()
//   }
// ============================================================

struct CustomNavigationStack<Content: View>: View {

    // One router instance lives here for the full lifetime of the stack.
    // @StateObject ensures it is never recreated on re-renders.
    @StateObject private var router = NavigationRouter()

    let content: () -> Content

    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }

    var body: some View {
        // Pass router.path so we own the navigation stack programmatically.
        // NavigationStack will read and write this path as screens are pushed/popped.
        NavigationStack(path: $router.path) {
            content()
                // Teach NavigationStack how to render a PushedScreen value.
                // Every time router.push() appends a PushedScreen to the path,
                // NavigationStack calls this closure to build the destination view.
                .navigationDestination(for: PushedScreen.self) { screen in
                    screen.view
                        // Re-inject pushScreen into each destination so that
                        // deeply nested screens can also push further screens.
                        .environment(\.pushScreen, router.push)
                }
                // Install our custom swipe-back gesture and transition delegate
                // into the UINavigationController that SwiftUI creates internally.
                // Must be placed on the root content so it fires once on appear.
                .installSwipeBack(router: router)
        }
        // Inject the push action into the entire view tree so any descendant
        // can call:  @Environment(\.pushScreen) var push
        //            push(AnyView(SomeView()))
        .environment(\.pushScreen, router.push)

        // App-wide overlay managers — these sit above the NavigationStack so
        // alerts, loaders, and toasts appear over navigation transitions too.
        .withAlertManager()
        .withLoaderManager()
        .withLowerToastManager()
        .withUpperToastManager()
    }
}
