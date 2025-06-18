//
//  HeroRankingView.swift
//  MLBB Hero Insight
//
//  Created by Sok Pich on 6/18/25.
//
import SwiftUI

struct HeroRankingView: View {
    @StateObject private var viewModel = HeroRankingViewModel()

    var body: some View {
        NavigationStack {
            VStack {
                filterSection
                Divider().padding(.bottom)

                if viewModel.isLoading {
                    ProgressView("Loading Rankings...")
                        .frame(maxHeight: .infinity)
                } else if let error = viewModel.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .frame(maxHeight: .infinity)
                } else {
                    List(viewModel.rankings) { record in
                        rankingCard(for: record)
                    }
                    .listStyle(.plain)
                    .refreshable {
                        Task {await viewModel.loadRankings()}
                    }
                }
            }
            .padding()
            .navigationTitle("Hero Rankings")
            .onAppear {
                Task { await viewModel.loadRankings()}
            }
        }
    }

    // MARK: - UI Components

    private var filterSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Filters").font(.headline)
            HStack {
                Text("Day: Today")
                Spacer()
                Text("Rank: Mythic")
            }
            HStack {
                Text("Sort: Win Rate")
                Spacer()
                Button("Apply Filter") {
                    Task { await viewModel.loadRankings() }
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(12)
    }

    private func rankingCard(for record: HeroRankingRecord) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 12) {
                AsyncImage(url: URL(string: record.data.mainHero.data.head)) { image in
                    image.resizable()
                } placeholder: {
                    Color.gray.opacity(0.2)
                }
                .frame(width: 50, height: 50)
                .clipShape(Circle())

                VStack(alignment: .leading) {
                    Text(record.data.mainHero.data.name ?? "")
                        .font(.headline)

                    HStack {
                        Text("Win: \(String(format: "%.1f", record.data.mainHeroWinRate * 100))%")
                        Text("Pick: \(String(format: "%.2f", record.data.mainHeroAppearanceRate * 100))%")
                        Text("Ban: \(String(format: "%.2f", record.data.mainHeroBanRate * 100))%")
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                }
            }

            Text("Counter Heroes:")
                .font(.subheadline)
                .bold()

            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(record.data.subHero.indices, id: \.self) { index in
                        let sub = record.data.subHero[index]
                        VStack(spacing: 4) {
                            AsyncImage(url: URL(string: sub.hero.data.head)) { image in
                                image.resizable()
                            } placeholder: {
                                Color.gray.opacity(0.2)
                            }
                            .frame(width: 40, height: 40)
                            .clipShape(Circle())

                            Text("+\(String(format: "%.1f", sub.increaseWinRate * 100))%")
                                .font(.caption2)
                                .foregroundColor(.green)
                        }
                        .padding(4)
                    }
                }
            }
        }
        .padding(.vertical, 8)
    }
}
