//
//  EpisodesView.swift
//  RickAndMorty
//
//  Created by Sok Pich on 5/29/25.
//
import SwiftUI

struct EpisodesView: View {
    @StateObject private var viewModel = EpisodesViewModel()
    
    let columns = [GridItem(.adaptive(minimum: 160), spacing: 16)]

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(viewModel.episodes) { episode in
                        NavigationLink(destination: EpisodeDetailView(episode: episode)) {
                            EpisodeCardView(episode: episode)
                        }
                        .onAppear {
                            viewModel.fetchIfNeeded(currentItem: episode)
                        }
                    }

                    if viewModel.isLoading {
                        ProgressView().padding()
                    }
                }
                .padding()
            }
            .refreshable {
                viewModel.resetAndFetch()
            }
            .navigationTitle("Episodes")
            .scrollDismissesKeyboard(.immediately)
            .searchable(text: $viewModel.searchQuery, prompt: "Search episodes")
            .onChange(of: viewModel.searchQuery) {
                viewModel.resetAndFetch()
            }
            .onAppear {
                viewModel.resetAndFetch()
            }
            .background(Color(.systemBackground))
        }
    }
}
