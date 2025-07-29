//
//  HeroPositionView.swift
//  MLBB Hero Insight
//
//  Created by Sok Pich on 6/20/25.
//
import SwiftUI

struct HeroPositionView: View {
    @EnvironmentObject var heroPosVM: HeroPositionViewModel
    @EnvironmentObject var homeVM: HomeViewModel
    @State private var searchText = ""
    @State private var showFilterSheet = false
    @EnvironmentObject var tabBarManager: TabBarVisibilityManager

    var filteredHeros: [HeroPositionRecord] {
        if searchText.isEmpty {
            return heroPosVM.positions ?? []
        } else {
            return heroPosVM.positions?.filter {
                $0.data?.hero?.data?.name?.localizedCaseInsensitiveContains(searchText) == true
            } ?? heroPosVM.positions ?? []
        }
    }
    var body: some View {
        NavigationStack {
            VStack {
                if heroPosVM.isLoading {
                    ProgressView("Loading Positions...")
                        .frame(maxHeight: .infinity)
                } else if let error = heroPosVM.errorMessage {
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
                        Task { await heroPosVM.loadPosition()}
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
                            
                            if heroPosVM.isBeingFiltered {
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
                Task { if !heroPosVM.isFetched {await heroPosVM.loadPosition()}}
            }
            .sheet(isPresented: $showFilterSheet) {
                HeroPositionFilterView(
                    lane: $heroPosVM.lane,
                    role: $heroPosVM.role, onApply: {
                        showFilterSheet = false
                        heroPosVM.isBeingFiltered = true
                        heroPosVM.isAlreadyReset = false
                        Task {
                            await heroPosVM.loadPosition()
                        }
                    }, onReset:  {
                        heroPosVM.resetFilter()
                    }
                )
                .presentationDetents([.medium, .large])
            }
        }
    }
}
