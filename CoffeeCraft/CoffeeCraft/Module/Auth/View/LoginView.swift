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
            MaterialTextField(
                text: $email,
                placeholder: "Email Address",
                keyboardType: .emailAddress,
                fieldtype: .email
            )

            MaterialTextField(
                text: $password,
                placeholder: "Password",
                fieldtype: .password
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
