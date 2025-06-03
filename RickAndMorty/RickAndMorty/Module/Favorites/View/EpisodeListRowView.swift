//
//  EpisodeListRowView.swift
//  RickAndMorty
//
//  Created by Sok Pich on 6/3/25.
//
import SwiftUI

struct EpisodeListRowView: View {
    let episode: Episode

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(episode.name)
                .font(.headline)
                .foregroundColor(.primary)

            HStack {
                Text(episode.episode)
                Spacer()
                Text(episode.air_date)
            }
            .font(.subheadline)
            .foregroundColor(.secondary)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(.secondarySystemBackground))
                .shadow(color: .black.opacity(0.2), radius: 3, x: 0, y: 2)
        )
    }
}
