//
//  CustomNavigationStack.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 1/30/26.
//
import SwiftUI

struct CustomNavigationStack<Content: View>: View {
    @StateObject private var router = NavigationRouter()

    let content: () -> Content

    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }

    var body: some View {
        NavigationStack(path: $router.path) {
            content()
                .navigationDestination(for: PushedScreen.self) { screen in
                    screen.view
                        // Every pushed screen also gets the push action
                        .environment(\.pushScreen, router.push)
                }
                // ✅ Hook our custom gesture + delegate into the internal UINavigationController
                .installSwipeBack()
        }
        .environment(\.pushScreen, router.push)
        .withAlertManager()
        .withLoaderManager()
        .withLowerToastManager()
        .withUpperToastManager()
    }
}

import SwiftUI

// MARK: - Screen Wrapper
// Hashable box so NavigationStack can store AnyView in its path.
struct PushedScreen: Hashable {
    let id = UUID()
    let view: AnyView

    func hash(into hasher: inout Hasher) { hasher.combine(id) }
    static func == (lhs: PushedScreen, rhs: PushedScreen) -> Bool { lhs.id == rhs.id }
}

// MARK: - Router
final class NavigationRouter: ObservableObject {
    @Published var path = NavigationPath()

    func push(_ view: AnyView) {
        path.append(PushedScreen(view: view))
    }
}

// MARK: - Environment key
private struct PushScreenKey: EnvironmentKey {
    static let defaultValue: (AnyView) -> Void = { _ in }
}

extension EnvironmentValues {
    /// Push any SwiftUI view onto the NavigationStack.
    var pushScreen: (AnyView) -> Void {
        get { self[PushScreenKey.self] }
        set { self[PushScreenKey.self] = newValue }
    }
}


import SwiftUI
import UIKit

// MARK: - Public modifier
// Apply once on your NavigationStack content:
//   NavigationStack { ... }
//       .installSwipeBack()

// MARK: - UIViewRepresentable shim
// Sits invisibly in the background. As soon as it has a window it walks
// up the responder chain to find the UINavigationController that SwiftUI's
// NavigationStack created internally, then hands it to the coordinator.

private struct SwipeBackInstaller: UIViewControllerRepresentable {

    func makeCoordinator() -> SwipeBackCoordinator { SwipeBackCoordinator() }

    func makeUIViewController(context: Context) -> SwipeBackViewController {
        let vc = SwipeBackViewController()
        vc.coordinator = context.coordinator
        return vc
    }

    func updateUIViewController(_ uiViewController: SwipeBackViewController, context: Context) {}
}
// MARK: - PassthroughView
// Waits until it's in the window, then hooks the nav controller.

private final class PassthroughView: UIView {
    var coordinator: SwipeBackCoordinator?

    override func didMoveToWindow() {
        super.didMoveToWindow()
        guard window != nil else { return }
        // Walk up the responder chain until we find a UINavigationController.
        coordinator?.install(on: nearestNavigationController())
    }

    private func nearestNavigationController() -> UINavigationController? {
        var responder: UIResponder? = self
        while let r = responder {
            if let nav = r as? UINavigationController { return nav }
            responder = r.next
        }
        // Fallback: search the window scene
        return window?
            .rootViewController?
            .findNavigationController()
    }
}

private extension UIViewController {
    func findNavigationController() -> UINavigationController? {
        if let nav = self as? UINavigationController { return nav }
        for child in children {
            if let nav = child.findNavigationController() { return nav }
        }
        return nil
    }
}


// MARK: - Public modifier
// Apply once inside your NavigationStack content:
//   NavigationStack { rootView.installSwipeBack() }

extension View {
    func installSwipeBack() -> some View {
        self.background(SwipeBackInstaller())
    }
}

// MARK: - SwipeBackViewController
// Invisible zero-size VC. Its only job is to fire once it's inside the
// NavigationController hierarchy, then hand that nav controller to the coordinator.

final class SwipeBackViewController: UIViewController {
    var coordinator: SwipeBackCoordinator?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Fully transparent — this VC renders nothing.
        view.backgroundColor = .clear
        view.isUserInteractionEnabled = false
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // At this point self.navigationController is SwiftUI's internal
        // UINavigationController — install our gesture + delegate on it.
        coordinator?.install(on: navigationController)
    }
}

// MARK: - Coordinator
// Owns the delegate + gesture for the lifetime of the NavigationStack.


final class SwipeBackCoordinator: NSObject,
                                   UINavigationControllerDelegate,
                                   UIGestureRecognizerDelegate {

    private weak var navController: UINavigationController?
    private var interactiveTransition: UIPercentDrivenInteractiveTransition?

    /// Called once. Guards against re-installation if SwiftUI re-renders.
    func install(on nav: UINavigationController?) {
        guard let nav, navController == nil else { return }
        navController = nav

        // Replace the system interactive pop gesture entirely.
        nav.interactivePopGestureRecognizer?.isEnabled = false
        nav.interactivePopGestureRecognizer?.delegate = nil
        nav.delegate = self

        let gesture = UIScreenEdgePanGestureRecognizer(
            target: self,
            action: #selector(handleEdgePan(_:))
        )
        gesture.edges = .left
        gesture.delegate = self
        nav.view.addGestureRecognizer(gesture)
    }

    // MARK: Edge Pan

    @objc private func handleEdgePan(_ gesture: UIScreenEdgePanGestureRecognizer) {
        guard let nav = navController else { return }
        let progress = max(0, min(1, gesture.translation(in: nav.view).x / nav.view.bounds.width))

        switch gesture.state {
        case .began:
            let t = UIPercentDrivenInteractiveTransition()
            t.wantsInteractiveStart = true  // start paused, driven entirely by update()
            t.completionCurve = .linear     // 1:1 finger-to-progress mapping
            interactiveTransition = t
            nav.popViewController(animated: true)

        case .changed:
            interactiveTransition?.update(progress)

        case .ended:
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

    // MARK: UIGestureRecognizerDelegate

    /// Root screen (count == 1) cannot swipe back — nowhere to go.
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        (navController?.viewControllers.count ?? 0) > 1
    }

    func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWith other: UIGestureRecognizer
    ) -> Bool { true }

    // MARK: UINavigationControllerDelegate

    func navigationController(
        _ navigationController: UINavigationController,
        animationControllerFor operation: UINavigationController.Operation,
        from fromVC: UIViewController,
        to toVC: UIViewController
    ) -> UIViewControllerAnimatedTransitioning? {
        switch operation {
        case .push: return PushSlideTransition()
        case .pop:  return InteractiveSlideTransition()
        default:    return nil
        }
    }

    func navigationController(
        _ navigationController: UINavigationController,
        interactionControllerFor animationController: UIViewControllerAnimatedTransitioning
    ) -> UIViewControllerInteractiveTransitioning? {
        interactiveTransition
    }
}
// MARK: - PushSlideTransition
// Mirror of the pop transition but in reverse:
// incoming screen slides in from the right, outgoing shifts left (parallax).

final class PushSlideTransition: NSObject, UIViewControllerAnimatedTransitioning {

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
            let noop = UIViewPropertyAnimator(duration: transitionDuration(using: context), curve: .easeOut)
            noop.addCompletion { _ in context.completeTransition(false) }
            propertyAnimator = noop
            return noop
        }

        let container = context.containerView
        let width = container.bounds.width
        let height = container.bounds.height

        // toView starts off-screen right; fromView sits at 0
        container.addSubview(toView)
        toView.frame   = CGRect(x: width, y: 0, width: width, height: height)
        fromView.frame = CGRect(x: 0,     y: 0, width: width, height: height)

        // Shadow strip on the left edge of the incoming screen
        let shadowWidth: CGFloat = 24
        let shadow = UIView(frame: CGRect(x: width - shadowWidth, y: 0, width: shadowWidth, height: height))
        shadow.backgroundColor = UIColor.black.withAlphaComponent(0)
        shadow.isUserInteractionEnabled = false
        container.insertSubview(shadow, belowSubview: toView)

        let a = UIViewPropertyAnimator(duration: transitionDuration(using: context), curve: .easeOut) {
            toView.frame.origin.x   = 0                // slide in from right
            fromView.frame.origin.x = -width * 0.3     // parallax: shift left
            shadow.frame.origin.x   = -shadowWidth      // shadow exits left with fromView
            shadow.backgroundColor  = UIColor.black.withAlphaComponent(0.20)
        }

        a.addCompletion { _ in
            shadow.removeFromSuperview()
            // Reset fromView in case transition was cancelled
            fromView.frame.origin.x = 0
            context.completeTransition(!context.transitionWasCancelled)
        }

        propertyAnimator = a
        return a
    }
}

// MARK: - InteractiveSlideTransition
// UIViewPropertyAnimator is required so UIPercentDrivenInteractiveTransition
// can truly pause and scrub (hold-finger-mid-swipe behaviour).
// UIView.animate does not support this.

final class InteractiveSlideTransition: NSObject, UIViewControllerAnimatedTransitioning {

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

        container.insertSubview(toView, belowSubview: fromView)
        toView.frame.origin.x   = -width * 0.3   // parallax: slide in from slightly left
        fromView.frame.origin.x = 0

        // Shadow lives in the container (a plain UITransitionView UIKit owns),
        // not in fromView which is a UIHostingController's view.
        let shadow = UIView(frame: fromView.frame)
        shadow.backgroundColor = .clear
        shadow.isUserInteractionEnabled = false
        container.insertSubview(shadow, aboveSubview: toView)

        let a = UIViewPropertyAnimator(duration: transitionDuration(using: context), curve: .easeOut) {
            fromView.frame.origin.x = width
            toView.frame.origin.x   = 0
            // Keep the shadow glued to the trailing edge of toView as it slides in
            shadow.frame.origin.x   = toView.frame.origin.x + toView.bounds.width
            shadow.backgroundColor  = UIColor.black.withAlphaComponent(0.25)
        }

        a.addCompletion { _ in
            shadow.removeFromSuperview()
            context.completeTransition(!context.transitionWasCancelled)
        }

        propertyAnimator = a
        return a
    }
}
