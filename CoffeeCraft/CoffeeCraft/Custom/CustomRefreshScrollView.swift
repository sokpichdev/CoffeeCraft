import SwiftUI

// MARK: - Main Component
struct CustomRefreshScrollView<Content: View>: View {
    @Environment(\.dismiss) var dismiss
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
    @State private var isEdgeSwipe = false
    @State private var lastOffsetUpdate = Date()
    
    private let hapticGenerator = UIImpactFeedbackGenerator(style: .medium)
    private let edgeThreshold: CGFloat = 20
    private let debounceInterval: TimeInterval = 1/120
    
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
                    .background(
                        GeometryReader { geo -> Color in
                            let currentY = geo.frame(in: .named("scrollSpace")).minY
                            
                            DispatchQueue.main.async {
                                let now = Date()
                                if now.timeIntervalSince(lastOffsetUpdate) >= debounceInterval {
                                    lastOffsetUpdate = now
                                    handleOffsetChange(currentY)
                                }
                            }
                            return Color.clear
                        }
                    )
                    .offset(y: isRefreshing ? threshold : 0)
            }
            .scrollDisabled(isLocked || isEdgeSwipe)
            .coordinateSpace(name: "scrollSpace")
            .simultaneousGesture(
                DragGesture(minimumDistance: 5)
                    .onChanged { value in
                        let horizontalAmount = value.translation.width
                        let verticalAmount = value.translation.height
                        let startX = value.startLocation.x
                        
                        if !isEdgeSwipe && startX < edgeThreshold && horizontalAmount > 0 {
                            isEdgeSwipe = true
                        }
                        
                        if isEdgeSwipe && horizontalAmount > 30 && !isRefreshing {
                            triggerNavigationBack()
                            return
                        }
                        
                        if abs(horizontalAmount) > abs(verticalAmount) && !isEdgeSwipe {
                            return
                        }
                        
                        if !isDragging && !isEdgeSwipe {
                            isDragging = true
                            hasTriggered = false
                        }
                    }
                    .onEnded { _ in
                        isDragging = false
                        isEdgeSwipe = false
                        
                        if !isRefreshing {
                            withAnimation(.easeOut(duration: 0.25)) {
                                offset = 0
                                showLoader = false
                            }
                        }
                    }
            )
            
            if (showLoader || isRefreshing) && onRefresh != nil && !isEdgeSwipe {
                CoffeeLoaderView(
                    progress: isRefreshing ? (1 - animationProgress) : min(max(offset, 0) / threshold, 1),
                    imageSize: 50
                )
//                .offset(y: loaderOffset + (isRefreshing ? threshold : min(offset, threshold)))
//                .transition(.asymmetric(
//                    insertion: .move(edge: .top).combined(with: .opacity),
//                    removal: .opacity
//                ))
                .transition(.opacity)
            }
        }
    }
    
    private func handleOffsetChange(_ value: CGFloat) {
        guard !isEdgeSwipe else { return }
        
        if isDragging && !isRefreshing && !isLocked {
            if value > 0 {
                offset = value
                
                if value > 10 && !showLoader {
                    withAnimation(.easeIn(duration: 0.15)) {
                        showLoader = true
                    }
                }
                
                if value > threshold && !hasTriggered && onRefresh != nil {
                    hasTriggered = true
                    triggerRefresh()
                }
            } else {
                offset = 0
                if !isRefreshing {
                    withAnimation(.easeOut(duration: 0.2)) {
                        showLoader = false
                    }
                }
            }
        } else if !isRefreshing && !isLocked && !isDragging && offset != 0 {
            withAnimation(.easeInOut(duration: 0.2)) {
                offset = 0
                showLoader = false
            }
        }
    }
    
    private func triggerNavigationBack() {
        let impact = UIImpactFeedbackGenerator(style: .light)
        impact.impactOccurred()
        dismiss()
    }
    
    private func triggerRefresh() {
        guard !isRefreshing && !isLocked else { return }
        
        hapticGenerator.prepare()
        hapticGenerator.impactOccurred()
        
        isRefreshing = true
        isLocked = true
        showLoader = true
        
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            offset = threshold
        }
        
        Task {
            withAnimation(.easeInOut(duration: 1.2)) {
                animationProgress = 1.0
            }
            
            await onRefresh?()
            
            withAnimation(.spring(response: 0.4, dampingFraction: 0.9)) {
                isRefreshing = false
                offset = 0
                animationProgress = 0
            }
            
            try? await Task.sleep(nanoseconds: 300_000_000)
            
            withAnimation(.easeOut(duration: 0.2)) {
                showLoader = false
            }
            isLocked = false
            hasTriggered = false
        }
    }
}

// MARK: - Type-erased wrapper to avoid generic issues
struct AnyRefreshableView: View {
    let view: AnyView
    let onRefresh: (() async -> Void)?
    
    init<Content: View>(content: Content, onRefresh: (() async -> Void)?) {
        self.view = AnyView(
            CustomRefreshScrollView(
                threshold: 120,
                { content },
                onRefresh: onRefresh
            )
        )
        self.onRefresh = onRefresh
    }
    
    var body: some View {
        view
    }
}

// MARK: - UIViewControllerRepresentable
struct NavigableScrollView<Content: View>: UIViewControllerRepresentable {
    @ViewBuilder var content: Content
    var onRefresh: (() async -> Void)?
    
    func makeUIViewController(context: Context) -> NavigableScrollViewController {
        let vc = NavigableScrollViewController()
        vc.updateContent(content, onRefresh: onRefresh)
        return vc
    }
    
    func updateUIViewController(_ uiViewController: NavigableScrollViewController, context: Context) {
        uiViewController.updateContent(content, onRefresh: onRefresh)
    }
}

// MARK: - UIViewController (non-generic)
class NavigableScrollViewController: UIViewController, UIGestureRecognizerDelegate, UINavigationControllerDelegate {
    
    private var hostingController: UIHostingController<AnyRefreshableView>?
    private var scrollView: UIScrollView!
    private var currentOnRefresh: (() async -> Void)?
    
    private var interactiveTransition: UIPercentDrivenInteractiveTransition?
    private var edgePanGesture: UIScreenEdgePanGestureRecognizer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupScrollView()
        setupEdgePanGesture()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.delegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if navigationController?.delegate === self {
            navigationController?.delegate = nil
        }
    }
    
    func updateContent<Content: View>(_ content: Content, onRefresh: (() async -> Void)?) {
        self.currentOnRefresh = onRefresh
        
        // Remove old hosting controller
        hostingController?.willMove(toParent: nil)
        hostingController?.view.removeFromSuperview()
        hostingController?.removeFromParent()
        
        // Create new hosting controller with type-erased view
        let refreshableView = AnyRefreshableView(content: content, onRefresh: onRefresh)
        let newHostingController = UIHostingController(rootView: refreshableView)
        hostingController = newHostingController
        
        addChild(newHostingController)
        scrollView.addSubview(newHostingController.view)
        newHostingController.view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            newHostingController.view.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            newHostingController.view.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            newHostingController.view.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            newHostingController.view.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            newHostingController.view.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor)
        ])
        
        newHostingController.didMove(toParent: self)
    }
    
    private func setupScrollView() {
        scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.alwaysBounceVertical = true
        
        view.addSubview(scrollView)
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupEdgePanGesture() {
        let edgePan = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(handleEdgePan(_:)))
        edgePan.edges = .left
        edgePan.delegate = self
        view.addGestureRecognizer(edgePan)
        edgePanGesture = edgePan
    }
    
    @objc private func handleEdgePan(_ gesture: UIScreenEdgePanGestureRecognizer) {
        let translation = gesture.translation(in: view)
        let progress = max(0, min(1, translation.x / view.bounds.width * 0.5))
        
        switch gesture.state {
        case .began:
            guard let nav = navigationController else { return }
            
            let transition = UIPercentDrivenInteractiveTransition()
            interactiveTransition = transition
            
            nav.delegate = self
            nav.popViewController(animated: true)
            
        case .changed:
            interactiveTransition?.update(progress)
            
        case .ended, .cancelled:
            let velocity = gesture.velocity(in: view).x
            
            if progress > 0.4 || velocity > 800 {
                interactiveTransition?.finish()
            } else {
                interactiveTransition?.cancel()
            }
            interactiveTransition = nil
            
        default:
            interactiveTransition?.cancel()
            interactiveTransition = nil
        }
    }
    
    // MARK: - UIGestureRecognizerDelegate
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    // MARK: - UINavigationControllerDelegate
    func navigationController(
        _ navigationController: UINavigationController,
        animationControllerFor operation: UINavigationController.Operation,
        from fromVC: UIViewController,
        to toVC: UIViewController
    ) -> UIViewControllerAnimatedTransitioning? {
        
        if operation == .pop {
            return SlideTransition(direction: .pop)
        }
        return nil
    }
    
    func navigationController(
        _ navigationController: UINavigationController,
        interactionControllerFor animationController: UIViewControllerAnimatedTransitioning
    ) -> UIViewControllerInteractiveTransitioning? {
        
        return interactiveTransition
    }
}

// MARK: - Custom Animated Transition
class SlideTransition: NSObject, UIViewControllerAnimatedTransitioning {
    enum Direction { case push, pop }
    let direction: Direction
    
    init(direction: Direction) {
        self.direction = direction
        super.init()
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.35
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromView = transitionContext.view(forKey: .from),
              let toView = transitionContext.view(forKey: .to) else {
            transitionContext.completeTransition(false)
            return
        }
        
        let container = transitionContext.containerView
        let duration = transitionDuration(using: transitionContext)
        
        if direction == .pop {
            container.addSubview(toView)
            container.addSubview(fromView)
            
            toView.frame.origin.x = -container.bounds.width * 0.3
            fromView.frame.origin.x = 0
            
            UIView.animate(withDuration: duration, delay: 0, options: .curveEaseOut, animations: {
                fromView.frame.origin.x = container.bounds.width
                toView.frame.origin.x = 0
            }) { _ in
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            }
        }
    }
}
