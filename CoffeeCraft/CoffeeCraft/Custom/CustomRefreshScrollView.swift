//
//  CustomRefreshScrollView.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 2/18/26.
//
import SwiftUI
struct CustomRefreshScrollView<Content: View>: View {
    
    var threshold: CGFloat = 140
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
    private let hapticGenerator = UIImpactFeedbackGenerator(style: .medium)
    
    init(
        threshold: CGFloat = 140,
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
            ScrollView(showsIndicators: false) {
                content()
                    .offset(y: isRefreshing ? threshold * animationProgress : 0)
                    .overlay(
                        GeometryReader { geo in
                            let currentY = geo.frame(in: .named("SCROLL")).minY
                            Color.clear
                                .preference(key: ScrollOffsetPreferenceKey.self, value: currentY)
                        }
                        .frame(height: 0),
                        alignment: .top
                    )
            }
            .scrollDisabled(isLocked)
            .coordinateSpace(name: "SCROLL")
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        // Only handle vertical drags (ignore horizontal swipes for navigation)
                        let horizontalAmount = abs(value.translation.width)
                        let verticalAmount = abs(value.translation.height)
                        
                        // If horizontal movement is greater, let navigation handle it
                        if horizontalAmount > verticalAmount {
                            return
                        }
                        
                        if !isDragging {
                            isDragging = true
                            hasTriggered = false
                        }
                    }
                    .onEnded { value in
                        isDragging = false
                        hasTriggered = false
                        
                        // Reset offset if not refreshing
                        if !isRefreshing {
                            withAnimation(.easeOut(duration: 0.3)) {
                                offset = 0
                                showLoader = false
                            }
                        }
                    }
            )
            .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                // Only update offset when user is dragging and not refreshing
                if isDragging && !isRefreshing && !isLocked {
                    if value > 0 {
                        offset = value
                        
                        // Show loader with animation when pulling starts
                        if value > 5 && !showLoader {
                            withAnimation(.easeIn(duration: 0.2)) {
                                showLoader = true
                            }
                        }
                        
                        // Trigger refresh immediately when threshold is crossed while dragging
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
                } else if !isRefreshing && !isLocked && !isDragging {
                    if offset != 0 {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            offset = 0
                            showLoader = false
                        }
                    }
                }
            }
            
            // Sticky loader at the top with animation
            if (showLoader || isRefreshing) && onRefresh != nil {
                VStack {
                    CoffeeLoaderView(
                        progress: isRefreshing ? (1 - animationProgress) : min(offset / threshold, 1),
                        imageSize: 50
                    )
                    .offset(y: loaderOffset)
//                    .frame(height: isRefreshing ? threshold : min(offset, threshold))
                    .transition(.move(edge: .top).combined(with: .opacity))
                    
                    Spacer()
                }
            }
        }
    }
    
    private func triggerRefresh() {
        guard !isRefreshing && !isLocked else { return }
        
        hapticGenerator.prepare()
        hapticGenerator.impactOccurred()
        
        isRefreshing = true
        isLocked = true
        showLoader = true
        
        // Snap offset to threshold position
        withAnimation(.easeOut(duration: 0.2)) {
            offset = threshold
        }
        
        Task {
            // Animate the coffee emptying and content pushing up
            withAnimation(.easeInOut(duration: 1.5)) {
                animationProgress = 1.0
            }
            
            // Now perform the actual refresh
            await onRefresh?()
            
            // Reset everything
            withAnimation(.spring(response: 0.4, dampingFraction: 1.5)) {
                isRefreshing = false
                offset = 0
                animationProgress = 0
            }
            
            try await MinimumLoadingTime(0.4).waitIfNeeded()
            
            withAnimation(.easeOut(duration: 0.2)) {
                showLoader = false
            }
            isLocked = false
            hasTriggered = false
        }
    }
}
