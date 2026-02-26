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
    @State private var heroAppeared = false
    @Namespace private var tabNamespace

    var body: some View {
        ZStack {
            // MARK: - Background
            Color(.systemGroupedBackground)
                .ignoresSafeArea()

            Ellipse()
                .fill(
                    RadialGradient(
                        colors: [Color.brown.opacity(0.10), .clear],
                        center: .center,
                        startRadius: 0,
                        endRadius: 280
                    )
                )
                .frame(width: 500, height: 360)
                .offset(y: -260)
                .ignoresSafeArea()

            CustomRefreshScrollView( {
                VStack(spacing: 0) {
//
                    heroSection
                        .padding(.top, 48)
                        .padding(.bottom, 32)
//
                    Group {
                        if isLogin {
                            LoginView()
                                .transition(.asymmetric(
                                    insertion: .move(edge: .leading).combined(with: .opacity),
                                    removal: .move(edge: .trailing).combined(with: .opacity)
                                ))
                        } else {
                            RegisterView()
                                .transition(.asymmetric(
                                    insertion: .move(edge: .trailing).combined(with: .opacity),
                                    removal: .move(edge: .leading).combined(with: .opacity)
                                ))
                        }
                    }
                    .padding(.horizontal, 24)

                    // MARK: - Toggle Link
                    Button {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.78)) {
                            isLogin.toggle()
                            authVM.resetForm()
                        }
                    } label: {
                        Group {
                            Text(isLogin ? "Don't have an account? " : "Already have an account? ")
                                .foregroundStyle(Color(.secondaryLabel)) +
                            Text(isLogin ? "Sign Up" : "Log In")
                                .foregroundStyle(Color.brown)
                                .fontWeight(.semibold)
                        }
                        .font(.subheadline)
                    }
                    .padding(.top, 20)
                    .padding(.bottom, 48)
                }
                .padding(.horizontal, 16)
                .simultaneousGesture(
                    TapGesture().onEnded {
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    }
                )
            })
        }
    }

    // MARK: - Hero Section
    private var heroSection: some View {
        VStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(Color.brown.opacity(0.10))
                    .frame(width: 100, height: 100)

                Circle()
                    .stroke(Color.brown.opacity(0.18), lineWidth: 1)
                    .frame(width: 86, height: 86)

                Image(systemName: "cup.and.saucer.fill")
                    .font(.system(size: 40, weight: .medium))
                    .foregroundStyle(Color.brown)
            }
            .scaleEffect(heroAppeared ? 1 : 0.65)
            .opacity(heroAppeared ? 1 : 0)
            .animation(.spring(response: 0.55, dampingFraction: 0.65).delay(0.08), value: heroAppeared)

            VStack(spacing: 5) {
                Text("CoffeeCraft")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundStyle(Color(.label))

                Text(isLogin ? "Welcome back ☕️" : "Join the craft 🌿")
                    .font(.subheadline)
                    .foregroundStyle(Color(.secondaryLabel))
                    .animation(.easeInOut(duration: 0.2), value: isLogin)
            }
            .offset(y: heroAppeared ? 0 : 14)
            .opacity(heroAppeared ? 1 : 0)
            .animation(.spring(response: 0.55, dampingFraction: 0.78).delay(0.18), value: heroAppeared)
        }
        .onAppear { heroAppeared = true }
    }
}
