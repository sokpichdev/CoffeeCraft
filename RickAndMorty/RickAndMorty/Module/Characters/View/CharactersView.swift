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
                            CharacterDetailPagerView(characters: viewModel.characters, initialCharacter: character)
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

struct CharacterRow: View {
    let character: Character

    var body: some View {
        VStack {
            AsyncImage(url: URL(string: character.image)) { image in
                image
                    .resizable()
                    .scaledToFill()
            } placeholder: {
                Color.gray.opacity(0.2)
            }
            .frame(width: 120, height: 120)
            .clipShape(Circle())

            Text(character.name)
                .font(.headline)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .frame(width: 120)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(radius: 3)
    }
}
