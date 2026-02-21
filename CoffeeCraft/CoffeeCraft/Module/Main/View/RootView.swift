//
//  RootView.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 10/20/25.
//
import SwiftUI
import FirebaseAuth

struct RootView: View {
    @EnvironmentObject var session: UserSession
    @EnvironmentObject var authVM: AuthViewModel
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var orderVM: OrderViewModel
    @EnvironmentObject var coordinator: NotificationCoordinator
    
    @StateObject var productVM = ProductViewModel()
    @StateObject var cartManager = CartManager()
    @StateObject var cardVM = CardViewModel()
    @StateObject var favVM = FavoriteViewModel()
    @StateObject var announcementVM = AnnouncementViewModel()
    @State private var selectedTab: Tab = .home
    
    var body: some View {
        Group {
            if UserSession.shared.currentUser == nil {
                AuthView()
            } else if authVM.isLoading {
                CoffeeLoaderView()
            } else {
                VStack(spacing: 0) {
                    // MARK: - Main Content
                    // Show the selected tab's root view
                    switch UserSession.shared.currentUser?.role {
                    case .customer:
                        switch selectedTab {
                        case .home:
                            HomeView(selectedTab: $selectedTab)
                                .environmentObject(authVM)
                                .environmentObject(announcementVM)
                        case .menu:
                            MenuView()
                                .environmentObject(cartManager)
                                .environmentObject(favVM)
                                .environmentObject(cardVM)
                                .environmentObject(productVM)
                        case .orders:
                            OrdersView()
                                .environmentObject(orderVM)
                                .environmentObject(coordinator)
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
                                .environmentObject(announcementVM)
                        case .menu:
                            MenuView(isManager: true)
                                .environmentObject(cartManager)
                                .environmentObject(favVM)
                                .environmentObject(cardVM)
                                .environmentObject(productVM)
                        case .orders:
                            AdminOrdersView()
                        case .profile:
                            AccountView()
                                .environmentObject(favVM)
                                .environmentObject(announcementVM)
                                .environmentObject(authVM)
                                .environmentObject(themeManager)
                                .environmentObject(cardVM)
                        }
                    case .none:
                        AuthView()
                    }
                    TabBarView(selectedTab: $selectedTab)
                }
                .ignoresSafeArea(edges: .bottom)
            }
        }
        .onChange(of: coordinator.shouldNavigateToOrders) { _, _ in
            selectedTab = .orders
        }
    }
}
