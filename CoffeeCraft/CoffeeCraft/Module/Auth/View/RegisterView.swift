//
//  RegisterView.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 12/13/25.
//
import SwiftUI

struct RegisterView: View {
    @EnvironmentObject var authVM: AuthViewModel

    var body: some View {
        VStack(spacing: 16) {
            CustomTextField1(text: $authVM.name,
                             placeHolder: "User Name",
                             charLimit: 15,
                             fieldType: .normal,
                             isAutoCorrect: false, isStarMark: true,
                             leadingIcon: .username,
                             trailingView: EmptyView(),
                             isValidate: .constant(true),
                             validateText: authVM.errorMessage ?? "",
                             isAutoCapitalize: .none,
                             onTextChange: { _ in
                authVM.validateName()
            })
            CustomTextField1(text: $authVM.email,
                             placeHolder: "Email Address",
                             keyboardType: .emailAddress,
                             fieldType: .email,
                             isAutoCorrect: false, isStarMark: true,
                             leadingIcon: .username,
                             trailingView: EmptyView(),
                             isValidate: .constant(true), // change later
                             validateText: authVM.errorMessage ?? "",
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
                             isValidate: .constant(true),
                             validateText: authVM.errorMessage ?? "",
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
                        do {
                            try await authVM.signUp(name: authVM.name, email: authVM.email, password: authVM.password, role: authVM.role)
                        } catch {
                            print("Sign Up Error: \(error.localizedDescription)")
                        }
                        authVM.isLoading = false
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
