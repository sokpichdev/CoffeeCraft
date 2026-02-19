//
//  AppNavigationController.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 2/19/26.
//
import SwiftUI

// ============================================================
// MARK: - AppNavigationController (referenced by CustomRefreshScrollView.swift)
// ============================================================
// Only used if you choose the UIKit-owned nav stack approach instead of
// CustomNavigationStack. If you are using CustomNavigationStack, this
// class is unused — keep it or delete it as you prefer.
//
// It owns the UINavigationController as a subclass so the delegate
// is set in viewDidLoad and can never be stolen by SwiftUI or other VCs.
// ============================================================

final class AppNavigationController: UINavigationController,
                                      UINavigationControllerDelegate {

    private var interactiveTransition: UIPercentDrivenInteractiveTransition?

    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        navigationBar.isHidden = true

        // Disable system gesture entirely — we provide our own below.
        interactivePopGestureRecognizer?.isEnabled = false
        interactivePopGestureRecognizer?.delegate = nil

        setupEdgePanGesture()
    }

    private func setupEdgePanGesture() {
        let edgePan = UIScreenEdgePanGestureRecognizer(
            target: self,
            action: #selector(handleEdgePan(_:))
        )
        edgePan.edges = .left
        edgePan.delegate = self
        view.addGestureRecognizer(edgePan)
    }

    @objc private func handleEdgePan(_ gesture: UIScreenEdgePanGestureRecognizer) {
        let progress = max(0, min(1, gesture.translation(in: view).x / view.bounds.width))

        switch gesture.state {
        case .began:
            let t = UIPercentDrivenInteractiveTransition()
            t.wantsInteractiveStart = true
            t.completionCurve = .linear
            interactiveTransition = t
            popViewController(animated: true)

        case .changed:
            interactiveTransition?.update(progress)

        case .ended:
            let velocity = gesture.velocity(in: view).x
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

    // Only allow swipe-back when there is a screen to go back to.
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        viewControllers.count > 1
    }

    func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWith other: UIGestureRecognizer
    ) -> Bool { true }

    func navigationController(
        _ navigationController: UINavigationController,
        animationControllerFor operation: UINavigationController.Operation,
        from fromVC: UIViewController,
        to toVC: UIViewController
    ) -> UIViewControllerAnimatedTransitioning? {
        operation == .pop ? InteractiveSlideTransition() : nil
    }

    func navigationController(
        _ navigationController: UINavigationController,
        interactionControllerFor animationController: UIViewControllerAnimatedTransitioning
    ) -> UIViewControllerInteractiveTransitioning? {
        interactiveTransition
    }
}
