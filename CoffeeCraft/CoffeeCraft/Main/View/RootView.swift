import FirebaseAuth
//
//  RootView.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 10/20/25.
//
import SwiftUI

struct RootView: View {
    @EnvironmentObject var session: UserSession
    @EnvironmentObject var authVM: AuthViewModel
    @EnvironmentObject var orderVM: OrderViewModel
    @EnvironmentObject var coordinator: NotificationCoordinator
    @EnvironmentObject var walletVM: WalletViewModel

    @StateObject var inboxVM = InboxViewModel()
    @StateObject var productVM = ProductViewModel()
    @StateObject var cartManager = CartManager()
    @StateObject var cardVM = CardViewModel()
    @StateObject var favVM = FavoriteViewModel()
    @StateObject var announcementVM = AnnouncementViewModel()
    
    @State private var selectedTab: Tab = .home

    var body: some View {
        Group {
            if session.isRestoring {
                CoffeeLoaderView()
            } else {
                VStack(spacing: 0) {
                        switch selectedTab {
                        case .dashboard:
                            AdminDashboardHomeView()
                        case .home:
                            HomeView(selectedTab: $selectedTab)
                                .environmentObject(announcementVM)
                                .environmentObject(walletVM)
                                .environmentObject(cardVM)
                        case .menu:
                            if session.currentUser?.role == .manager {
                                MenuView(isManager: true)
                                    .environmentObject(cartManager)
                                    .environmentObject(favVM)
                                    .environmentObject(cardVM)
                                    .environmentObject(productVM)
                                    .environmentObject(walletVM)
                                    .environmentObject(OrderEnvironment.shared)
                            } else {
                                MenuView()
                                    .environmentObject(cartManager)
                                    .environmentObject(favVM)
                                    .environmentObject(cardVM)
                                    .environmentObject(productVM)
                                    .environmentObject(walletVM)
                                    .environmentObject(OrderEnvironment.shared)
                            }
                        case .orders:
                            if session.currentUser?.role == .manager {
                                AdminOrdersView()
                                    .environmentObject(cartManager)
                            } else {
                                OrdersView()
                                    .environmentObject(orderVM)
                                    .environmentObject(cartManager)
                                    .environmentObject(coordinator)
                            }
                        case .profile:
                            AccountView()
                                .environmentObject(favVM)
                                .environmentObject(announcementVM)
                                .environmentObject(authVM)
                                .environmentObject(cardVM)
                                .environmentObject(inboxVM)
                                .environmentObject(walletVM)
                        }
                    TabBarView(selectedTab: $selectedTab)
                }
                .ignoresSafeArea(edges: .bottom)
                .onAppear {
                    if session.currentUser != nil {
                        Task {
                            await inboxVM.fetchNotifications(pageNum: 1)
                        }
                    }
                    if let userId = session.userId {
                        walletVM.setup(userId: userId)
                        cardVM.setUser(userId: userId)
                    }
                }
                .onChange(of: session.currentUser) { _, newUser in
                    if let userId = newUser?.id {
                        walletVM.setup(userId: userId)
                    }
                    // Reset to home whenever the account switches.
                    // Prevents a customer from inheriting .dashboard if a manager was logged in before.
                    selectedTab = .home
                }
            }
        }
        .onChange(of: coordinator.shouldNavigateToOrders) { _, _ in
            selectedTab = .orders
        }
        .onChange(of: NetworkMonitor.shared.isConnected) { _, isConnected in
            // The OfflineBannerModifier handles the offline state visually.
            // We only show an alert when the connection is restored so the user knows their queued actions will now complete.
            if isConnected {
                AlertManager.shared.showSuccess(title: "Back Online",
                                                message: "Your connection has been restored.")
            }
        }
    }
}
