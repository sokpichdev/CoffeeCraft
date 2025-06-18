//
//  MainApp.swift
//  MLBB Hero Insight
//
//  Created by Sok Pich on 6/18/25.
//
import SwiftUI

struct MainApp: View {
    @State private var selectedTab: Tab = .home

    var body: some View {
        VStack(spacing: 0) {
            Group {
                switch selectedTab {
                case .home:
                    HomeView()
                case .ranking:
                    HeroRankingView()
                case .position:
                    HomeView()
                case .settings:
                    HomeView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)  // fill space above tab bar

            TabBarView(selectedTab: $selectedTab)
        }
        .edgesIgnoringSafeArea(.bottom)  // let tab bar reach device bottom (optional)
    }
}
