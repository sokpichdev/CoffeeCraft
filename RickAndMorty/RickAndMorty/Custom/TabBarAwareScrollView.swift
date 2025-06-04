//
//  TabBarAwareScrollView.swift
//  RickAndMorty
//
//  Created by Sok Pich on 6/4/25.
//
import SwiftUI

struct TabBarAwareScrollView<T: ObservableObject, Content: View>: View {
    @EnvironmentObject var tabBarManager: TabBarVisibilityManager
    @ObservedObject var viewModel: T
    @Binding var searchQuery: String

    let content: Content
    let directionChangeThreshold: CGFloat
    let updateInterval: TimeInterval
    let onSearchQueryChange: (() -> Void)?

    @State private var lastScrollOffset: CGFloat = 0
    @State private var scrollDirection: String = "Idle"
    @State private var isDragging: Bool = false
    @State private var lastUpdateTime = Date.distantPast

    init(
        viewModel: T,
        searchQuery: Binding<String>,
        directionChangeThreshold: CGFloat = 10,
        updateInterval: TimeInterval = 0.1,
        onSearchQueryChange: (() -> Void)? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.viewModel = viewModel
        self._searchQuery = searchQuery
        self.directionChangeThreshold = directionChangeThreshold
        self.updateInterval = updateInterval
        self.onSearchQueryChange = onSearchQueryChange
        self.content = content()
    }

    var body: some View {
        ScrollView {
            GeometryReader { geo in
                let offset = geo.frame(in: .global).minY

                Color.clear
                    .onAppear { lastScrollOffset = offset }
                    .onChange(of: offset) { newOffset, _ in
                        guard isDragging else { return }
                        guard newOffset <= -10 else { return }

                        let now = Date()
                        if now.timeIntervalSince(lastUpdateTime) < updateInterval {
                            return
                        }

                        lastUpdateTime = now
                        let delta = newOffset - lastScrollOffset

                        let hideTabBarThreshold: CGFloat = -directionChangeThreshold
                        let showTabBarThreshold: CGFloat = directionChangeThreshold

                        var shouldShowTabBar = false
                        var shouldHideTabBar = false

                        if delta > showTabBarThreshold && scrollDirection != "Scrolling Up" {
                            shouldShowTabBar = true
                        } else if delta < hideTabBarThreshold && scrollDirection != "Scrolling Down" {
                            shouldHideTabBar = true
                        }

                        if shouldShowTabBar || shouldHideTabBar {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                if shouldShowTabBar {
                                    scrollDirection = "Scrolling Up"
                                    tabBarManager.isVisible = true
                                } else if shouldHideTabBar {
                                    scrollDirection = "Scrolling Down"
                                    tabBarManager.isVisible = false
                                }
                                lastScrollOffset = newOffset
                            }
                        }
                    }
            }
            .frame(height: 0)

            content
        }
        .simultaneousGesture(
            DragGesture()
                .onChanged { _ in isDragging = true }
                .onEnded { _ in
                    isDragging = false
                    scrollDirection = "Idle"
                }
        )
        .navigationTitle("Characters")
        .scrollDismissesKeyboard(.immediately)
        .searchable(text: $searchQuery, prompt: "Search by name")
        .onChange(of: searchQuery) {
            onSearchQueryChange?()
        }
    }
}
