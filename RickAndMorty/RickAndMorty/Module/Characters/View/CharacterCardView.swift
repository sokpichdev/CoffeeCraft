//
//  CharacterCardView.swift
//  RickAndMorty
//
//  Created by Sok Pich on 5/29/25.
//
import SwiftUI

struct CharacterCardView: View {
    let character: Character
    @EnvironmentObject var tabBarManager: TabBarVisibilityManager
    var body: some View {
        GeometryReader { geometry in
            let cardWidth = geometry.size.width
            let imageSize = cardWidth * 0.8
            VStack(spacing: 8) {
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
                .frame(maxWidth: imageSize, maxHeight: imageSize)
                .clipped()
                .clipShape(RoundedRectangle(cornerRadius: 12))

                Text(character.name)
                    .foregroundColor(Color(.label))
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .frame(height: 40) // force consistent height for all names
                    .frame(maxWidth: .infinity)
            }
            .padding()
            .frame(maxWidth: cardWidth, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color(.secondarySystemBackground))
                    .shadow(color: .black.opacity(0.2), radius: 3, x: 0, y: 2)
            )
        }
        .frame(height: 230)
    }
}
