//
//  RootView.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 10/20/25.
//
import SwiftUI

struct RootView: View {
    @EnvironmentObject var authVM: AuthViewModel
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
                        CustomerHomeView()
                    case .manager:
                        ManagerDashboardView()
                    }
                    TabBarView(selectedTab: $selectedTab)
                }
                .ignoresSafeArea(edges: .bottom)
            }
        }
    }
}
