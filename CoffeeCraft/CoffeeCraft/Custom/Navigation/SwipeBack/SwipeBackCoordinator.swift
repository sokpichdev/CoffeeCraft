//
//  SwipeBackCoordinator.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 2/19/26.
//

import SwiftUI

// ============================================================
// MARK: - SwipeBackCoordinator
// ============================================================
// Owns and manages the custom swipe-back gesture and navigation
// transition delegate for the lifetime of the NavigationStack.
//
// Responsibilities:
//   • Disables the system interactive pop gesture (we fully replace it)
//   • Installs a UIScreenEdgePanGestureRecognizer on the nav controller's view
//   • Acts as UINavigationControllerDelegate to supply custom transitions
//   • Drives UIPercentDrivenInteractiveTransition with finger position during swipe
// ============================================================

final class SwipeBackCoordinator: NSObject,
                                   UINavigationControllerDelegate,
                                   UIGestureRecognizerDelegate {

    // Weak to avoid a retain cycle: coordinator → nav → (eventually) coordinator.
    private weak var navController: UINavigationController?

    // Held strongly during an active interactive pop gesture, then nilled after.
    private var interactiveTransition: UIPercentDrivenInteractiveTransition?

    // --------------------------------------------------------
    // MARK: Install
    // Called once from SwipeBackViewController.viewDidAppear.
    // The `navController == nil` guard prevents re-installation
    // if SwiftUI re-renders and viewDidAppear fires again.
    // --------------------------------------------------------

    func install(on nav: UINavigationController?) {
        guard let nav, navController == nil else { return }
        navController = nav

        // Remove the built-in swipe-back so it doesn't conflict with ours.
        nav.interactivePopGestureRecognizer?.isEnabled = false
        nav.interactivePopGestureRecognizer?.delegate = nil

        // Become the nav delegate so we can supply custom transition animators.
        nav.delegate = self

        // Our replacement edge-pan gesture. Installed on the nav controller's
        // view so it covers the full screen across all child view controllers —
        // no need to reinstall it per screen.
        let gesture = UIScreenEdgePanGestureRecognizer(
            target: self,
            action: #selector(handleEdgePan(_:))
        )
        gesture.edges = .left
        gesture.delegate = self
        nav.view.addGestureRecognizer(gesture)
    }

    // --------------------------------------------------------
    // MARK: Edge Pan Handler
    // Translates raw gesture state into interactive transition progress.
    //
    // Progress = how far the finger has moved as a fraction of screen width.
    // UIPercentDrivenInteractiveTransition scrubs the UIViewPropertyAnimator
    // in InteractiveSlideTransition to match finger position exactly,
    // allowing the user to hold and cancel mid-swipe.
    // --------------------------------------------------------

    @objc private func handleEdgePan(_ gesture: UIScreenEdgePanGestureRecognizer) {
        guard let nav = navController else { return }
        let progress = max(0, min(1, gesture.translation(in: nav.view).x / nav.view.bounds.width))

        switch gesture.state {
        case .began:
            // wantsInteractiveStart = true: transition starts paused, waiting for update().
            // completionCurve = .linear: finger position maps 1:1 to animation progress.
            let t = UIPercentDrivenInteractiveTransition()
            t.wantsInteractiveStart = true
            t.completionCurve = .linear
            interactiveTransition = t
            // Start the pop — the delegate will be asked for the interaction controller.
            nav.popViewController(animated: true)

        case .changed:
            // Scrub the paused animation to the current finger position.
            interactiveTransition?.update(progress)

        case .ended:
            // Complete if far enough or fast enough; otherwise snap back.
            // velocity > 800 pt/s means a fast flick always succeeds.
            let velocity = gesture.velocity(in: nav.view).x
            let shouldFinish = progress > 0.4 || velocity > 800
            interactiveTransition?.completionSpeed = 0.9
            shouldFinish ? interactiveTransition?.finish() : interactiveTransition?.cancel()
            interactiveTransition = nil

        case .cancelled:
            interactiveTransition?.completionSpeed = 0.9
            interactiveTransition?.cancel()
            interactiveTransition = nil

        default:
            interactiveTransition?.cancel()
            interactiveTransition = nil
        }
    }

    // --------------------------------------------------------
    // MARK: UIGestureRecognizerDelegate
    // --------------------------------------------------------

    // Blocks the swipe-back gesture on the root screen.
    // viewControllers.count == 1 means there is nowhere to go back to.
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        (navController?.viewControllers.count ?? 0) > 1
    }

    // Allow our edge-pan to run simultaneously with the scroll view's pan gesture
    // so pull-to-refresh and swipe-back do not block each other.
    func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWith other: UIGestureRecognizer
    ) -> Bool { true }

    // --------------------------------------------------------
    // MARK: UINavigationControllerDelegate
    // --------------------------------------------------------

    // Called by UIKit to ask which animation to use for push or pop.
    // Returning nil falls back to the default UIKit cross-dissolve/slide.
    func navigationController(
        _ navigationController: UINavigationController,
        animationControllerFor operation: UINavigationController.Operation,
        from fromVC: UIViewController,
        to toVC: UIViewController
    ) -> UIViewControllerAnimatedTransitioning? {
        switch operation {
        case .push: return PushSlideTransition()        // custom push animation
        case .pop:  return InteractiveSlideTransition() // interactive scrubable pop
        default:    return nil
        }
    }

    // Called by UIKit to ask for the interactive driver during a pop.
    // Returns our live UIPercentDrivenInteractiveTransition being driven
    // by the edge-pan gesture, or nil for non-interactive pops (e.g. back button).
    func navigationController(
        _ navigationController: UINavigationController,
        interactionControllerFor animationController: UIViewControllerAnimatedTransitioning
    ) -> UIViewControllerInteractiveTransitioning? {
        interactiveTransition
    }
}
