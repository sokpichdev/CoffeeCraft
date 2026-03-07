//
//  PushSlideTransition.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 2/19/26.
//

import SwiftUI

// ============================================================
// MARK: - PushSlideTransition
// ============================================================
// Custom animation for pushing a new screen onto the stack.
//
// Visual behaviour:
//   • Incoming (toView)   slides in from the right edge of the screen
//   • Outgoing (fromView) shifts left at 30% of screen width — parallax effect
//   • A shadow strip on the left edge of toView adds perceived depth
//
// Uses UIViewPropertyAnimator + interruptibleAnimator so the setup is
// consistent with InteractiveSlideTransition and UIKit's animator contract.
// ============================================================

final class PushSlideTransition: NSObject, UIViewControllerAnimatedTransitioning {

    // Cached animato2r — UIKit may call interruptibleAnimator multiple times
    // for the same transition context. We must return the same instance each time.
    private var propertyAnimator: UIViewPropertyAnimator?

    func transitionDuration(using context: UIViewControllerContextTransitioning?) -> TimeInterval { 0.35 }

    func animateTransition(using context: UIViewControllerContextTransitioning) {
        // Delegate to interruptibleAnimator so both code paths share the same setup.
        interruptibleAnimator(using: context).startAnimation()
    }

    func interruptibleAnimator(using context: UIViewControllerContextTransitioning) -> UIViewImplicitlyAnimating {
        // Return cached animator if UIKit calls this more than once.
        if let existing = propertyAnimator { return existing }

        guard
            let fromView = context.view(forKey: .from),
            let toView   = context.view(forKey: .to)
        else {
            // Safety fallback — should never happen in a well-formed transition.
            let noop = UIViewPropertyAnimator(duration: transitionDuration(using: context), curve: .easeOut)
            noop.addCompletion { _ in context.completeTransition(false) }
            propertyAnimator = noop
            return noop
        }

        let container = context.containerView
        let width  = container.bounds.width
        let height = container.bounds.height

        // Set explicit frames (not just origin) to avoid layout ambiguity
        // when SwiftUI's auto-layout tries to recalculate positions mid-flight.
        container.addSubview(toView)
        toView.frame   = CGRect(x: width, y: 0, width: width, height: height)  // off-screen right
        fromView.frame = CGRect(x: 0, y: 0, width: width, height: height)  // current position

        // Shadow strip: a narrow view positioned at toView's left edge.
        // It travels with toView as it slides in, giving depth between screens.
        // Inserted below toView so the shadow sits behind the incoming screen.
        let shadowWidth: CGFloat = 24
        let shadow = UIView(frame: CGRect(x: width - shadowWidth, y: 0, width: shadowWidth, height: height))
        shadow.backgroundColor = UIColor.black.withAlphaComponent(0)
        shadow.isUserInteractionEnabled = false
        container.insertSubview(shadow, belowSubview: toView)

        let animator = UIViewPropertyAnimator(duration: transitionDuration(using: context), curve: .easeOut) {
            toView.frame.origin.x   = 0              // arrive at final on-screen position
            fromView.frame.origin.x = -width * 0.3   // parallax: push outgoing left by 30%
            shadow.frame.origin.x   = -shadowWidth    // shadow exits off-screen left
            shadow.backgroundColor  = UIColor.black.withAlphaComponent(0.20)
        }

        animator.addCompletion { _ in
            shadow.removeFromSuperview()
            // Restore fromView's position in case the transition was cancelled
            // and UIKit needs to snap everything back.
            fromView.frame.origin.x = 0
            context.completeTransition(!context.transitionWasCancelled)
        }

        propertyAnimator = animator
        return animator
    }
}
