//
//  CharactersView.swift
//  RickAndMorty
//
//  Created by Sok Pich on 5/29/25.
//
import SwiftUI

struct CharactersView: View {
    @StateObject var viewModel = CharactersViewModel()
    @EnvironmentObject var tabBarManager: TabBarVisibilityManager
    let columns = [
        GridItem(.adaptive(minimum: 150), spacing: 16)
    ]

    let statusOptions = ["", "alive", "dead", "unknown"]
    let genderOptions = ["", "male", "female", "genderless", "unknown"]

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(viewModel.characters) { character in
                        NavigationLink {
                            CharacterDetailPagerView(
                                characters: viewModel.characters,
                                initialCharacter: character,
                                fetchMoreCharactersIfNeeded: { currentChar in
                                    viewModel.fetchCharactersIfNeeded(currentCharacter: currentChar)
                                }
                            )
                            .environmentObject(tabBarManager)
                        } label: {
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
                            .foregroundColor(Color.primary)
                    }
                }
            }
            .background(Color(.systemBackground))
            .onAppear {
                viewModel.resetAndFetch()
            }
            .refreshable {
                viewModel.resetAndFetch()
            }
        }
    }
}
