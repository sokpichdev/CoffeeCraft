//
//  LocationListRowView.swift
//  RickAndMorty
//
//  Created by Sok Pich on 6/3/25.
//
import SwiftUI

struct LocationListRowView: View {
    let location: Location

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(location.name)
                .font(.headline)
                .foregroundColor(.primary)

            HStack {
                Text(location.type)
                Spacer()
                Text(location.dimension)
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
