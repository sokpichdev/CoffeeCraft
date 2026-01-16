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
    @StateObject var cartManager = CartManager(userId: Auth.auth().currentUser?.uid ?? "guest")
    @StateObject var favVM = FavoriteViewModel()
    @State private var selectedTab: Tab = .home
    
    var body: some View {
        Group {
            if authVM.isLoading {
                ProgressView("Loading...")
            } else if authVM.currentUser == nil {
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
                        case .menu:
                            MenuView()
                                .environmentObject(cartManager)
                                .environmentObject(favVM)
                        case .orders:
                            OrdersView()
                        case .profile:
                            AccountView()
                                .environmentObject(favVM)
                                .environmentObject(authVM)
                        }
                    case .manager:
                        switch selectedTab {
                        case .home:
                            HomeView(selectedTab: $selectedTab)
                        case .menu:
                            MenuView(isManager: true)
                                .environmentObject(cartManager)
                                .environmentObject(favVM)
                        case .orders:
                            AdminOrdersView()
                        case .profile:
                            AccountView()
                                .environmentObject(favVM)
                                .environmentObject(authVM)
                        }
                    }
                    TabBarView(selectedTab: $selectedTab)
                }
                .ignoresSafeArea(edges: .bottom)
            }
        }
    }
}
