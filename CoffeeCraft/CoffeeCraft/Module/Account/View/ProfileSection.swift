//
//  ProfileSection.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 3/30/26.
//

import SwiftUI

// MARK: - Profile Section
struct ProfileSection: View {
    @EnvironmentObject var authVM: AuthViewModel
    @EnvironmentObject var userSession: UserSession
    
    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.accentPrimary,
                                     Color.accentPrimary.opacity(0.75),
                                     Color.accentPrimary.opacity(0.5)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 80, height: 80)
                
                Image(systemName: "person.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)
                    .foregroundColor(.white)
            }
            .shadow(color: Color.surfacePrimary.opacity(0.3), radius: 8, y: 4)
            
            VStack(spacing: 6) {
                Text(UserSession.shared.userName ?? "")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.textPrimary)
                
                NavigationLink {
                    if userSession.isLoggedIn {
                        ProfileView()
                            .environmentObject(authVM)
                    } else {
                        AuthView().environmentObject(authVM)
                    }
                } label: {
                    HStack(spacing: 6) {
                        Text("View Profile")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        Image(systemName: "arrow.right.circle.fill")
                            .font(.headline)
                    }
                    .foregroundColor(Color.accentPrimary)
                }
            }
        }
        .padding(.vertical, 24)
        .padding(.horizontal)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.surfacePrimary)
        )
    }
}
