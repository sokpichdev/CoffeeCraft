//
//  SwipeBackViewController.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 2/19/26.
//
import SwiftUI

// ============================================================
// MARK: - installSwipeBack View Modifier
// ============================================================
// A convenience modifier that embeds SwipeBackInstaller as a
// zero-size background. Placing it in the background means it
// participates in the view hierarchy (giving it access to the
// NavigationController) without affecting layout or appearance.
// ============================================================

extension View {
    func installSwipeBack() -> some View {
        self.background(SwipeBackInstaller())
    }
}


// ============================================================
// MARK: - SwipeBackInstaller (UIViewControllerRepresentable)
// ============================================================
// An invisible UIViewControllerRepresentable whose only purpose is
// to obtain a reference to SwiftUI's internal UINavigationController.
//
// Why UIViewControllerRepresentable and NOT UIViewRepresentable:
//   UIViewRepresentable inserts a UIView directly inside UIHostingController's
//   view, which SwiftUI forbids and logs a warning about broken hierarchies.
//   UIViewControllerRepresentable adds a proper child view controller
//   alongside the hosting controller — the correct and supported pattern.
//
// Once embedded, SwipeBackViewController.viewDidAppear fires and
// self.navigationController returns SwiftUI's UINavigationController,
// which is then handed to SwipeBackCoordinator for one-time configuration.
// ============================================================

private struct SwipeBackInstaller: UIViewControllerRepresentable {

    // The coordinator is created once and kept alive for the lifetime
    // of this representable. It holds the gesture and delegate strongly.
    func makeCoordinator() -> SwipeBackCoordinator { SwipeBackCoordinator() }

    func makeUIViewController(context: Context) -> SwipeBackViewController {
        let vc = SwipeBackViewController()
        vc.coordinator = context.coordinator
        return vc
    }

    // Nothing to update — this VC has no dynamic content.
    func updateUIViewController(_ uiViewController: SwipeBackViewController, context: Context) {}
}


// ============================================================
// MARK: - SwipeBackViewController
// ============================================================
// A fully transparent, non-interactive view controller.
// It renders nothing — its only job is to exist inside the
// NavigationController hierarchy long enough for viewDidAppear
// to fire, at which point self.navigationController is valid.
//
// viewDidAppear is the earliest safe point to read navigationController
// because viewDidLoad fires before the VC is added to the nav stack.
// ============================================================

final class SwipeBackViewController: UIViewController {
    var coordinator: SwipeBackCoordinator?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        view.isUserInteractionEnabled = false   // must not intercept any touches
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // At this point self.navigationController is SwiftUI's internal
        // UINavigationController. Pass it to the coordinator to set up
        // the gesture and delegate. The coordinator guards against running twice.
        coordinator?.install(on: navigationController)
    }
}


