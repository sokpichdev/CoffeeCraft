//
//  LoginView.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 12/13/25.
//
import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authVM: AuthViewModel
    var onForgotPassword: () -> Void

    @State private var appeared = false
    @Environment(\.dismiss) private var dismiss
    private var isDisabled: Bool {
        authVM.email.isEmpty || authVM.password.isEmpty
    }

    var body: some View {
        VStack(spacing: 20) {

            // MARK: - Fields
            VStack(spacing: 12) {
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
            }

            // MARK: - Forgot Password
            HStack {
                Spacer()
                Button {
                    onForgotPassword()
                } label: {
                    Text("Forgot Password?")
                        .font(.footnote)
                        .fontWeight(.medium)
                        .foregroundColor(Color.accentPrimary)
                }
            }
            CustomCoffeeButton(title: "Log In", isDisabled: isDisabled) {
                if authVM.validateLoginForm() {
                    Task {
                        let success = await authVM.login(email: authVM.email, password: authVM.password)
                        if success {
                            dismiss()
                        }
                    }
                }
            }

            // MARK: - Divider
            HStack(spacing: 10) {
                Rectangle()
                    .fill(Color(.separator).opacity(0.5))
                    .frame(height: 1)
                Text("or")
                    .font(.caption)
                    .foregroundColor(Color(.tertiaryLabel))
                    .fixedSize()
                Rectangle()
                    .fill(Color(.separator).opacity(0.5))
                    .frame(height: 1)
            }

//            HStack(spacing: 10) {
//                socialButton(icon: "apple.logo", label: "Apple")
//                socialButton(icon: "globe", label: "Google")
//            }
        }
        .padding(20)
        .background(
            Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 18, style: .continuous)
        )
        .shadow(color: Color(.label).opacity(0.06), radius: 12, y: 4)
        .offset(y: appeared ? 0 : 20)
        .opacity(appeared ? 1 : 0)
        .onAppear { appeared = true }
    }

    @ViewBuilder
    private func socialButton(icon: String, label: String) -> some View {
        Button {
            // TODO: social sign-in
        } label: {
            HStack(spacing: 7) {
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .medium))
                Text(label)
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            .foregroundColor(Color(.label))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(Color(.systemGroupedBackground), in: RoundedRectangle(cornerRadius: 11, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 11, style: .continuous)
                    .stroke(Color(.separator).opacity(0.5), lineWidth: 1)
            )
        }
    }
}
