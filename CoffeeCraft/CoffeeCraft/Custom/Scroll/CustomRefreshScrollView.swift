//
//  CustomRefreshScrollView.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 2/18/26.

import SwiftUI
import UIKit

// ============================================================
// MARK: - CustomRefreshScrollView
// ============================================================
// A pull-to-refresh scroll container. Navigation logic is completely
// absent here — that responsibility belongs to CustomNavigationStack
// and SwipeBackCoordinator.
//
// How it works:
//   A GeometryReader inside the ScrollView measures how far the content
//   has been pulled below its natural top position. When that distance
//   crosses `threshold`, a refresh is triggered. While refreshing, the
//   content is offset downward by `threshold` to make room for the loader.
//
// Usage:
//   CustomRefreshScrollView(onRefresh: {
//       await viewModel.reload()
//   }) {
//       // your scrollable content here
//   }
//
// Without onRefresh the view behaves as a plain ScrollView.
// ============================================================

struct CustomRefreshScrollView<Content: View>: View {
    var showsIndicators: Bool
    // How far the user must pull down (in points) to trigger a refresh.
    var threshold: CGFloat

    // Vertical offset applied to the loader view — use this to nudge the
    // loader below a navigation bar or safe area if needed.
    var loaderOffset: CGFloat

    // The scrollable content, built lazily so it is not evaluated until layout.
    var content: () -> Content

    // The async refresh action. When nil, pull-to-refresh is effectively disabled.
    var onRefresh: (() async -> Void)?

    // --------------------------------------------------------
    // MARK: State
    // --------------------------------------------------------

    // Current pull distance in points (0 when not pulling).
    @State private var offset: CGFloat = 0

    // True from the moment the threshold is crossed until the async task completes.
    @State private var isRefreshing = false

    // Prevents a second refresh from starting while one is already in progress.
    @State private var isLocked = false

    // True while the user's finger is actively dragging downward.
    // Used to distinguish intentional pulls from content bouncing.
    @State private var isDragging = false

    // Prevents the threshold from firing the refresh callback more than once
    // per drag gesture.
    @State private var hasTriggered = false

    // 0.0 → 1.0 progress fed to the loader's internal animation during refresh.
    @State private var animationProgress: CGFloat = 0

    // Controls loader visibility. Separate from isRefreshing so the loader
    // can fade out after isRefreshing returns to false.
    @State private var showLoader = false

    // Timestamp of the last offset update. Used to debounce GeometryReader
    // callbacks which can fire at 120 fps, preventing excessive state updates.
    @State private var lastOffsetUpdate = Date()

    // --------------------------------------------------------
    // MARK: Constants
    // --------------------------------------------------------

    // Medium impact gives tactile confirmation when the threshold is crossed.
    private let haptic = UIImpactFeedbackGenerator(style: .medium)

    // 1/120 second debounce matches the maximum ProMotion display refresh rate.
    // This ensures we process at most one offset update per display frame.
    private let debounce: TimeInterval = 1.0 / 120.0

    // --------------------------------------------------------
    // MARK: Init
    // --------------------------------------------------------

    init(
        showsIndicators: Bool = false,
        threshold: CGFloat = 120,
        loaderOffset: CGFloat = 0,
        @ViewBuilder _ content: @escaping () -> Content,
        onRefresh: (() async -> Void)? = nil
    ) {
        self.showsIndicators = showsIndicators
        self.threshold   = threshold
        self.loaderOffset = loaderOffset
        self.onRefresh   = onRefresh
        self.content     = content
    }

    // --------------------------------------------------------
    // MARK: Body
    // --------------------------------------------------------

    var body: some View {
        ZStack(alignment: .top) {

            ScrollView(showsIndicators: showsIndicators) {
                content()
                    // While refreshing, push all content down by `threshold`
                    // to create space for the loader above it.
                    .offset(y: isRefreshing ? threshold : 0)
                    .background(
                        // GeometryReader sits behind the content (zero height, zero impact).
                        // It reads the content's Y position in the named coordinate space
                        // and triggers offset tracking on every layout pass.
                        GeometryReader { geo -> Color in
                            let y = geo.frame(in: .named("scroll")).minY
                            DispatchQueue.main.async {
                                let now = Date()
                                // Debounce: skip if not enough time has passed since last update.
                                guard now.timeIntervalSince(lastOffsetUpdate) >= debounce else { return }
                                lastOffsetUpdate = now
                                handleOffset(y)
                            }
                            return .clear
                        }
                    )
            }
            // Disable scrolling while locked (during active refresh) so the
            // user cannot scroll past the loader or cause a second pull.
            .scrollDisabled(isLocked)
            // Name the coordinate space so GeometryReader can measure
            // positions relative to the ScrollView's own frame.
            .coordinateSpace(name: "scroll")
            .simultaneousGesture(
                // Runs alongside the ScrollView's built-in pan gesture.
                // We only care about downward vertical drags (isDragging flag).
                // Horizontal drags are ignored — those belong to the
                // UIScreenEdgePanGestureRecognizer in SwipeBackCoordinator.
                DragGesture(minimumDistance: 5)
                    .onChanged { value in
                        guard abs(value.translation.height) > abs(value.translation.width) else { return }
                        if !isDragging { isDragging = true; hasTriggered = false }
                    }
                    .onEnded { _ in
                        isDragging = false
                        // If we're not currently refreshing, snap offset and loader back.
                        guard !isRefreshing else { return }
                        withAnimation(.easeOut(duration: 0.25)) { offset = 0; showLoader = false }
                    }
            )

            // Loader is shown as soon as the user begins pulling (offset > 10)
            // and hidden after the refresh completes with a short delay.
            // guarded by onRefresh != nil so it never shows on non-refreshable lists.
            if (showLoader || isRefreshing) && onRefresh != nil {
                CoffeeLoaderView(
                    // During active pull: progress is the fraction of threshold reached.
                    // During refresh:     progress counts down from 1 as the animation plays.
                    progress: isRefreshing
                        ? (1 - animationProgress)
                        : min(max(offset, 0) / threshold, 1),
                    imageSize: 50
                )
                .offset(y: loaderOffset)
                .transition(.opacity)
            }
        }
    }

    // --------------------------------------------------------
    // MARK: Offset Handling
    // Called on every debounced GeometryReader update.
    //
    // Three distinct states:
    //   1. Dragging downward (value > 0) — track offset and trigger if threshold crossed
    //   2. Dragging back up  (value ≤ 0) — reset offset and hide loader
    //   3. Not dragging, offset is non-zero — snap back (handles bounce/momentum)
    // --------------------------------------------------------

    private func handleOffset(_ value: CGFloat) {
        if isDragging && !isRefreshing && !isLocked {
            if value > 0 {
                offset = value

                // Show the loader as soon as there's a meaningful pull (10pt buffer
                // prevents the loader from flickering on tiny accidental movements).
                if value > 10 && !showLoader {
                    withAnimation(.easeIn(duration: 0.15)) { showLoader = true }
                }

                // Cross the threshold → fire the refresh exactly once per gesture.
                if value > threshold && !hasTriggered && onRefresh != nil {
                    hasTriggered = true
                    triggerRefresh()
                }
            } else {
                // User pulled down but then scrolled back up without crossing threshold.
                offset = 0
                if !isRefreshing { withAnimation(.easeOut(duration: 0.2)) { showLoader = false } }
            }
        } else if !isRefreshing && !isLocked && !isDragging && offset != 0 {
            // Content bounced or finger lifted — snap offset back to zero.
            withAnimation(.easeInOut(duration: 0.2)) { offset = 0; showLoader = false }
        }
    }

    // --------------------------------------------------------
    // MARK: Trigger Refresh
    // Locks the scroll view, snaps content offset to threshold,
    // runs the async callback, then unwinds all state.
    // --------------------------------------------------------

    private func triggerRefresh() {
        guard !isRefreshing && !isLocked else { return }

        // Prepare and fire haptic before the async work begins.
        haptic.prepare(); haptic.impactOccurred()

        isRefreshing = true
        isLocked     = true
        showLoader   = true

        // Spring the content down to the threshold position to "lock" the loader
        // in place while the refresh runs. Feels snappy, not mechanical.
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) { offset = threshold }

        Task {
            // Start the loader's internal animation concurrently with the refresh work.
            withAnimation(.easeInOut(duration: 1.2)) { animationProgress = 1.0 }

            // Run the caller's async refresh work.
            await onRefresh?()

            // Spring everything back to the resting state.
            withAnimation(.spring(response: 0.4, dampingFraction: 0.9)) {
                isRefreshing    = false
                offset          = 0
                animationProgress = 0
            }

            // Brief pause so the loader's exit animation plays before it disappears.
            try await MinimumLoadingTime(0.3).waitIfNeeded()

            withAnimation(.easeOut(duration: 0.2)) { showLoader = false }

            // Unlock last so scrolling only re-enables after all animations settle.
            isLocked     = false
            hasTriggered = false
        }
    }
}
