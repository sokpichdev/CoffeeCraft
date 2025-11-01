//
//  AuthView.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 10/20/25.
//
import SwiftUI

struct AuthView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @State private var email = ""
    @State private var password = ""
    @State private var name = ""
    @State private var role: UserRole = .customer
    @State private var isLogin = true
    @State private var isLoading = false
    @FocusState private var focusedField: Field?

    enum Field {
        case name, email, password
    }

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

                // Form container
                VStack(spacing: 16) {
                    if !isLogin {
                        CustomTextField(title: "Full Name", text: $name, icon: "person.fill")
                            .focused($focusedField, equals: .name)
                            .submitLabel(.next)
                    }

                    CustomTextField(title: "Email Address", text: $email, icon: "envelope.fill", keyboardType: .emailAddress)
                        .focused($focusedField, equals: .email)
                        .submitLabel(.next)

                    CustomSecureField(title: "Password", text: $password, icon: "lock.fill")
                        .focused($focusedField, equals: .password)
                        .submitLabel(.done)

                    if !isLogin {
                        Picker("Role", selection: $role) {
                            Text("Customer").tag(UserRole.customer)
                            Text("Manager").tag(UserRole.manager)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .padding(.top, 6)
                    }
                }
                .padding(24)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
                .shadow(color: .black.opacity(0.25), radius: 10, x: 0, y: 8)
                .padding(.horizontal)

                // Auth button
                Button {
                    Task {
                        isLoading = true
                        do {
                            if isLogin {
                                try await authVM.login(email: email, password: password)
                            } else {
                                try await authVM.signUp(name: name, email: email, password: password, role: role)
                            }
                        } catch {
                            print("Error: \(error.localizedDescription)")
                        }
                        isLoading = false
                    }
                } label: {
                    HStack {
                        if isLoading {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Text(isLogin ? "Login" : "Sign Up")
                                .fontWeight(.semibold)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.brown.gradient)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .shadow(color: .brown.opacity(0.4), radius: 6, y: 4)
                }
                .padding(.horizontal)

                // Switch between login/signup
                Button {
                    withAnimation(.spring()) {
                        isLogin.toggle()
                        clearFields()
                    }
                } label: {
                    Text(isLogin ? "Don’t have an account? Sign Up" : "Already have an account? Login")
                        .font(.callout)
                        .foregroundStyle(.white.opacity(0.8))
                        .padding(.top, 8)
                }

                Spacer()
            }
            .padding()
        }
    }

    private func clearFields() {
        email = ""
        password = ""
        name = ""
    }
}
