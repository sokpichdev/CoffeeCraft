//
//  HeroDetailView.swift
//  MLBB Hero Insight
//
//  Created by Sok Pich on 6/26/25.
//
import SwiftUI

struct HeroDetailView: View {
    @StateObject var viewModel = DetailViewModel()
    let heroID: String

    var body: some View {
        VStack {
            if viewModel.isLoading {
                ProgressView("Loading...")
                    .padding()
            } else if let error = viewModel.errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .padding()
            } else if let hero = viewModel.detail.first {
                ScrollView {
                    VStack(spacing: 16) {
                        AsyncImage(url: hero.data.hero.data.squareheadbig) { image in
                            image
                                .resizable()
                                .scaledToFit()
                                .cornerRadius(12)
                        } placeholder: {
                            ProgressView()
                        }
                        .frame(height: 200)

                        Text(hero.data.hero.data.name)
                            .font(.largeTitle)
                            .fontWeight(.bold)

                        Text(hero.data.hero.data.story)
                            .font(.body)
                            .foregroundColor(.secondary)
                            .padding()

                        HStack {
                            ForEach(hero.data.hero.data.sortlabel.filter { !$0.isEmpty }, id: \.self) { role in
                                Text(role)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Color.blue.opacity(0.2))
                                    .cornerRadius(8)
                            }
                        }
                    }
                    .padding()
                }
            } else if viewModel.isFetched {
                Text("No data found.")
            }
        }
        .task {
            await viewModel.loadDetail(id: heroID)
        }
        .navigationTitle("Hero Detail")
    }
}
