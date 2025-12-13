//
//  AuthView.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 10/20/25.
//
import SwiftUI

struct AuthView: View {
    @EnvironmentObject var authVM: AuthViewModel
    // State variables for the fields
    @State private var email = ""
    @State private var password = ""
    @State private var name = ""
    @State private var role: UserRole = .customer
    
    @State private var isLogin = true

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(colors: [.brown.opacity(0.8), .black],
                           startPoint: .topLeading,
                           endPoint: .bottomTrailing)
                .ignoresSafeArea()

            VStack(spacing: 24) {
                Spacer()

                // Title
                Text(isLogin ? "Welcome Back ☕️" : "Create Account 🌿")
                    .font(.system(.largeTitle, design: .rounded)).bold()
                    .foregroundStyle(.white)
                    .transition(.opacity.combined(with: .slide))
                    .padding(.bottom, 8)
                
                // --- Conditional View ---
                if isLogin {
                    LoginView(email: $email, password: $password)
                        .transition(.move(edge: .leading).combined(with: .opacity))
                } else {
                    RegisterView(name: $name, email: $email, password: $password, role: $role)
                        .transition(.move(edge: .trailing).combined(with: .opacity))
                }
                // --- End Conditional View ---

                // Switch between login/signup
                Button {
                    withAnimation(.spring()) {
                        isLogin.toggle()
                        clearFields()
                    }
                } label: {
                    Text(isLogin ? "Don’t have an account? Sign Up" : "Already have an account? Login")
                        .font(.customCallout)
                        .foregroundStyle(.white.opacity(0.8))
                        .padding(.top, 8)
                }
                .padding(.horizontal)

                Spacer()
            }
            .padding()
        }
    }

    private func clearFields() {
        email = ""
        password = ""
        name = ""
        role = .customer // Reset role to default
    }
}
