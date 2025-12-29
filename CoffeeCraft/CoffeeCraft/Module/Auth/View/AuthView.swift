//
//  AuthView.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 10/20/25.
//
import SwiftUI

struct AuthView: View {
    @EnvironmentObject var authVM: AuthViewModel
    
    @State private var isLogin = true

    var body: some View {
        ZStack {
            LinearGradient(colors: [.brown.opacity(0.8), .black],
                           startPoint: .topLeading,
                           endPoint: .bottomTrailing)
                .ignoresSafeArea()
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 24) {
                    Text(isLogin ? "Welcome Back ☕️" : "Create Account 🌿")
                        .font(.system(.largeTitle, design: .rounded)).bold()
                        .foregroundStyle(.white)
                        .transition(.opacity.combined(with: .slide))
                        .padding(.bottom, 8)
                    
                    Group {
                        if isLogin {
                            LoginView()
                                .transition(.move(edge: .leading).combined(with: .opacity))
                        } else {
                            RegisterView()
                                .transition(.move(edge: .trailing).combined(with: .opacity))
                        }
                    }
                    .padding(.horizontal)

                    Button {
                        withAnimation(.spring()) {
                            isLogin.toggle()
                            authVM.resetForm()
                        }
                    } label: {
                        Text(isLogin ? "Don’t have an account? Sign Up" : "Already have an account? Login")
                            .font(.callout)
                            .foregroundStyle(.white.opacity(0.8))
                            .padding(.top, 8)
                    }
                    .padding(.horizontal)
                }
                .simultaneousGesture(
                    TapGesture().onEnded {
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    }
                )
            }
            
        }
    }
}
