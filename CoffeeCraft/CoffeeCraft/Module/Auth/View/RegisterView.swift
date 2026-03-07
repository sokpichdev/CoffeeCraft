//
//  RegisterView.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 12/13/25.
//
import SwiftUI

struct RegisterView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @StateObject var cardVM = CardViewModel()
    @State private var appeared = false
    @Environment(\.dismiss) private var dismiss
    private var isDisabled: Bool {
        authVM.isLoading || authVM.name.isEmpty || authVM.email.isEmpty || authVM.password.isEmpty
    }

    var body: some View {
        VStack(spacing: 20) {

            // MARK: - Fields
            VStack(spacing: 12) {
                CustomTextField1(
                    text: $authVM.name,
                    placeHolder: "Full Name",
                    charLimit: 15,
                    fieldType: .normal,
                    isAutoCorrect: false,
                    isStarMark: true,
                    leadingIcon: .username,
                    trailingView: EmptyView(),
                    isValidate: $authVM.nameValidation.isValid,
                    validateText: authVM.nameValidation.message,
                    isAutoCapitalize: .none,
                    onTextChange: { _ in authVM.checkUsername() }
                )

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
                    charLimit: 20,
                    keyboardType: .alphabet,
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

            // MARK: - Role Picker (hidden — all public signups are customers)
            /*
            Picker("Role", selection: $authVM.role) {
                Text("Customer").tag(UserRole.customer)
                Text("Manager").tag(UserRole.manager)
            }
            .pickerStyle(SegmentedPickerStyle())
            */

            CustomCoffeeButton(title: "Create Account", isDisabled: isDisabled) {
                if authVM.validateRegisterForm() {
                    Task {
                        await authVM.signUp(
                            name: authVM.name,
                            email: authVM.email,
                            password: authVM.password,
                            role: .customer
                        ) { result in
                            switch result {
                            case .success(let userInfo):
                                Task {
                                    do {
                                        try await cardVM.createInitialCard(userId: userInfo.id, userName: userInfo.name)
                                        AppLog.auth.info("✅ Card created successfully!")
                                    } catch {
                                        AppLog.auth.error("❌ Card Error: \(error.localizedDescription)")
                                    }
                                }
                                dismiss()
                            case .failure(let error):
                                authVM.errorMessage = error.localizedDescription
                            }
                        }
                    }
                }
            }

            // MARK: - Terms
            Text("By creating an account, you agree to our **Terms of Service** and **Privacy Policy**.")
                .font(.caption2)
                .foregroundStyle(Color(.tertiaryLabel))
                .multilineTextAlignment(.center)
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
