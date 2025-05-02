//
//  CharacterDetailView.swift
//  PaginationApp
//
//  Created by Sok Pich on 4/29/25.
//

import SwiftUI

struct CharacterDetailView: View {
    var user: User

    var body: some View {
        VStack(spacing: 20) {
            AsyncImage(url: URL(string: user.image)) { phase in
                if let image = phase.image {
                    image.resizable()
                         .scaledToFit()
                         .frame(width: 200, height: 200)
                         .clipShape(Circle())
                         .shadow(radius: 10)
                } else if phase.error != nil {
                    Image(systemName: "xmark.circle")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .foregroundColor(.red)
                } else {
                    ProgressView()
                }
            }
            .padding()

            VStack(alignment: .leading, spacing: 10) {
                Text("Name: \(user.name)")
                    .font(.headline)
            }
            .padding()

            Spacer()
        }
        .navigationTitle(user.name)
        .navigationBarTitleDisplayMode(.inline)
        .foregroundColor(.white)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.ignoresSafeArea())
    }
}
