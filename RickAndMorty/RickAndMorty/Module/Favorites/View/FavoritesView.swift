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
    @State private var isGridView: Bool = true
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
                        if isGridView {
                            LazyVGrid(columns: columns, spacing: 24) {
                                ForEach(favorites.favoriteCharacters) { character in
                                    NavigationLink(destination: CharacterDetailView(character: character)) {
                                        CharacterCardView(character: character)
                                    }
                                }
                            }
                            .padding(16)
                        } else {
                            LazyVStack(spacing: 12) {
                                ForEach(favorites.favoriteCharacters) { character in
                                    NavigationLink(destination: CharacterDetailView(character: character)) {
                                        CharacterListRowView(character: character)
                                    }
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.top, 8)
                        }
                    case 1:
                        if isGridView {
                            LazyVGrid(columns: columns, spacing: 24) {
                                ForEach(favorites.favoriteEpisodes) { episode in
                                    NavigationLink(destination: EpisodeDetailView(episode: episode)) {
                                        EpisodeCardView(episode: episode)
                                    }
                                }
                            }.padding(16)
                        } else {
                            LazyVStack(spacing: 12) {
                                ForEach(favorites.favoriteEpisodes) { episode in
                                    NavigationLink(destination: EpisodeDetailView(episode: episode)) {
                                        EpisodeListRowView(episode: episode)
                                    }
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.top, 8)
                        }
                            
                    case 2:
                        if isGridView {
                            LazyVGrid(columns: columns, spacing: 24) {
                                ForEach(favorites.favoriteLocations) { location in
                                    NavigationLink(destination: LocationDetailView(location: location)) {
                                        LocationCardView(location: location)
                                    }
                                }
                            }.padding(16)
                        } else {
                            LazyVStack(spacing: 12) {
                                ForEach(favorites.favoriteLocations) { location in
                                    NavigationLink(destination: LocationDetailView(location: location)) {
                                        LocationListRowView(location: location)
                                    }
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.top, 8)
                        }
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
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            isGridView.toggle()
                        }
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: isGridView ? "list.bullet" : "square.grid.2x2")
                                .transition(.scale)
                                .foregroundColor(.primary)

                            Text(isGridView ? "List" : "Grid")
                                .font(.subheadline)
                                .transition(.opacity.combined(with: .move(edge: .trailing)))
                                .foregroundColor(.primary)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 6)
                        .background(Color(.systemGray6))
                        .clipShape(Capsule())
                    }
                }
            }
        }
    }
}
