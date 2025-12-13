//
//  LoginView.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 12/13/25.
//
import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @Binding var email: String
    @Binding var password: String
    @State private var isLoading = false
    @FocusState private var focusedField: Field?

    @State private var showForgotPassword = false

    enum Field {
        case email, password
    }

    var body: some View {
        VStack(spacing: 16) {
            
            // Email Field
            MaterialTextField(
                text: $email,
                placeholder: "Email Address",
                keyboardType: .emailAddress,
                fieldtype: .email
            )
            .focused($focusedField, equals: .email)
            .submitLabel(.next)
            .textContentType(.emailAddress)

            // Password Field
            MaterialTextField(
                text: $password,
                placeholder: "Password",
                fieldtype: .password
            )
            .focused($focusedField, equals: .password)
            .submitLabel(.done)
            .textContentType(.password)
            
            // Forgot Password Button
            HStack {
                Spacer()
                Button("Forgot Password?") {
                    showForgotPassword = true
                }
                .font(.customCallout)
                .foregroundStyle(Color.brown.opacity(0.8))
            }
            .padding(.top, 4)
            
            // Login Button
            Button {
                Task {
                    isLoading = true
                    do {
                        try await authVM.login(email: email, password: password)
                    } catch {
                        print("Login Error: \(error.localizedDescription)")
                    }
                    isLoading = false
                }
            } label: {
                HStack {
                    if isLoading {
                        ProgressView().tint(.white)
                    } else {
                        Text("Login").fontWeight(.semibold)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.brown.gradient)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .shadow(color: .brown.opacity(0.4), radius: 6, y: 4)
            }
            .disabled(isLoading || email.isEmpty || password.isEmpty)
        }
        .padding(24)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: .black.opacity(0.25), radius: 10, x: 0, y: 8)
        .sheet(isPresented: $showForgotPassword) {
            ForgotPasswordView()
                .environmentObject(authVM)
        }
    }
}
