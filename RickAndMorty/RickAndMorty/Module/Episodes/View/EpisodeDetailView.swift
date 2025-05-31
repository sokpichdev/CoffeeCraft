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

    let columns = [GridItem(.adaptive(minimum: 150), spacing: 24)]

    var body: some View {
        ScrollView(showsIndicators: false) {
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
                    LazyVGrid(columns: columns, spacing: 24) {
                        ForEach(viewModel.residents) { character in
                            NavigationLink(destination: CharacterDetailView(character: character)) {
                                CharacterCardView(character: character).environmentObject(tabBarManager)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .padding(.top)
        }
        .navigationTitle(episode.name)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            withAnimation(.easeInOut(duration: 0.1)) {
                tabBarManager.isVisible = false
            }
            viewModel.fetchResidents(from: episode.characters)
        }
    }
}
