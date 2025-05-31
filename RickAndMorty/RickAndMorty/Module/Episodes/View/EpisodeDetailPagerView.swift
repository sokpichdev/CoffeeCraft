//
//  EpisodeDetailPagerView.swift
//  RickAndMorty
//
//  Created by Sok Pich on 5/31/25.
//
import SwiftUI

struct EpisodeDetailPagerView: View {
    let episodes: [Episode]
    let fetchMoreEpisodesIfNeeded: (Episode) -> Void
    @State private var currentIndex: Int
    @ObservedObject var favorites = FavoritesManager.shared
    @EnvironmentObject var tabBarManager: TabBarVisibilityManager

    init(episodes: [Episode], initialEpisode: Episode, fetchMoreEpisodesIfNeeded: @escaping (Episode) -> Void) {
        self.episodes = episodes
        self.fetchMoreEpisodesIfNeeded = fetchMoreEpisodesIfNeeded
        _currentIndex = State(initialValue: episodes.firstIndex(where: { $0.id == initialEpisode.id }) ?? 0)
    }

    var body: some View {
        TabView(selection: $currentIndex) {
            ForEach(Array(episodes.enumerated()), id: \.element.id) { index, episode in
                EpisodeDetailView(episode: episode)
                    .tag(index)
                    .onAppear {
                        if index == episodes.count - 1 {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                fetchMoreEpisodesIfNeeded(episode)
                            }
                        }
                    }
            }
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never)) // Explicit page style
        .navigationBarTitleDisplayMode(.inline)
        .indexViewStyle(.page(backgroundDisplayMode: .never))
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                if episodes.indices.contains(currentIndex) {
                    let episode = episodes[currentIndex]
                    Button {
                        favorites.toggleFavorite(episode)
                    } label: {
                        Image(systemName: favorites.isFavorite(episode) ? "heart.fill" : "heart")
                            .foregroundColor(Color(.secondaryLabel))
                    }
                }
            }
        }
        .onAppear {
            tabBarManager.isVisible = false
        }
        .onDisappear {
            tabBarManager.isVisible = true
        }
    }
}
