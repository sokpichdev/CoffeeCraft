//
//  LocationsView.swift
//  RickAndMorty
//
//  Created by Sok Pich on 5/29/25.
//
import SwiftUI

struct LocationsView: View {
    @StateObject var viewModel = LocationsViewModel()
    @EnvironmentObject var tabBarManager: TabBarVisibilityManager
    
    let columns = [GridItem(.adaptive(minimum: 150), spacing: 24)]

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 24) {
                    ForEach(viewModel.locations) { location in
                        NavigationLink(destination: LocationDetailView(location: location)) {
                            LocationCardView(location: location)
                        }
                        .onAppear {
                            viewModel.fetchIfNeeded(currentItem: location)
                        }
                    }

                    if viewModel.isLoading {
                        ProgressView()
                            .padding()
                    }
                }
                .padding()
            }
            .navigationTitle("Locations")
            .scrollDismissesKeyboard(.immediately)
            .searchable(text: $viewModel.searchQuery, prompt: "Search locations")
            .onChange(of: viewModel.searchQuery) {
                viewModel.resetAndFetch()
            }
            .onAppear {
                withAnimation(.easeInOut(duration: 0.05)) {
                    tabBarManager.isVisible = true
                }
                viewModel.resetAndFetch()
            }
            .background(Color(.systemBackground))
            .refreshable {
                viewModel.resetAndFetch()
            }
        }
    }
}
