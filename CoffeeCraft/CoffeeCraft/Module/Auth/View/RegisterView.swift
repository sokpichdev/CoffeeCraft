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
    var body: some View {
        VStack(spacing: 16) {
            CustomTextField1(text: $authVM.name,
                             placeHolder: "User Name",
                             charLimit: 15,
                             fieldType: .normal,
                             isAutoCorrect: false, isStarMark: true,
                             leadingIcon: .username,
                             trailingView: EmptyView(),
                             isValidate: $authVM.nameValidation.isValid,
                             validateText: authVM.nameValidation.message,
                             isAutoCapitalize: .none,
                             onTextChange: { _ in
                authVM.checkUsername()
            })
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
                             onTextChange: { _ in
                authVM.validateEmail()
            })
            CustomTextField1(text: $authVM.password,
                             placeHolder: "Password",
                             charLimit: 15,
                             keyboardType: .alphabet,
                             fieldType: .password,
                             isAutoCorrect: false, isStarMark: true,
                             leadingIcon: .lock,
                             trailingView: EmptyView(),
                             isValidate: $authVM.passwordValidation.isValid,
                             validateText: authVM.passwordValidation.message,
                             isAutoCapitalize: .none,
                             onTextChange: { _ in
                authVM.validatePassword()
            })

            Picker("Role", selection: $authVM.role) {
                Text("Customer").tag(UserRole.customer)
                Text("Manager").tag(UserRole.manager)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.top, 6)

            Button {
                if authVM.validateRegisterForm() {
                    Task {
                        authVM.isLoading = true
                        defer { authVM.isLoading = false }
                        
                        await authVM.signUp(name: authVM.name, email: authVM.email, password: authVM.password, role: authVM.role) { result in
                            switch result {
                            case .success(let userInfo):
                                // Wrap card creation in Task (fire-and-forget)
                                Task {
                                    do {
                                        try await cardVM.createInitialCard(
                                            userId: userInfo.id,
                                            userName: userInfo.name
                                        )
                                        AppLog.auth.info("✅ Card created successfully!")
                                    } catch {
                                        AppLog.auth.error("❌ Card Error: \(error.localizedDescription)")
                                        // Signup succeeded, card failed = OK!
                                    }
                                }
                                
                            case .failure(let error):
                                AppLog.auth.error("❌ Signup Error: \(error.localizedDescription)")
                                authVM.errorMessage = error.localizedDescription
                            }
                        }
                    }

                }
            } label: {
                HStack {
                    if authVM.isLoading {
                        ProgressView().tint(.white)
                    } else {
                        Text("Sign Up").fontWeight(.semibold)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.brown.gradient)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .shadow(color: .brown.opacity(0.4), radius: 6, y: 4)
            }
            .disabled(authVM.isLoading || authVM.name.isEmpty || authVM.email.isEmpty || authVM.password.isEmpty)
        }
        .padding(24)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: .black.opacity(0.25), radius: 10, x: 0, y: 8)
    }
}
