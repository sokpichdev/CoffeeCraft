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
            scrollPosition = items.count * centerOffset
        }
        .task(id: isUserDragging) {
            guard !isUserDragging, !items.isEmpty else { return }
            do {
                try await Task.sleep(for: .seconds(5))
                while !Task.isCancelled {
                    try await Task.sleep(for: .seconds(3))
                    guard let current = scrollPosition else { continue }
                    withAnimation(.easeInOut(duration: 0.3)) {
                        scrollPosition = current + 1
                    }
                }
            } catch {}
        }
        .onChange(of: scrollPosition) { _, newValue in
            guard let newValue, !items.isEmpty else { return }
            currentIndex = newValue % items.count
            recenterIfNeeded(newValue)
        }
        .gesture(
            DragGesture()
                .onChanged { _ in
                    isUserDragging = true
                }
                .onEnded { _ in
                    isUserDragging = false
                }
        )
    }

    // MARK: - Infinite Loop Logic

    private func recenterIfNeeded(_ index: Int) {
        let count = items.count

        let middleStart = count * centerOffset
        let middleEnd = middleStart + count

        if index < middleStart || index >= middleEnd {
            let delay: TimeInterval = isUserDragging ? 0.0 : 0.31
            Task {
                if delay > 0 {
                    try? await Task.sleep(for: .seconds(delay))
                }
                let remainder = index % count
                let centeredIndex = middleStart + remainder
                if scrollPosition != centeredIndex {
                    scrollPosition = centeredIndex
                }
            }
        }
    }
}
