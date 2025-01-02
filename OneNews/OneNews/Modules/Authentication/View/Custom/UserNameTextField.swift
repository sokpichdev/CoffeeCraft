//
//  UserNameTextField.swift
//  OneNews
//
//  Created by Sok Pich on 12/24/24.
//

import SwiftUI

struct UserNameTextField: View {
    @ObservedObject var authVM: AuthViewModel
    var body: some View {
        TextField("Email or Phone Number", text: $authVM.username)
            .padding(16)
            .frame(maxWidth: .infinity, maxHeight: 45)
            .background(Color.optionBtn1)
            .cornerRadius(100)
    }
}

struct PasswordTextField: View {
    @ObservedObject var authVM: AuthViewModel
    var passType: PasswordType
    
    private var passwordText: String {
        switch passType {
        case .confirmPassword:
            return "Confirm Password"
        case .newPassword:
            return "New Password"
        case .password:
            return "Password"
        }
    }
    var body: some View {
        HStack {
            TextField(passwordText,
                text: $authVM.password)
            Spacer()
            
            Button(action: {
                authVM.isHidePassword = true
            }) {
                CusImage(ImageName: authVM.isHidePassword ? "hide" : "show")
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, maxHeight: 45)
        .background(Color.optionBtn1)
        .cornerRadius(100)
    }
}

struct AuthButton: View {
    var btnType: ButtonType
    var maxWidth: CGFloat = .infinity
    var onTap: (() -> Void)?
    
    // Computed property to determine button text
    private var buttonText: String {
        switch btnType {
        case .login:
            return "Login"
        case .register:
            return "Sign Up"
        case .confirm:
            return "Confirm"
        }
    }
    
    var body: some View {
        Button(action: {
            onTap?()
        }) {
            Text(buttonText)
                .fontWeight(.bold)
                .padding(16)
                .frame(maxWidth: maxWidth, maxHeight: 45)
                .background(Color.main)
                .foregroundColor(.white)
                .cornerRadius(100)
        }
    }
}


struct LoginOTPButton: View {
    @ObservedObject var authVM: AuthViewModel
    var body: some View  {
        NavigationLink(destination: LoginOTPView(authVM: authVM)) {
            HStack {
                Spacer()
                CusImage(ImageName: "phone")
                Text("Login with OTP").foregroundColor(.main)
                Spacer()
            }
            .padding(16)
            .frame(maxWidth: .infinity, maxHeight: 50)
            .background(Color.optionBtn1.opacity(0.7))
            .cornerRadius(50)
            .overlay(RoundedRectangle(cornerRadius: 50).stroke(Color.main, lineWidth: 1))
        }
    }
}

struct OTPTextField: View {
    @ObservedObject var authVM: AuthViewModel

    var body: some View {
        HStack {
            TextField("OTP", text: $authVM.otp)
            Spacer()

            VStack {
                if authVM.otpEnded {
                    Button(action: {
                        authVM.otpEnded = false
                        authVM.timerValue = 20
                    }) {
                        Text("Resend")
                            .padding(8)
                            .cornerRadius(8)
                    }
                } else {
                    Text("\(authVM.formatTime(authVM.timerValue))")
                }
            }
            .foregroundColor(.letters)
            .font(.subheadline)
            .padding(16)
            .frame(maxWidth: 100, maxHeight: 30)
            .background(Color.optionBtn2)
            .cornerRadius(100)
        }
        .padding(16)
        .frame(maxWidth: .infinity, maxHeight: 45)
        .background(Color.optionBtn1)
        .cornerRadius(100)
    }

    
}

