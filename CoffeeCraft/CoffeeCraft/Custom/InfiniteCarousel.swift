//
//  InfiniteCarousel.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 12/17/25.
//
import SwiftUI

struct InfiniteCarousel<Content: View, T: Hashable>: View {
    let items: [T]
    let height: CGFloat
    let width: CGFloat
    @Binding var currentIndex: Int
    @ViewBuilder let content: (T) -> Content
    
    @State private var scrollPosition: Int?
    @State private var timer: Timer?
    @State private var restartWorkItem: DispatchWorkItem?
    @State private var isUserDragging = false

    // MARK: - Dynamic Configuration
    // If <= 5 items, use 5 sets (25 items max). If > 5 items, 3 sets is plenty of buffer.
    private var multiplier: Int {
        items.count <= 5 ? 5 : 3
    }
    
    private var repeatedItems: [T] {
        Array(repeating: items, count: multiplier).flatMap { $0 }
    }
    
    private var centerOffset: Int {
        multiplier / 2 // Returns 2 for multiplier 5, or 1 for multiplier 3
    }

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 0) {
                ForEach(repeatedItems.indices, id: \.self) { index in
                    content(repeatedItems[index])
                        .frame(width: width, height: height)
                        .id(index)
                }
            }
            .scrollTargetLayout()
        }
        .scrollPosition(id: $scrollPosition)
        .scrollTargetBehavior(.paging)
        .frame(height: height)
        .background(Color.textPrimary)
        .onAppear {
            // Dynamically start in the middle set
            scrollPosition = items.count * centerOffset
            scheduleAutoScrollRestart()
        }
        .onChange(of: scrollPosition) { _, newValue in
            guard let newValue, !items.isEmpty else { return }
            currentIndex = newValue % items.count
            recenterIfNeeded(newValue)
        }
        .onDisappear {
            stopAutoScroll()
            cancelRestart()
        }
        .gesture(
            DragGesture()
                .onChanged { _ in
                    isUserDragging = true
                    stopAutoScroll()
                    cancelRestart()
                }
                .onEnded { _ in
                    isUserDragging = false
                    scheduleAutoScrollRestart()
                }
        )
    }

    // MARK: - Auto Scroll
    
    private func startAutoScroll() {
        stopAutoScroll()
        timer = Timer.scheduledTimer(withTimeInterval: 3, repeats: true) { _ in
            guard !isUserDragging, let current = scrollPosition else { return }
            // Ensure the UI update happens on the main thread
            DispatchQueue.main.async {
                withAnimation(.easeInOut(duration: 0.3)) {
                    scrollPosition = current + 1
                }
            }
        }
    }

    private func stopAutoScroll() {
        timer?.invalidate()
        timer = nil
    }

    // MARK: - Delayed Restart

    private func scheduleAutoScrollRestart() {
        cancelRestart()

        let workItem = DispatchWorkItem {
            startAutoScroll()
        }

        restartWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 5, execute: workItem)
    }

    private func cancelRestart() {
        restartWorkItem?.cancel()
        restartWorkItem = nil
    }

    // MARK: - Infinite Loop Logic
    
    private func recenterIfNeeded(_ index: Int) {
            let count = items.count
            
            // Define the "Safe Zone" (The middle set)
            let middleStart = count * centerOffset
            let middleEnd = middleStart + count

            // If user exits the middle set, we snap them back
            if index < middleStart || index >= middleEnd {
                let delay = isUserDragging ? 0.0 : 0.31
                
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                    let remainder = index % count
                    let centeredIndex = middleStart + remainder
                    
                    // Silent snap to the corresponding item in the middle set
                    if scrollPosition != centeredIndex {
                        scrollPosition = centeredIndex
                    }
                }
            }
        }
}
