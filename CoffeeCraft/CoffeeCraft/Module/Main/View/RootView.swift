//
//  RootView.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 10/20/25.
//
import SwiftUI
import FirebaseAuth

struct RootView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @EnvironmentObject var themeManager: ThemeManager
    
    @StateObject var cartManager = CartManager()
    @StateObject var cardVM = CardViewModel()
    @StateObject var favVM = FavoriteViewModel()
    @State private var selectedTab: Tab = .home
    
    var body: some View {
        Group {
            if authVM.currentUser == nil {
                AuthView()
            } else {
                VStack(spacing: 0) {
                    // MARK: - Main Content
                    // Show the selected tab's root view
                    switch authVM.currentUser!.role {
                    case .customer:
                        switch selectedTab {
                        case .home:
                            HomeView(selectedTab: $selectedTab)
                                .environmentObject(authVM)
                        case .menu:
                            MenuView()
                                .environmentObject(cartManager)
                                .environmentObject(favVM)
                                .environmentObject(cardVM)
                        case .orders:
                            OrdersView()
                        case .profile:
                            AccountView()
                                .environmentObject(favVM)
                                .environmentObject(authVM)
                                .environmentObject(themeManager)
                                .environmentObject(cardVM)
                        }
                    case .manager:
                        switch selectedTab {
                        case .home:
                            HomeView(selectedTab: $selectedTab)
                                .environmentObject(authVM)
                        case .menu:
                            MenuView(isManager: true)
                                .environmentObject(cartManager)
                                .environmentObject(favVM)
                                .environmentObject(cardVM)
                        case .orders:
                            AdminOrdersView()
                        case .profile:
                            AccountView()
                                .environmentObject(favVM)
                                .environmentObject(authVM)
                                .environmentObject(themeManager)
                                .environmentObject(cardVM)
                        }
                    }
                    TabBarView(selectedTab: $selectedTab)
                }
                .ignoresSafeArea(edges: .bottom)
            }
        }
    }
}
