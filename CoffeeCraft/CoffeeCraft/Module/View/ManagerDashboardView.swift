//
//  ManagerDashboardView.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 10/20/25.
//
import SwiftUI

struct ManagerDashboardView: View {
    @EnvironmentObject var authVM: AuthViewModel
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, Manager!")
            Button(action: {
                authVM.logout()
            }, label: {
                Text("Logout")
            })
        }
        .padding()
    }
}
