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

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Picker("Favorite Type", selection: $selection) {
                    Text("Characters").tag(0)
                    Text("Episodes").tag(1)
                    Text("Locations").tag(2)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()

                ScrollView {
                    switch selection {
                    case 0:
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 160))], spacing: 16) {
                            ForEach(favorites.favoriteCharacters) { character in
                                NavigationLink(destination: CharacterDetailView(character: character)) {
                                    CharacterCardView(character: character)
                                }
                            }
                        }.padding()
                    case 1:
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 160))], spacing: 16) {
                            ForEach(favorites.favoriteEpisodes) { episode in
                                NavigationLink(destination: EpisodeDetailView(episode: episode)) {
                                    EpisodeCardView(episode: episode)
                                }
                            }
                        }.padding()
                    case 2:
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 160))], spacing: 16) {
                            ForEach(favorites.favoriteLocations) { location in
                                NavigationLink(destination: LocationDetailView(location: location)) {
                                    LocationCardView(location: location)
                                }
                            }
                        }.padding()
                    default:
                        EmptyView()
                    }
                }
                .scrollDismissesKeyboard(.immediately)
            }
            .navigationTitle("Favorites")
            .background(Color(.systemBackground))
        }
    }
}
