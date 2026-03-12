//
//  UINavigationController+Ex.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 4/12/26.
//
//  Restores the interactive swipe-back gesture when a custom scroll view
//  (or any view with its own DragGesture) would otherwise steal it.
//
//  Problem:
//    SwiftUI NavigationStack drives its swipe-back through the UIKit
//    UINavigationController it owns internally. By default, UIKit sets
//    interactivePopGestureRecognizer.delegate = self (the nav controller),
//    which means the recognizer only fires when no other recognizer is
//    active. CustomRefreshScrollView's simultaneousGesture(DragGesture(...))
//    is always "active" while a pan is in progress, so UIKit sees a conflict
//    and silently disables the pop gesture on every pushed screen.
//
//  Fix:
//    Become the delegate ourselves and return true from
//    gestureRecognizerShouldBegin only when there is a screen to pop.
//    This breaks the tie in favour of the edge-pan, so swipe-back works
//    regardless of what other gesture recognizers are attached to child views.
//
//  Safe usage notes:
//    • The extension is retroactive — mark it @retroactive to silence the
//      Swift 5.7+ compiler warning.
//    • gestureRecognizerShouldBegin is the only delegate method we need;
//      all other UIGestureRecognizerDelegate methods fall back to UIKit defaults.
//    • This does NOT affect sheets, fullScreenCovers, or other modal
//      presentations — they use separate nav controllers or no nav controller.

import UIKit

extension UINavigationController: @retroactive UIGestureRecognizerDelegate {

    override open func viewDidLoad() {
        super.viewDidLoad()
        // Assign ourselves as the delegate so we control when
        // the interactive pop gesture is allowed to begin.
        interactivePopGestureRecognizer?.delegate = self
    }

    /// Allow the swipe-back gesture only when there is a screen to go back to.
    /// Returning false on the root screen prevents a broken navigation state
    /// that could otherwise leave the UI unresponsive.
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        viewControllers.count > 1
    }

    /// Force every other gesture recognizer (including SwiftUI's DragGesture,
    /// which is a UIPanGestureRecognizer underneath) to wait for the
    /// interactivePopGestureRecognizer to fail before it can begin.
    ///
    /// This is the critical piece: without it, the scroll view's DragGesture
    /// wins the recognizer competition and the edge-pan never fires.
    /// UIScreenEdgePanGestureRecognizer fails almost instantly when the touch
    /// doesn't start at the leading edge, so there is no perceptible delay
    /// on taps or non-edge swipes.
    public func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer
    ) -> Bool {
        gestureRecognizer === interactivePopGestureRecognizer
    }
}
