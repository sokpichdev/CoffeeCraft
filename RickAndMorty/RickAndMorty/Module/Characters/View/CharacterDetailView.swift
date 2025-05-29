//
//  CharacterDetailView.swift
//  RickAndMorty
//
//  Created by Sok Pich on 5/29/25.
//
import SwiftUI

struct CharacterDetailView: View {
    let character: Character
    @ObservedObject var favorites = FavoritesManager.shared

    var body: some View {
        VStack(spacing: 16) {
            AsyncImage(url: URL(string: character.image)) { image in
                image.resizable()
            } placeholder: {
                ProgressView()
            }
            .frame(width: 200, height: 200)
            .clipShape(Circle())

            Text(character.name)
                .font(.largeTitle)
                .bold()

            Text("\(character.status) - \(character.species)")
                .font(.headline)
                .foregroundColor(.secondary)

            Text("Gender: \(character.gender)")
            Text("Origin: \(character.origin.name)")
            Text("Location: \(character.location.name)")

            Spacer()
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    favorites.toggleFavorite(character)
                } label: {
                    Image(systemName: favorites.isFavorite(character) ? "heart.fill" : "heart")
                }
            }
        }
        .padding()
        .navigationTitle(character.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}
