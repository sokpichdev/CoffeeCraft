//
//  HomeView.swift
//  MLBB Hero Insight
//
//  Created by Sok Pich on 6/18/25.
//
import SwiftUI

struct HomeView: View {
    @EnvironmentObject var viewModel: HomeViewModel
    @State private var searchText = ""

    var filteredHeroes: [Hero] {
        if searchText.isEmpty {
            return viewModel.heroes
        } else {
            return viewModel.heroes.filter {
                $0.name.localizedCaseInsensitiveContains(searchText)
            }
        }
    }

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading {
                    ProgressView("Loading heroes...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let error = viewModel.errorMessage {
                    VStack(spacing: 16) {
                        Text(error)
                            .foregroundColor(.red)
                        Button("Retry") {
                            Task { await viewModel.loadHeroes() }
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        ForEach(filteredHeroes) { hero in
                            HStack(spacing: 16) {
                                Circle()
                                    .fill(Color.indigo.opacity(0.2))
                                    .frame(width: 40, height: 40)
                                    .overlay(Text(hero.id).font(.footnote))
                                Text(hero.name)
                                    .font(.body)
                                    .fontWeight(.medium)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                    .listStyle(.insetGrouped)
                    .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .automatic))
                    .refreshable {
                        Task { await viewModel.loadHeroes() }
                    }
                }
            }
            .navigationTitle("MLBB Heroes")
        }
        .task {
            await viewModel.loadHeroes()
        }
    }
}
