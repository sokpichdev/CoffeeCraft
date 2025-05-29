//
//  LocationDetailView.swift
//  RickAndMorty
//
//  Created by Sok Pich on 5/29/25.
//
import SwiftUI

struct LocationDetailView: View {
    let location: Location
    @StateObject private var viewModel = LocationDetailViewModel()

    let columns = [GridItem(.adaptive(minimum: 160), spacing: 16)]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Header Info
                VStack(alignment: .leading, spacing: 8) {
                    Text(location.name)
                        .font(.largeTitle)
                        .bold()

                    Text("Type: \(location.type)")
                    Text("Dimension: \(location.dimension)")
                }
                .padding(.horizontal)

                Divider()

                Text("Residents")
                    .font(.headline)
                    .padding(.horizontal)

                if viewModel.isLoading {
                    ProgressView().padding()
                } else if viewModel.residents.isEmpty {
                    Text("No known residents.")
                        .foregroundColor(.gray)
                        .padding(.horizontal)
                } else {
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(viewModel.residents) { character in
                            NavigationLink(destination: CharacterDetailView(character: character)) {
                                CharacterCardView(character: character)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .padding(.top)
        }
        .navigationTitle(location.name)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.fetchResidents(from: location.residents)
        }
    }
}
