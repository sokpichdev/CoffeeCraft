//
//  RootView.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 10/20/25.
//
import SwiftUI

struct RootView: View {
    @EnvironmentObject var authVM: AuthViewModel

    var body: some View {
        Group {
            if authVM.isLoading {
                ProgressView("Loading...")
            } else if authVM.currentUser == nil {
                AuthView()
            } else {
                switch authVM.currentUser!.role {
                case .customer:
                    CustomerHomeView()
                case .manager:
                    ManagerDashboardView()
                }
            }
        }
    }
}
