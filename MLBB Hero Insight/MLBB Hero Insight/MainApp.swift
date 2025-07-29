//
//  MainApp.swift
//  MLBB Hero Insight
//
//  Created by Sok Pich on 6/18/25.
//
import SwiftUI

struct MainApp: View {
    @StateObject var homeVM = HomeViewModel()
    @StateObject var heroPosVM = HeroPositionViewModel()

    @State var showTabBar: Bool = true
    @State private var selectedTab: Tab = .home
    @EnvironmentObject var tabBarManager: TabBarVisibilityManager

    var body: some View {
        ZStack(alignment: .bottom) {
            Group {
                switch selectedTab {
                case .home:
                    HomeView()
                        .environmentObject(homeVM)
                        .environmentObject(tabBarManager)
                case .ranking:
                    HeroRankingView()
                        .environmentObject(tabBarManager)
                case .position:
                    HeroPositionView()
                        .environmentObject(homeVM)
                        .environmentObject(heroPosVM)
                        .environmentObject(tabBarManager)
                case .settings:
                    HomeView()
                        .environmentObject(homeVM)
                        .environmentObject(tabBarManager)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)  // fill space above tab bar
            if tabBarManager.isVisible == true {
                TabBarView(selectedTab: $selectedTab)
            }
        }
        .edgesIgnoringSafeArea(.bottom)  // let tab bar reach device bottom (optional)
    }
}
