//
//  CharacterDetailPagerView.swift
//  RickAndMorty
//
//  Created by Sok Pich on 5/30/25.
//
import SwiftUI

struct CharacterDetailPagerView: View {
    let characters: [Character]
    let fetchMoreCharactersIfNeeded: (Character) -> Void
    @State private var currentIndex: Int
    @ObservedObject var favorites = FavoritesManager.shared
    @EnvironmentObject var tabBarManager: TabBarVisibilityManager

    init(characters: [Character], initialCharacter: Character, fetchMoreCharactersIfNeeded: @escaping (Character) -> Void) {
        self.characters = characters
        self.fetchMoreCharactersIfNeeded = fetchMoreCharactersIfNeeded
        _currentIndex = State(initialValue: characters.firstIndex(where: { $0.id == initialCharacter.id }) ?? 0)
    }

    var body: some View {
        TabView(selection: $currentIndex) {
            ForEach(Array(characters.enumerated()), id: \.element.id) { index, character in
                CharacterDetailView(character: character)
                    .tag(index)
                    .onAppear {
                        currentIndex = index
                        print("Current index: \(index) / Total: \(characters.count)")

                        // Fetch more if we're at the last item
                        if index == characters.count - 1 {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                fetchMoreCharactersIfNeeded(character)
                            }
                        }
                    }
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .navigationTitle(characters[currentIndex].name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                if characters.indices.contains(currentIndex) {
                    let character = characters[currentIndex]
                    Button {
                        favorites.toggleFavorite(character)
                    } label: {
                        Image(systemName: favorites.isFavorite(character) ? "heart.fill" : "heart")
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
