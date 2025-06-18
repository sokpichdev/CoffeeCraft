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
        VStack {
            Group {
                switch selectedTab {
                case .home:
                    HomeView()
                case .ranking:
                    EmptyView()
//                    HeroRankingView()
                case .position:
                    EmptyView()
//                    HeroPositionView()
                case .settings:
                    EmptyView()
//                    SettingsView()
                }
            }
            TabBarView(selectedTab: $selectedTab)
        }
    }
}
