//
//  ForgotPasswordView.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 12/13/25.
//
import SwiftUI

struct ForgotPasswordView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @Environment(\.dismiss) var dismiss
    @State private var isSending = false
    
    var body: some View {
        NavigationView {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 20) {
                    Text("Enter the email address associated with your account to receive a password reset link.")
                        .font(.callout)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    CustomTextField1(text: $authVM.email,
                                     placeHolder: "Email Address",
                                     keyboardType: .emailAddress,
                                     fieldType: .email,
                                     isAutoCorrect: false, isStarMark: true,
                                     leadingIcon: .username,
                                     trailingView: EmptyView(),
                                     isValidate: $authVM.emailValidation.isValid,
                                     validateText: authVM.emailValidation.message,
                                     isAutoCapitalize: .none,
                                     onTextChange: { _ in authVM.validateEmail() })
                    .padding(.horizontal)

                    CustomCoffeeButton(title: "Send Reset Link", isDisabled: isSending || authVM.email.isEmpty) {
                        Task {
                            isSending = true
                            LoaderManager.shared.showLoading()
                            do {
                                try await authVM.sendPasswordReset(email: authVM.email)
                                LoaderManager.shared.hideLoading()
                                AlertManager.shared.showSuccess(message: "Password reset link sent to \(authVM.email).")
                            } catch {
                                LoaderManager.shared.hideLoading()
                                AlertManager.shared.showError(title: "Error", message: error.localizedDescription)
                            }
                            isSending = false
                        }
                    }
                }
                .padding(.top, 40)
            }
            .simultaneousGesture(
                TapGesture().onEnded {
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                }
            )
            .customNavigationBar("Reset Password") {
                ToolBarButton(placement: .topBarLeading, buttonType: .text("Close")) {
                    dismiss()
                }
            }
        }
    }
}
