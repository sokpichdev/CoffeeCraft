//
//  CharactersView.swift
//  RickAndMorty
//
//  Created by Sok Pich on 5/29/25.
//
import SwiftUI

struct CharactersView: View {
    @StateObject var viewModel = CharactersViewModel()
    @EnvironmentObject var tabBarManager: TabBarVisibilityManager
    let columns = [
        GridItem(.adaptive(minimum: 150), spacing: 24)
    ]

    let statusOptions = ["", "alive", "dead", "unknown"]
    let genderOptions = ["", "male", "female", "genderless", "unknown"]
    @State private var scrollOffset: CGFloat = 0
    @State private var lastScrollOffset: CGFloat = 0
    @State private var scrollDirection: String = "Idle"
    @State private var isDragging: Bool = false
    let directionChangeThreshold: CGFloat = 10
    
    @State private var lastUpdateTime = Date.distantPast
    let updateInterval: TimeInterval = 0.1
    
    @State var isRefreshing: Bool = false
    var body: some View {
        NavigationStack {
            ScrollView {
                GeometryReader { geo in
                    let offset = geo.frame(in: .global).minY

                    Color.clear
                        .onAppear {
                            lastScrollOffset = offset
                        }
                    .onChange(of: offset) { newOffset, _ in
                        guard !isRefreshing else { return }
                        guard isDragging else { return }
                        guard newOffset <= -10 else { return }

                        let now = Date()
                        if now.timeIntervalSince(lastUpdateTime) < updateInterval {
                            return
                        }

                        lastUpdateTime = now

                        let delta = newOffset - lastScrollOffset

                        let hideTabBarThreshold: CGFloat = -10
                        let showTabBarThreshold: CGFloat = 30

                        DispatchQueue.global(qos: .userInitiated).async {
                            var shouldShowTabBar = false
                            var shouldHideTabBar = false

                            if delta > showTabBarThreshold && scrollDirection != "Scrolling Up" {
                                shouldShowTabBar = true
                            } else if delta < hideTabBarThreshold && scrollDirection != "Scrolling Down" {
                                shouldHideTabBar = true
                            }

                            if shouldShowTabBar || shouldHideTabBar {
                                DispatchQueue.main.async {
                                    if shouldShowTabBar {
                                        scrollDirection = "Scrolling Up"
                                        lastScrollOffset = newOffset
                                        if !tabBarManager.isVisible {
                                            withAnimation(.easeInOut(duration: 0.2)) {
                                                tabBarManager.isVisible = true
                                            }
                                        }
                                    } else if shouldHideTabBar {
                                        scrollDirection = "Scrolling Down"
                                        lastScrollOffset = newOffset
                                        if tabBarManager.isVisible {
                                            withAnimation(.easeInOut(duration: 0.2)) {
                                                tabBarManager.isVisible = false
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                .frame(height: 0)
                
                LazyVGrid(columns: columns, spacing: 24) {
                    ForEach(viewModel.characters) { character in
                        NavigationLink {
                            CharacterDetailPagerView(
                                characters: viewModel.characters,
                                initialCharacter: character,
                                fetchMoreCharactersIfNeeded: { currentChar in
                                    viewModel.fetchCharactersIfNeeded(currentCharacter: currentChar)
                                }
                            )
                            .environmentObject(tabBarManager)
                        } label: {
                            CharacterCardView(character: character)
                        }
                        .onAppear {
                            viewModel.fetchCharactersIfNeeded(currentCharacter: character)
                        }
                    }
                }
                .padding(16)

                if viewModel.isLoading {
                    ProgressView().padding()
                }
            }
            .simultaneousGesture(
                DragGesture()
                    .onChanged { _ in
                        isDragging = true
                    }
                    .onEnded { _ in
                        isDragging = false
                        scrollDirection = "Idle"
                    }
            )
            .navigationTitle("Characters")
            .searchable(text: $viewModel.searchQuery, prompt: "Search by name")
            .scrollDismissesKeyboard(.immediately)
            .onChange(of: viewModel.searchQuery) {
                viewModel.resetAndFetch()
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Picker("Status", selection: $viewModel.selectedStatus) {
                            ForEach(statusOptions, id: \.self) { Text($0.capitalized) }
                        }

                        Picker("Gender", selection: $viewModel.selectedGender) {
                            ForEach(genderOptions, id: \.self) { Text($0.capitalized) }
                        }

                        Divider()

                        Button("Apply Filters") {
                            viewModel.resetAndFetch()
                        }
                    } label: {
                        Image(systemName: "line.horizontal.3.decrease.circle")
                            .foregroundColor(Color.primary)
                    }
                }
            }
            .background(Color(.systemBackground))
            .onAppear {
                withAnimation(.easeInOut(duration: 0.05)) {
                    tabBarManager.isVisible = true
                }
                viewModel.resetAndFetch()
            }
            .refreshable {
                isRefreshing = true
                viewModel.resetAndFetch()
                withAnimation(.easeInOut(duration: 0.05)) {
                    tabBarManager.isVisible = true
                }
                isRefreshing = false
            }
        }
    }
}
