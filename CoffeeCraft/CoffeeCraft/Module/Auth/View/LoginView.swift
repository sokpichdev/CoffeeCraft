//
//  LoginView.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 12/13/25.
//
import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @State private var showForgotPassword = false

    var body: some View {
        VStack(spacing: 16) {
            CustomTextField1(
                text: $authVM.email,
                placeHolder: "Email Address",
                keyboardType: .emailAddress,
                fieldType: .email,
                isAutoCorrect: false,
                isStarMark: true,
                leadingIcon: .username,
                trailingView: EmptyView(),
                isValidate: $authVM.emailValidation.isValid,
                validateText: authVM.emailValidation.message,
                isAutoCapitalize: .none,
                onTextChange: { _ in authVM.validateEmail() }
            )
            
            CustomTextField1(
                text: $authVM.password,
                placeHolder: "Password",
                fieldType: .password,
                isAutoCorrect: false,
                isStarMark: true,
                leadingIcon: .lock,
                trailingView: EmptyView(),
                isValidate: $authVM.passwordValidation.isValid,
                validateText: authVM.passwordValidation.message,
                isAutoCapitalize: .none,
                onTextChange: { _ in authVM.validatePassword() }
            )
            
            HStack {
                Spacer()
                Button("Forgot Password?") {
                    showForgotPassword = true
                }
                .font(.callout)
                .foregroundStyle(Color.white)
            }
            .padding(.top, 4)
            
            Button {
                if authVM.validateLoginForm() {
                    Task {
                        authVM.isLoading = true
                        do {
                            try await authVM.login(email: authVM.email, password: authVM.password)
                        } catch {
                            print("Login Error: \(error.localizedDescription)")
                        }
                        authVM.isLoading = false
                    }
                }
            } label: {
                HStack {
                    if authVM.isLoading {
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
            .disabled(authVM.isLoading || authVM.email.isEmpty || authVM.password.isEmpty)
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
