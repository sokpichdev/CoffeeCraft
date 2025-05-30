//
//  CharacterDetailPagerView.swift
//  RickAndMorty
//
//  Created by Sok Pich on 5/30/25.
//
import SwiftUI

struct CharacterDetailPagerView: View {
    let characters: [Character]
    @State private var currentIndex: Int
    @ObservedObject var favorites = FavoritesManager.shared
    @EnvironmentObject var tabBarManager: TabBarVisibilityManager

    init(characters: [Character], initialCharacter: Character) {
        self.characters = characters
        self._currentIndex = State(initialValue: characters.firstIndex(where: { $0.id == initialCharacter.id }) ?? 0)
    }

    var body: some View {
        TabView(selection: $currentIndex) {
            ForEach(Array(characters.enumerated()), id: \.1.id) { index, character in
                CharacterDetailView(character: character)
                    .tag(index)
            }
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
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
            withAnimation(.easeInOut(duration: 0.05)) {
                tabBarManager.isVisible = true
            }
        }
    }
}
