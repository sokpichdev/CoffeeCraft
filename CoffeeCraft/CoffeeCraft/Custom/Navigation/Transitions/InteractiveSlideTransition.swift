//
//  InteractiveSlideTransition.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 2/19/26.
//

import SwiftUI

// ============================================================
// MARK: - InteractiveSlideTransition
// ============================================================
// Custom animation for popping a screen off the stack.
// This transition is interactive — it can be driven frame-by-frame
// by UIPercentDrivenInteractiveTransition during an edge-pan gesture,
// allowing the user to hold the screen mid-swipe and cancel if desired.
//
// Visual behaviour (exact mirror of PushSlideTransition):
//   • Outgoing (fromView) slides out to the right edge of the screen
//   • Incoming (toView)   slides in from -30% (parallax)
//   • A shadow overlay between them adds depth
//
// Why UIViewPropertyAnimator is required here:
//   UIPercentDrivenInteractiveTransition works by pausing the animator
//   and manually scrubbing fractionComplete via update(). This only works
//   with UIViewPropertyAnimator. UIView.animate blocks cannot be paused —
//   using them produces an instant snap-to-end with no scrubbing.
// ============================================================

final class InteractiveSlideTransition: NSObject, UIViewControllerAnimatedTransitioning {

    // Same caching pattern as PushSlideTransition.
    private var propertyAnimator: UIViewPropertyAnimator?

    func transitionDuration(using context: UIViewControllerContextTransitioning?) -> TimeInterval { 0.35 }

    func animateTransition(using context: UIViewControllerContextTransitioning) {
        interruptibleAnimator(using: context).startAnimation()
    }

    func interruptibleAnimator(using context: UIViewControllerContextTransitioning) -> UIViewImplicitlyAnimating {
        if let existing = propertyAnimator { return existing }

        guard
            let fromView = context.view(forKey: .from),
            let toView   = context.view(forKey: .to)
        else {
            let noop = UIViewPropertyAnimator(duration: transitionDuration(using: context), curve: .linear)
            noop.addCompletion { _ in context.completeTransition(false) }
            propertyAnimator = noop
            return noop
        }

        let container = context.containerView
        let width = container.bounds.width

        // toView (the screen we're returning to) slides in from the left at -30%.
        // Inserting it below fromView keeps the outgoing screen on top as it slides away.
        container.insertSubview(toView, belowSubview: fromView)
        toView.frame.origin.x   = -width * 0.3   // parallax start position
        fromView.frame.origin.x = 0              // current on-screen position

        // Shadow overlay sits between toView and fromView in z-order.
        // It lives in the container (a plain UITransitionView that UIKit owns),
        // NOT in fromView — adding subviews to UIHostingController.view is forbidden
        // and triggers a "broken view hierarchy" warning from SwiftUI.
        let shadow = UIView(frame: fromView.frame)
        shadow.backgroundColor = .clear
        shadow.isUserInteractionEnabled = false
        container.insertSubview(shadow, aboveSubview: toView)

        let a = UIViewPropertyAnimator(duration: transitionDuration(using: context), curve: .easeOut) {
            fromView.frame.origin.x = width          // slide outgoing screen off-right
            toView.frame.origin.x   = 0              // incoming screen arrives at 0
            // Shadow stays glued to the right edge of toView as it slides in,
            // casting a shading effect on the left side of the outgoing screen.
            shadow.frame.origin.x   = toView.frame.origin.x + toView.bounds.width
            shadow.backgroundColor  = UIColor.black.withAlphaComponent(0.25)
        }

        a.addCompletion { _ in
            shadow.removeFromSuperview()
            // completeTransition(false) if the gesture was cancelled — UIKit
            // restores original view positions automatically.
            context.completeTransition(!context.transitionWasCancelled)
        }

        propertyAnimator = a
        return a
    }
}
