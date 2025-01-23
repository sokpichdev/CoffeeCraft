//
//  RegisterView.swift
//  OneNews
//
//  Created by Sok Pich on 12/25/24.
//

import SwiftUI
import Combine
import FirebaseAuth

struct RegisterView: View {
    @ObservedObject var authVM: AuthViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            CustomNavigation()
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 0) {
                    CustomLabel(text: "Register", font: .largeTitle, fontWeight: .semibold, textColor: .main)
                    UnderLineView()
                }
                .padding(.vertical, 30)
                UserNameTextField(authVM: authVM)
                OTPTextField(authVM: authVM)
                PasswordTextField(authVM: authVM, passType: .password)
                PasswordTextField(authVM: authVM, passType: .confirmPassword)
                
                AuthButton(btnType: .register) {
                    authVM.validateUsername()
                    authVM.validatePassword(for: .password)
                    authVM.validatePassword(for: .confirmPassword)
                    
                    if authVM.isUsernameValid && authVM.passwordError == nil && authVM.confirmPasswordError == nil {
                        authVM.registerUser()
                        print("success")
//                        self.isUserLoggedIn = true
                        if let user = Auth.auth().currentUser {
                            print("Current user: \(user.email ?? "No Email")")
                        } else {
                            print("No user signed in")
                        }


                    } else {
                        print("Validation failed.")
                    }
                }
                Spacer()
            }
            .padding(16)
        }
        .onAppear {
            authVM.observeAuthState()
            authVM.clearTextField()
        }
        .onChange(of: authVM.isUserLoggedIn) { isLoggedIn in
            if isLoggedIn {
                // Navigate to the main screen
                print("Navigate to the main screen")
            }
        }

    }
}

