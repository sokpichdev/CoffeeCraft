import SwiftUI
import UIKit

// ============================================================
// MARK: HOW TO USE
// ============================================================
//
// 1. In your @main App, replace WindowGroup content with AppRootView:
//
//    @main
//    struct MyApp: App {
//        var body: some Scene {
//            WindowGroup {
//                AppRootView {
//                    HomeScreen()        // ← your root screen
//                }
//            }
//        }
//    }
//
// 2. On every screen (root + children), use CustomRefreshScrollView
//    as your scroll container:
//
//    struct HomeScreen: View {
//        var body: some View {
//            CustomRefreshScrollView(onRefresh: {
//                await viewModel.reload()
//            }) {
//                // your content here
//            }
//        }
//    }
//
// 3. To push a child screen, read the environment action:
//
//    @Environment(\.pushScreen) var push
//    ...
//    Button("Open Detail") { push(AnyView(DetailScreen())) }
//
// 4. The root screen cannot swipe back (nothing to go back to).
//    Child screens automatically get the interactive swipe-back.
//
// ============================================================

// MARK: - AppRootView
// Use this as the single root of your window.
// It owns the UINavigationController so the delegate is never overwritten.

struct AppRootView<Root: View>: UIViewControllerRepresentable {
    let root: () -> Root

    init(@ViewBuilder _ root: @escaping () -> Root) {
        self.root = root
    }

    func makeUIViewController(context: Context) -> AppNavigationController {
        let nav = AppNavigationController()
        let rootVC = Self.makeHostingVC(for: AnyView(root()), nav: nav)
        nav.setViewControllers([rootVC], animated: false)
        return nav
    }

    func updateUIViewController(_ nav: AppNavigationController, context: Context) {}

    /// Wraps any SwiftUI view in a hosting controller, injecting the push action.
    static func makeHostingVC(for view: AnyView, nav: AppNavigationController) -> UIViewController {
        let enriched = view.environment(\.pushScreen) { destination in
            let vc = makeHostingVC(for: destination, nav: nav)
            nav.pushViewController(vc, animated: true)
        }
        let hc = UIHostingController(rootView: enriched)
        hc.view.backgroundColor = .systemBackground
        return hc
    }
}


// MARK: - AppNavigationController
// One nav controller, one delegate, one edge-pan gesture — set up once and never stolen.

final class AppNavigationController: UINavigationController,
                                      UINavigationControllerDelegate
                                      /*UIGestureRecognizerDelegate*/ {

    private var interactiveTransition: UIPercentDrivenInteractiveTransition?

    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        navigationBar.isHidden = true

        // Disable the system interactive pop — we replace it entirely.
        interactivePopGestureRecognizer?.isEnabled = false
        interactivePopGestureRecognizer?.delegate = nil

        setupEdgePanGesture()
    }

    // MARK: Edge Pan Setup

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
            // gestureRecognizerShouldBegin already blocks this on the root screen.
            let t = UIPercentDrivenInteractiveTransition()
            t.wantsInteractiveStart = true   // start paused, wait for update() calls
            t.completionCurve = .linear      // finger position maps 1:1 to progress
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

    // MARK: UIGestureRecognizerDelegate

    /// Blocks swipe-back on the root (parent) screen — nothing to go back to.
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return viewControllers.count > 1
    }

    func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWith other: UIGestureRecognizer
    ) -> Bool {
        return true
    }

    // MARK: UINavigationControllerDelegate

    func navigationController(
        _ navigationController: UINavigationController,
        animationControllerFor operation: UINavigationController.Operation,
        from fromVC: UIViewController,
        to toVC: UIViewController
    ) -> UIViewControllerAnimatedTransitioning? {
        // Custom transition only for pop; push stays default.
        return operation == .pop ? InteractiveSlideTransition() : nil
    }

    func navigationController(
        _ navigationController: UINavigationController,
        interactionControllerFor animationController: UIViewControllerAnimatedTransitioning
    ) -> UIViewControllerInteractiveTransitioning? {
        return interactiveTransition
    }
}

// MARK: - CustomRefreshScrollView
// Pull-to-refresh only. Navigation logic lives entirely in AppNavigationController.

struct CustomRefreshScrollView<Content: View>: View {
    var threshold: CGFloat = 120
    var loaderOffset: CGFloat = 0
    var content: () -> Content
    var onRefresh: (() async -> Void)?
    
    @State private var offset: CGFloat = 0
    @State private var isRefreshing = false
    @State private var isLocked = false
    @State private var isDragging = false
    @State private var hasTriggered = false
    @State private var animationProgress: CGFloat = 0
    @State private var showLoader = false
    @State private var lastOffsetUpdate = Date()

    private let haptic = UIImpactFeedbackGenerator(style: .medium)
    private let debounce: TimeInterval = 1.0 / 120.0

    init(
        threshold: CGFloat = 120,
        loaderOffset: CGFloat = 0,
        @ViewBuilder _ content: @escaping () -> Content,
        onRefresh: (() async -> Void)? = nil
    ) {
        self.threshold = threshold
        self.loaderOffset = loaderOffset
        self.onRefresh = onRefresh
        self.content = content
    }

    var body: some View {
        ZStack(alignment: .top) {
            ScrollView {
                content()
                    .offset(y: isRefreshing ? threshold : 0)
                    .background(
                        GeometryReader { geo -> Color in
                            let y = geo.frame(in: .named("scroll")).minY
                            DispatchQueue.main.async {
                                let now = Date()
                                guard now.timeIntervalSince(lastOffsetUpdate) >= debounce else { return }
                                lastOffsetUpdate = now
                                handleOffset(y)
                            }
                            return .clear
                        }
                    )
            }
            .scrollDisabled(isLocked)
            .coordinateSpace(name: "scroll")
            .simultaneousGesture(
                DragGesture(minimumDistance: 5)
                    .onChanged { v in
                        // Ignore horizontal drags — the edge-pan gesture owns those.
                        guard abs(v.translation.height) > abs(v.translation.width) else { return }
                        if !isDragging { isDragging = true; hasTriggered = false }
                    }
                    .onEnded { _ in
                        isDragging = false
                        guard !isRefreshing else { return }
                        withAnimation(.easeOut(duration: 0.25)) { offset = 0; showLoader = false }
                    }
            )

            if (showLoader || isRefreshing) && onRefresh != nil {
                // ↓ Replace with your own loader view
                CoffeeLoaderView(
                    progress: isRefreshing ? (1 - animationProgress) : min(max(offset, 0) / threshold, 1),
                    imageSize: 50
                )
                .transition(.opacity)
            }
        }
    }

    private func handleOffset(_ value: CGFloat) {
        if isDragging && !isRefreshing && !isLocked {
            if value > 0 {
                offset = value
                if value > 10 && !showLoader {
                    withAnimation(.easeIn(duration: 0.15)) { showLoader = true }
                }
                if value > threshold && !hasTriggered && onRefresh != nil {
                    hasTriggered = true
                    triggerRefresh()
                }
            } else {
                offset = 0
                if !isRefreshing { withAnimation(.easeOut(duration: 0.2)) { showLoader = false } }
            }
        } else if !isRefreshing && !isLocked && !isDragging && offset != 0 {
            withAnimation(.easeInOut(duration: 0.2)) { offset = 0; showLoader = false }
        }
    }

    private func triggerRefresh() {
        guard !isRefreshing && !isLocked else { return }
        haptic.prepare(); haptic.impactOccurred()

        isRefreshing = true; isLocked = true; showLoader = true
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) { offset = threshold }

        Task {
            withAnimation(.easeInOut(duration: 1.2)) { animationProgress = 1.0 }
            await onRefresh?()
            withAnimation(.spring(response: 0.4, dampingFraction: 0.9)) {
                isRefreshing = false; offset = 0; animationProgress = 0
            }
            try? await Task.sleep(nanoseconds: 300_000_000)
            withAnimation(.easeOut(duration: 0.2)) { showLoader = false }
            isLocked = false; hasTriggered = false
        }
    }
}


// ============================================================
// MARK: - Example Screens (delete before shipping)
// ============================================================

/*
@main
struct ExampleApp: App {
    var body: some Scene {
        WindowGroup {
            AppRootView {
                HomeScreen()
            }
        }
    }
}

struct HomeScreen: View {
    @Environment(\.pushScreen) var push

    var body: some View {
        CustomRefreshScrollView(onRefresh: {
            try? await Task.sleep(nanoseconds: 1_500_000_000)
        }) {
            VStack(spacing: 24) {
                Text("Home — root screen").font(.title2).bold()
                Text("Swipe-back is disabled here (nowhere to go)").foregroundStyle(.secondary)
                Button("Open Detail →") { push(AnyView(DetailScreen())) }
                    .buttonStyle(.borderedProminent)
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 60)
        }
    }
}

struct DetailScreen: View {
    @Environment(\.pushScreen) var push

    var body: some View {
        CustomRefreshScrollView(onRefresh: {
            try? await Task.sleep(nanoseconds: 1_000_000_000)
        }) {
            VStack(spacing: 24) {
                Text("Detail — child screen").font(.title2).bold()
                Text("Swipe left edge to go back — hold mid-swipe ✓").foregroundStyle(.secondary)
                Button("Go deeper →") { push(AnyView(DeepScreen())) }
                    .buttonStyle(.bordered)
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 60)
        }
    }
}

struct DeepScreen: View {
    var body: some View {
        CustomRefreshScrollView {
            VStack(spacing: 16) {
                Text("Deep screen").font(.title2).bold()
                Text("Swipe back works here too").foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 60)
        }
    }
}
*/
