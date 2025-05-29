//
//  CharactersView.swift
//  RickAndMorty
//
//  Created by Sok Pich on 5/29/25.
//
import SwiftUI

struct CharactersView: View {
    @StateObject var viewModel = CharactersViewModel()

    let columns = [
        GridItem(.adaptive(minimum: 150), spacing: 16)
    ]

    let statusOptions = ["", "alive", "dead", "unknown"]
    let genderOptions = ["", "male", "female", "genderless", "unknown"]

    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(viewModel.characters) { character in
                        NavigationLink(destination: CharacterDetailView(character: character)) {
                            CharacterCardView(character: character)
                        }
                        .onAppear {
                            viewModel.fetchCharactersIfNeeded(currentCharacter: character)
                        }
                    }
                }
                .padding()

                if viewModel.isLoading {
                    ProgressView().padding()
                }
            }
            .navigationTitle("Characters")
            .searchable(text: $viewModel.searchQuery, prompt: "Search by name")
            .scrollDismissesKeyboard(.immediately)
            .onChange(of: viewModel.searchQuery) {
                viewModel.resetAndFetch()
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Picker("Status", selection: $viewModel.selectedStatus) {
                            ForEach(statusOptions, id: \.self) { Text($0.capitalized) }
                        }

                        Picker("Gender", selection: $viewModel.selectedGender) {
                            ForEach(genderOptions, id: \.self) { Text($0.capitalized) }
                        }

                        Divider()

                        Button("Apply Filters") {
                            viewModel.resetAndFetch()
                        }
                    } label: {
                        Image(systemName: "line.horizontal.3.decrease.circle")
                    }
                }
            }
            .onAppear {
                viewModel.resetAndFetch()
            }
        }
    }
}

