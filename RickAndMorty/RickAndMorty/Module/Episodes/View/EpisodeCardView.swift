//
//  EpisodeCardView.swift
//  RickAndMorty
//
//  Created by Sok Pich on 5/29/25.
//
import SwiftUI

struct EpisodeCardView: View {
    let episode: Episode

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(episode.name)
                .font(.headline)
                .foregroundColor(.primary)
                .lineLimit(2)
                .multilineTextAlignment(.leading)

            Text(episode.episode)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.leading)

            Text("Air Date: \(episode.air_date)")
                .font(.footnote)
                .foregroundColor(.gray)
                .multilineTextAlignment(.leading)
            Spacer()
        }
        .padding()
        .frame(height: 140) // 👈 fixed height
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color(.secondarySystemBackground))
                .shadow(color: .black.opacity(0.2), radius: 3, x: 0, y: 2)
        )
    }
}
