//
//  CharacterCardView.swift
//  RickAndMorty
//
//  Created by Sok Pich on 5/29/25.
//
import SwiftUI

struct CharacterCardView: View {
    let character: Character

    var body: some View {
        VStack(spacing: 8) {
            // Fixed-height image with consistent layout
            AsyncImage(url: URL(string: character.image)) { phase in
                switch phase {
                case .empty:
                    Color.gray.opacity(0.2)
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                case .failure:
                    Image(systemName: "photo")
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(.gray)
                @unknown default:
                    EmptyView()
                }
            }
            .frame(height: 150)
            .frame(maxWidth: .infinity)
            .clipped()
            .clipShape(RoundedRectangle(cornerRadius: 12))

            // Fixed-height name text (limit to 2 lines)
            Text(character.name)
                .font(.headline)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .frame(height: 40) // force consistent height for all names
                .frame(maxWidth: .infinity)
        }
        .padding()
        .frame(height: 230) // total card height (adjust if needed)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.2), radius: 3, x: 0, y: 2)
        )
    }
}
