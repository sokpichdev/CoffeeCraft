//
//  LocationCardView.swift
//  RickAndMorty
//
//  Created by Sok Pich on 5/29/25.
//
import SwiftUI

struct LocationCardView: View {
    let location: Location

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(location.name)
                .font(.headline)
                .lineLimit(2)
                .multilineTextAlignment(.leading)

            Text(location.type)
                .font(.subheadline)
                .foregroundColor(.secondary)

            Text(location.dimension)
                .font(.caption)
                .foregroundColor(.gray)
                .lineLimit(1)
        }
        .padding()
        .frame(height: 140) // 👈 fixed height
        .frame(maxWidth: .infinity)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}
