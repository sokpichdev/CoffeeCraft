//
//  EpisodeDetailView.swift
//  RickAndMorty
//
//  Created by Sok Pich on 5/29/25.
//
import SwiftUI

struct EpisodeDetailView: View {
    let episode: Episode
    @StateObject private var viewModel = LocationDetailViewModel() // reuse to fetch characters by URLs
    @ObservedObject var favorites = FavoritesManager.shared
    @EnvironmentObject var tabBarManager: TabBarVisibilityManager

    let columns = [GridItem(.adaptive(minimum: 160), spacing: 16)]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(episode.name)
                        .font(.largeTitle)
                        .bold()

                    Text("Air Date: \(episode.air_date)")
                    Text("Episode Code: \(episode.episode)")
                }
                .padding(.horizontal)

                Divider()

                Text("Characters")
                    .font(.headline)
                    .padding(.horizontal)

                if viewModel.isLoading {
                    ProgressView().padding()
                } else {
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(viewModel.residents) { character in
                            NavigationLink(destination: CharacterDetailView(character: character)) {
                                CharacterCardView(character: character)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .padding(.top)
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    favorites.toggleFavorite(episode)
                } label: {
                    Image(systemName: favorites.isFavorite(episode) ? "heart.fill" : "heart")
                }
            }
        }
        .navigationTitle(episode.name)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            tabBarManager.isVisible = false

            viewModel.fetchResidents(from: episode.characters)
        }
        .onDisappear {
            withAnimation(.easeInOut(duration: 0.05)) {
                tabBarManager.isVisible = true
            }
        }
    }
}
