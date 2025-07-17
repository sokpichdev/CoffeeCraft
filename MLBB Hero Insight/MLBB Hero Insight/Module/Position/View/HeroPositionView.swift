//
//  HeroPositionView.swift
//  MLBB Hero Insight
//
//  Created by Sok Pich on 6/20/25.
//
import SwiftUI

struct HeroPositionView: View {
    @StateObject private var viewModel = HeroPositionViewModel()
    @EnvironmentObject var homeVM: HomeViewModel
    @State private var searchText = ""
    @State private var showFilterSheet = false
    
    var filteredHeros: [HeroPositionRecord] {
        if searchText.isEmpty {
            return viewModel.positions ?? []
        } else {
            return viewModel.positions?.filter {
                $0.data?.hero?.data?.name?.localizedCaseInsensitiveContains(searchText) == true
            } ?? viewModel.positions ?? []
        }
    }
    var body: some View {
        NavigationStack {
            VStack {
                if viewModel.isLoading {
                    ProgressView("Loading Positions...")
                        .frame(maxHeight: .infinity)
                } else if let error = viewModel.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .frame(maxHeight: .infinity)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 0, pinnedViews: []) {
                            ForEach(filteredHeros.indices, id: \.self) { index in
                                let record = filteredHeros[index]
                                VStack(spacing: 0) {
                                    FlippableHeroCard(heroes: homeVM.heroes, record: record)
                                        .padding(.vertical, 8)
                                        .padding(.horizontal)
                                }
                            }
                        }
                        .padding(.top)
                    }
                    .scrollIndicators(.hidden)
                    .refreshable {
                        Task { await viewModel.loadPosition()}
                    }
                }
            }
            .navigationTitle("Hero Positions")
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .automatic))
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showFilterSheet = true
                    } label: {
                        ZStack(alignment: .topTrailing) {
                            Image(systemName: "line.3.horizontal.decrease.circle")
                                .font(.title3)
                            
                            if viewModel.isBeingFiltered {
                                Circle()
                                    .fill(Color.red)
                                    .frame(width: 8, height: 8)
                                    .offset(x: 6, y: -6)
                            }
                        }
                        .accessibilityLabel("Filter")
                    }
                }
            }
            .onAppear {
                Task { await viewModel.loadPosition()}
            }
            .sheet(isPresented: $showFilterSheet) {
                HeroPositionFilterView(
                    lane: $viewModel.lane,
                    role: $viewModel.role, onApply: {
                        showFilterSheet = false
                        viewModel.isBeingFiltered = true
                        viewModel.isAlreadyReset = false
                        Task {
                            await viewModel.loadPosition()
                        }
                    }, onReset:  {
                        viewModel.resetFilter()
                    }
                )
                .presentationDetents([.medium, .large])
            }
        }
    }
}
