//
//  FavoritesView.swift
//  RickAndMorty
//
//  Created by Sok Pich on 5/29/25.
//
import SwiftUI

struct FavoritesView: View {
    @ObservedObject var favorites = FavoritesManager.shared
    @State private var selection = 0
    @EnvironmentObject var tabBarManager: TabBarVisibilityManager
    let columns = [
        GridItem(.adaptive(minimum: 150), spacing: 24)
    ]
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Picker("Favorite Type", selection: $selection) {
                    Text("Characters").tag(0)
                    Text("Episodes").tag(1)
                    Text("Locations").tag(2)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(16)

                ScrollView(showsIndicators: false) {
                    switch selection {
                    case 0:
                        LazyVGrid(columns: columns, spacing: 24) {
                            ForEach(favorites.favoriteCharacters) { character in
                                NavigationLink(destination: CharacterDetailView(character: character)) {
                                    CharacterCardView(character: character)
                                }
                            }
                        }.padding(16)
                    case 1:
                        LazyVGrid(columns: columns, spacing: 24) {
                            ForEach(favorites.favoriteEpisodes) { episode in
                                NavigationLink(destination: EpisodeDetailView(episode: episode)) {
                                    EpisodeCardView(episode: episode)
                                }
                            }
                        }.padding(16)
                    case 2:
                        LazyVGrid(columns: columns, spacing: 24) {
                            ForEach(favorites.favoriteLocations) { location in
                                NavigationLink(destination: LocationDetailView(location: location)) {
                                    LocationCardView(location: location)
                                }
                            }
                        }.padding(16)
                    default:
                        EmptyView()
                    }
                }
                .scrollDismissesKeyboard(.immediately)
            }
            .navigationTitle("Favorites")
            .background(Color(.systemBackground))
            .onAppear {
                withAnimation(.easeInOut(duration: 0.05)) {
                    tabBarManager.isVisible = true
                }
            }
//            .onDisappear {
//                withAnimation(.easeInOut(duration: 0.1)) {
//                    tabBarManager.isVisible = false
//                }
//            }
        }
    }
}
