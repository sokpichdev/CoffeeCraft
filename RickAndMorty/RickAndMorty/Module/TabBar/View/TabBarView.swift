//
//  TabBarView.swift
//  RickAndMorty
//
//  Created by Sok Pich on 5/29/25.
//
import SwiftUI

struct TabBarView1: View {
    @State private var selectedTab: Tab = .characters
    @Namespace private var namespace

    var body: some View {
        VStack(spacing: 0) {
            Group {
                switch selectedTab {
                case .characters:
                    CharactersView()
                case .locations:
                    LocationsView()
                case .episodes:
                    EpisodesView()
                case .favorites:
                    FavoritesView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            ZStack {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .shadow(color: .gray.opacity(0.4), radius: 20, x: 0, y: 20)
                TabsLayoutView(selectedTab: $selectedTab, namespace: namespace)
            }
            .frame(height: 70)
        }
        .edgesIgnoringSafeArea(.bottom)
    }
}
