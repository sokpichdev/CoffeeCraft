//
//  LocationDetailPagerView.swift
//  RickAndMorty
//
//  Created by Sok Pich on 5/31/25.
//

import SwiftUI

struct LocationDetailPagerView: View {
    let locations: [Location]
    let fetchMoreLocatinoIfNeeded: (Location) -> Void
    @State private var currentIndex: Int
    @ObservedObject var favorites = FavoritesManager.shared
    @EnvironmentObject var tabBarManager: TabBarVisibilityManager
    
    init(locations: [Location], initialLocation: Location, fetchMoreLocationIfNeeded: @escaping (Location) -> Void) {
        self.locations = locations
        self.fetchMoreLocatinoIfNeeded = fetchMoreLocationIfNeeded
        _currentIndex = State(initialValue: locations.firstIndex(where: { $0.id == initialLocation.id}) ?? 0)
    }
    
    var body: some View {
        TabView(selection: $currentIndex) {
            ForEach(Array(locations.enumerated()), id: \.element.id) { index, location in
                LocationDetailView(location: location)
                    .tag(index)
                    .onAppear {
                        if index == locations.count - 1 {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                fetchMoreLocatinoIfNeeded(location)
                            }
                        }
                    }
            }
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        .navigationBarTitleDisplayMode(.inline)
        .indexViewStyle(.page(backgroundDisplayMode: .never))
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                if locations.indices.contains(currentIndex) {
                    let location = locations[currentIndex]
                    Button {
                        favorites.toggleFavorite(location)
                    } label: {
                        Image(systemName: favorites.isFavorite(location) ? "heart.fill" : "heart")
                            .foregroundColor(Color(.secondaryLabel))
                    }
                }
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 0.1)) {
                tabBarManager.isVisible = false
            }
        }
    }
}
