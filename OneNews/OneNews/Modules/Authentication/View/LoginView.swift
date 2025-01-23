//
//  LoginView.swift
//  OneNews
//
//  Created by Sok Pich on 12/24/24.
//

import SwiftUI

struct LoginView: View {
    @StateObject var authVM = AuthViewModel()
    
    var body: some View {
        VStack(spacing: 0){
            CustomNavigation()
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 0) {
                    CustomLabel(text: "Login", font: .largeTitle, fontWeight: .semibold, textColor: .main)
                    UnderLineView()
                }
                .padding(.vertical, 30)
                
                UserNameTextField(authVM: authVM)
                PasswordTextField(authVM: authVM, passType: .password)
                HStack {
                    Spacer()
                    NavigationLink(destination: ForgotPasswordView(authVM: authVM)) {
                        Text("Forgot Password?").foregroundStyle(.letters.opacity(0.5))
                    }
                }
                
                AuthButton(btnType: .login) {
                    if authVM.isUsernameValid && authVM.isPasswordValid {
                        print("Login successful!")
                        authVM.clearTextField()
                    } else {
                        print("Login failed!")
                        
                    }
                }
                
                HStack {
                    Spacer()
                    Text("Or")
                        .fontWeight(.bold)
                        .padding(10)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.letters.opacity(0.5), lineWidth: 0.5))
                    Spacer()
                }
                LoginOTPButton(authVM: authVM)
                NavigationLink(destination: RegisterView(authVM: authVM)) {
                    HStack(spacing: 5) {
                        Spacer()
                        Text("Don't have an account?").foregroundColor(.letters)
                        Text("Sign up here").foregroundColor(.main)
                        Spacer()
                    }
                }
            }
            .padding(16)
            Spacer()
        }
//        .background(Color.background)
        .onAppear() {
            authVM.clearTextField()
        }
    }
//    func validateInputs() -> Bool {
//        return authVM.isUsernameValid && authVM.isPasswordValid
//    }
}
