//
//  CharacterListRowView.swift
//  RickAndMorty
//
//  Created by Sok Pich on 6/3/25.
//
import SwiftUI

struct CharacterListRowView: View {
    let character: Character

    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            AsyncImage(url: URL(string: character.image)) { image in
                image
                    .resizable()
                    .scaledToFill()
            } placeholder: {
                Color.gray.opacity(0.3)
            }
            .frame(width: 60, height: 60)
            .clipShape(RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 4) {
                Text(character.name)
                    .font(.headline)
                    .foregroundColor(.primary)

                Text(character.status.capitalized)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(.secondarySystemBackground))
                .shadow(color: .black.opacity(0.2), radius: 3, x: 0, y: 2)
        )
    }
}
