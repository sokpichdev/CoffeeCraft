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
    @State var isNavigateToDetail: Bool = false
    @State var selectedHeroID: String = "0"
    @EnvironmentObject var tabBarManager: TabBarVisibilityManager

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
            VStack {
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
                    ScrollView {
                        LazyVStack(spacing: 0, pinnedViews: []) {
                            ForEach(filteredHeroes) { hero in
                                Button(action: {
                                    isNavigateToDetail = true
                                    selectedHeroID = hero.id
                                }, label: {
                                    HStack(spacing: 16) {
                                        Circle()
                                            .fill(Color.indigo.opacity(0.2))
                                            .frame(width: 40, height: 40)
                                            .overlay(Text(hero.id).font(.footnote))
                                        Text(hero.name)
                                            .font(.body)
                                            .fontWeight(.medium)
                                        Spacer()
                                    }
                                    .padding(.vertical, 4)
                                })
                                .buttonStyle(.plain)
                            }
                        }
                        .padding()
                    }
                    .scrollIndicators(.hidden)
                    .refreshable {
                        Task { await viewModel.loadHeroes() }
                    }
                }
            }
            .navigationTitle("MLBB Heroes")
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .automatic))
            .navigationDestination(isPresented: $isNavigateToDetail, destination: {
                HeroDetailView(heroID: selectedHeroID).environmentObject(tabBarManager)
            })
        }
        .task {
            if !viewModel.isFetched {
                await viewModel.loadHeroes()
            }
        }
    }
}
