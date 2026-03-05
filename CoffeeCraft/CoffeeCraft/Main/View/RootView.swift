//
//  RootView.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 10/20/25.
//
import SwiftUI
import FirebaseAuth

struct RootView: View {
    @EnvironmentObject var networkMonitor: NetworkMonitor
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
    @Environment(\.pushScreen) private var push

    var body: some View {
        Group {
            if authVM.isLoading {
                CoffeeLoaderView()
            } else {
                VStack(spacing: 0) {
                        switch selectedTab {
                        case .home:
                            HomeView(selectedTab: $selectedTab)
                                .environmentObject(announcementVM)
                                .environmentObject(walletVM)
                                .environmentObject(cardVM)
                        case .menu:
                            if UserSession.shared.currentUser?.role == .manager {
                                MenuView(isManager: true)
                                    .environmentObject(cartManager)
                                    .environmentObject(favVM)
                                    .environmentObject(cardVM)
                                    .environmentObject(productVM)
                                    .environmentObject(walletVM)
                            } else {
                                MenuView()
                                    .environmentObject(cartManager)
                                    .environmentObject(favVM)
                                    .environmentObject(cardVM)
                                    .environmentObject(productVM)
                                    .environmentObject(walletVM)
                            }
                        case .map:
                            MapView(selectedTab: $selectedTab)
                                .environmentObject(OrderEnvironment.shared)
                        case .orders:
                            if UserSession.shared.currentUser?.role == .manager {
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
                    if UserSession.shared.currentUser != nil {
                        inboxVM.fetchNotifications(pageNum: 1)
                    }
                    if let userId = UserSession.shared.userId {
                        walletVM.setup(userId: userId)
                        cardVM.setUser(userId: userId)
                    }
                }
                .onChange(of: UserSession.shared.currentUser) { _, newUser in
                    if let userId = newUser?.id {
                        walletVM.setup(userId: userId)
                    }
                }
            }
        }
        .onChange(of: coordinator.shouldNavigateToOrders) { _, _ in
            selectedTab = .orders
        }
        .onChange(of: NetworkMonitor.shared.isConnected) { _, isConnected in
            guard !AlertManager.shared.showAlert else { return }
            if !isConnected {
                AlertManager.shared.showWarning(title: "No Internet", message: "You're offline. Some features may not be available.")
            } else {
                AlertManager.shared.showSuccess(title: "Back Online", message: "Your connection has been restored.")
            }
        }
    }
}
