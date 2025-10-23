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
                            ComingSoonView()
                                .environmentObject(authVM)
                        case .menu:
                            CustomerHomeView()
                                .environmentObject(cartManager)
                        case .orders:
                            OrdersView()
                        case .profile:
                            ComingSoonView()
                                .environmentObject(authVM)
                        }
                    case .manager:
                        switch selectedTab {
                        case .home:
                            ComingSoonView().environmentObject(authVM)
                        case .menu:
                            ComingSoonView().environmentObject(authVM)
                        case .orders:
                            AdminOrdersView()
                        case .profile:
                            ComingSoonView().environmentObject(authVM)
                        }
                    }
                    TabBarView(selectedTab: $selectedTab)
                }
                .ignoresSafeArea(edges: .bottom)
            }
        }
    }
}
