//
//  EpisodesView.swift
//  RickAndMorty
//
//  Created by Sok Pich on 5/29/25.
//
import SwiftUI

struct EpisodesView: View {
    @StateObject private var viewModel = EpisodesViewModel()
    @EnvironmentObject var tabBarManager: TabBarVisibilityManager
    
    let columns = [GridItem(.adaptive(minimum: 150), spacing: 24)]

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 24) {
                    ForEach(viewModel.episodes) { episode in
                        NavigationLink {
                            EpisodeDetailPagerView(
                                episodes: viewModel.episodes,
                                initialEpisode: episode,
                                fetchMoreEpisodesIfNeeded: { currentEpi in
                                    viewModel.fetchEpisodesIfNeeded(currentEpisode: currentEpi)
                                }
                            )
                            .environmentObject(tabBarManager)
                        } label: {
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
            .onChange(of: viewModel.searchQuery) { _ in
                viewModel.resetAndFetch()
            }
            .onAppear {
                withAnimation(.easeInOut(duration: 0.05)) {
                    tabBarManager.isVisible = true
                }
                viewModel.resetAndFetch()
            }
            .background(Color(.systemBackground))
        }
    }
}
