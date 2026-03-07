//
//  ForgotPasswordView.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 12/13/25.
//
import SwiftUI

struct ForgotPasswordView: View {
    @EnvironmentObject var authVM: AuthViewModel
    var onBack: () -> Void

    @State private var isSending = false
    @State private var appeared = false

    private var isDisabled: Bool {
        isSending || authVM.email.isEmpty
    }

    var body: some View {
        VStack(spacing: 20) {
            VStack(spacing: 6) {
                Text("Forgot your password?")
                    .font(.headline)
                    .foregroundStyle(Color(.label))

                Text("Enter your email and we'll send you a link to reset it.")
                    .font(.subheadline)
                    .foregroundStyle(Color(.secondaryLabel))
                    .multilineTextAlignment(.center)
            }

            // MARK: - Email Field
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

            // MARK: - Send Button
            CustomCoffeeButton(title: "Send Reset Link", isDisabled: isDisabled) {
                Task {
                    isSending = true
                    LoaderManager.shared.showLoading()
                    do {
                        try await authVM.sendPasswordReset(email: authVM.email)
                        LoaderManager.shared.hideLoading()
                        AlertManager.shared.showSuccess(message: "Reset link sent to \(authVM.email).")
                        authVM.resetForm(isResetEmail: true)
                        onBack()
                    } catch {
                        LoaderManager.shared.hideLoading()
                        AlertManager.shared.showError(title: "Error", message: error.localizedDescription)
                    }
                    isSending = false
                }
            }

            Button {
                onBack()
            } label: {
                HStack(spacing: 5) {
                    Image(systemName: "chevron.left")
                        .font(.footnote.weight(.semibold))
                    Text("Back to Log In")
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
                .foregroundStyle(Color.accentPrimary)
            }
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
}
