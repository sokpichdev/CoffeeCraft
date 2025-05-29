//
//  CharactersView.swift
//  RickAndMorty
//
//  Created by Sok Pich on 5/29/25.
//
import SwiftUI

struct CharactersView: View {
    @StateObject var viewModel = CharactersViewModel()

    let statusOptions = ["", "alive", "dead", "unknown"]
    let genderOptions = ["", "male", "female", "genderless", "unknown"]

    var body: some View {
        NavigationView {
            VStack {
                // 🔍 Search Bar
                TextField("Search by name", text: $viewModel.searchQuery)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                    .onSubmit {
                        viewModel.resetAndFetch()
                    }

                // 🎭 Filters
                HStack {
                    Picker("Status", selection: $viewModel.selectedStatus) {
                        ForEach(statusOptions, id: \.self) { Text($0.capitalized) }
                    }

                    Picker("Gender", selection: $viewModel.selectedGender) {
                        ForEach(genderOptions, id: \.self) { Text($0.capitalized) }
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .padding(.horizontal)

                Button("Apply Filters") {
                    viewModel.resetAndFetch()
                }
                .padding(.bottom)

                // 📜 List of Characters
                ScrollView {
                    LazyVStack {
                        ForEach(viewModel.characters) { character in
                            NavigationLink(destination: CharacterDetailView(character: character)) {
                                CharacterCardView(character: character)
                            }
                            .onAppear {
                                viewModel.fetchCharactersIfNeeded(currentCharacter: character)
                            }
                        }

                        if viewModel.isLoading {
                            ProgressView().padding()
                        }
                    }
                }
            }
            .navigationTitle("Characters")
            .onAppear {
                viewModel.resetAndFetch()
            }
        }
    }
}

