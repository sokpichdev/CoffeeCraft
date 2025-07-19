//
//  HeroRankingView.swift
//  MLBB Hero Insight
//
//  Created by Sok Pich on 6/18/25.
//
import SwiftUI

struct HeroRankingView: View {
    @StateObject private var viewModel = HeroRankingViewModel()
    @State private var searchText = ""
    @State private var showFilterSheet = false
    
    var filteredHeroes: [HeroRankingRecord] {
        if searchText.isEmpty {
            return viewModel.rankings ?? []
        } else {
            return viewModel.rankings?.filter {
                $0.data.mainHero?.data?.name?.localizedCaseInsensitiveContains(searchText) == true
            } ?? viewModel.rankings ?? []
        }
    }
    var body: some View {
        NavigationStack {
            VStack {
                if viewModel.isLoading {
                    ProgressView("Loading Rankings...")
                        .frame(maxHeight: .infinity)
                } else if let error = viewModel.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .frame(maxHeight: .infinity)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 0, pinnedViews: []) {
                            ForEach(filteredHeroes.indices, id: \.self) { index in
                                let record = filteredHeroes[index]
                                VStack(spacing: 0) {
                                    rankingCard(for: record)
                                        .padding(.vertical, 12)

                                    if index < filteredHeroes.count - 1 {
                                        Divider()
                                    }
                                }
                            }
                        }
                        .padding(.top)
                    }
                    .scrollIndicators(.hidden)
                    .refreshable {
                        Task { await viewModel.loadRankings() }
                    }
                }
            }
            .navigationTitle("Hero Rankings")
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always))
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
                Task { await viewModel.loadRankings()}
            }
            .sheet(isPresented: $showFilterSheet) {
                HeroRankingFilterView(
                    day: $viewModel.selectedDay,
                    rank: $viewModel.selectedRank,
                    size: $viewModel.size,
                    index: $viewModel.index,
                    sortField: $viewModel.sortField,
                    sortOrder: $viewModel.sortOrder,
                    onApply: {
                        showFilterSheet = false
                        viewModel.isBeingFiltered = true
                        viewModel.isAlreadyReset = false
                        Task {
                            await viewModel.loadRankings()
                        }
                    },
                    onReset: {
                        viewModel.resetFilters()
                    }
                )
                .presentationDetents([.medium, .large])
            }
        }
    }

    // MARK: - UI Components

    private var filterSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Filters")
                .font(.headline)

            // Day and Rank
            HStack {
                Picker("Day", selection: $viewModel.selectedDay) {
                    ForEach([1, 3, 7, 15, 30], id: \.self) { day in
                        Text("\(day)").tag(day)
                    }
                }
                .pickerStyle(.menu)

                Spacer()

                Picker("Rank", selection: $viewModel.selectedRank) {
                    ForEach(["all", "epic", "legend", "mythic", "honor", "glory"], id: \.self) { rank in
                        Text(rank.capitalized).tag(rank)
                    }
                }
                .pickerStyle(.menu)
            }

            // Size and Index
            HStack {
                TextField("Size", text: $viewModel.size)
                    .keyboardType(.numberPad)
                    .textFieldStyle(.roundedBorder)

                TextField("Index", text: $viewModel.index)
                    .keyboardType(.numberPad)
                    .textFieldStyle(.roundedBorder)
            }

            // Sort Field and Order
            HStack {
                Picker("Sort By", selection: $viewModel.sortField) {
                    ForEach(["win_rate", "pick_rate", "ban_rate"], id: \.self) { field in
                        Text(field.replacingOccurrences(of: "_", with: " ").capitalized).tag(field)
                    }
                }
                .pickerStyle(.menu)

                Picker("Order", selection: $viewModel.sortOrder) {
                    ForEach(["asc", "desc"], id: \.self) { order in
                        Text(order.uppercased()).tag(order)
                    }
                }
                .pickerStyle(.menu)
            }

            // Filter Button
            HStack {
                Spacer()
                Button("Apply Filter") {
                    Task {
                        await viewModel.loadRankings()
                    }
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(12)
    }

    private func rankingCard(for record: HeroRankingRecord) -> some View {
        let data = record.data
        return VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 12) {
                AsyncImage(url: URL(string: data.mainHero?.data?.head ?? "")) { image in
                    image.resizable()
                } placeholder: {
                    Color.gray.opacity(0.2)
                }
                .frame(width: 50, height: 50)
                .clipShape(Circle())

                VStack(alignment: .leading) {
                    Text(data.mainHero?.data?.name ?? "")
                        .font(.headline)

                    HStack {
                        Text("Win: \(String(format: "%.1f", (data.mainHeroWinRate ?? 1) * 100))%")
                        Text("Pick: \(String(format: "%.2f",(data.mainHeroAppearanceRate ?? 1) * 100))%")
                        Text("Ban: \(String(format: "%.2f", (data.mainHeroBanRate ?? 1) * 100))%")
                    }
                    .font(.body)
                    .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal)

            Text("Counter Heroes:")
                .font(.subheadline)
                .bold()
                .padding(.horizontal)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    if let subHeroes = data.subHero, !subHeroes.isEmpty {
                        ForEach(subHeroes.indices, id: \.self) { index in
                            let sub = subHeroes[index]
                            VStack(spacing: 4) {
                                AsyncImage(url: URL(string: sub.hero?.data?.head ?? "")) { image in
                                    image.resizable()
                                } placeholder: {
                                    Color.gray.opacity(0.2)
                                }
                                .frame(width: 40, height: 40)
                                .clipShape(Circle())
//
                                Text("+\(String(format: "%.1f", (sub.increaseWinRate ?? 1) * 100))%")
                                    .font(.caption2)
                                    .foregroundColor(.green)
                            }
                            .padding(4)
                        }
                    }
                }
                .padding(.horizontal) // align with screen edges
            }
        }
        .frame(maxWidth: .infinity)
    }
}
