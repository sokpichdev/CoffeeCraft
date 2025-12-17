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
    @State private var isUserScrolling = false
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 0) { // Using LazyHStack for true infinite scroll
                ForEach(0..<Int.max, id: \.self) { index in
                    let actualIndex = index % items.count
                    content(items[actualIndex])
                        .frame(width: width, height: height)
                        .id(index)
                }
            }
            .scrollTargetLayout()
        }
        .scrollPosition(id: $scrollPosition)
        .scrollTargetBehavior(.paging)
        .frame(height: height)
        .onChange(of: scrollPosition) { oldValue, newValue in
            guard let newValue = newValue else { return }
            currentIndex = newValue % items.count
            isUserScrolling = false
        }
        .onAppear {
            // Start at a large middle point for infinite scrolling
            scrollPosition = 1000 * items.count + currentIndex
            startAutoScroll()
        }
        .onDisappear {
            stopAutoScroll()
        }
        .gesture(
            DragGesture()
                .onChanged { _ in
                    isUserScrolling = true
                    stopAutoScroll()
                }
                .onEnded { _ in
                    startAutoScroll()
                }
        )
    }
    
    private func startAutoScroll() {
        stopAutoScroll()
        
        timer = Timer.scheduledTimer(withTimeInterval: 3, repeats: true) { _ in
            if !isUserScrolling {
                withAnimation(.easeInOut(duration: 0.3)) {
                    if let current = scrollPosition {
                        scrollPosition = current + 1
                    }
                }
            }
        }
    }
    
    private func stopAutoScroll() {
        timer?.invalidate()
        timer = nil
    }
}
