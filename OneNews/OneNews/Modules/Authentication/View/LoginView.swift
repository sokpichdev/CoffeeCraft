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
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 0) {
                CustomLabel(text: "Login", font: .largeTitle, fontWeight: .semibold, textColor: .main)
                UnderLineView()
            }
            .padding(.vertical, 30)
            
            UserNameTextField(authVM: authVM)
            PasswordTextField(authVM: authVM)
            HStack {
                Spacer()
                NavigationLink(destination: EmptyView()) {
                    Text("Forgot Password?").foregroundStyle(.letters.opacity(0.5))
                }
            }
            LoginButton()
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
        .customBackButton()
        Spacer()
    }
}

struct CustomBackButton: View {
    
    @Environment(\.presentationMode) var presentationMode
    var body: some View {
        Button(action: {
            presentationMode.wrappedValue.dismiss() // Go back
        }) {
            Image("backBtn") // Replace with your back button image name
        }
    }
}

extension View {
    func customBackButton() -> some View {
        self
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(leading: CustomBackButton())
    }
}
