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
        VStack(alignment: .leading, spacing: 4) {
            TextField("Email or Phone Number", text: $authVM.username, onEditingChanged: { _ in
                validateUsername()
            }, onCommit: {
                validateUsername()
            })
            .padding(16)
            .frame(maxWidth: .infinity, maxHeight: 50)
            .background(Color.optionBtn1)
            .cornerRadius(100)
            .onChange(of: authVM.username) { _ in
                validateUsername()
            }
            
            if let error = authVM.usernameError {
                Text(error)
                    .font(.footnote)
                    .foregroundColor(.red)
            }
        }
        .keyboardType(.twitter)
    }
    func validateUsername() {
        let emailPattern = #"^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
        let phonePattern = #"^\d{9}$"#
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailPattern)
        let phonePredicate = NSPredicate(format: "SELF MATCHES %@", phonePattern)

        if authVM.username.isEmpty {
            authVM.usernameError = "Please enter Email or Phone number."
            authVM.isUsernameValid = false
        } else if emailPredicate.evaluate(with: authVM.username) || phonePredicate.evaluate(with: authVM.username) {
            authVM.usernameError = nil
            authVM.isUsernameValid = true
        } else {
            authVM.usernameError = "Please enter a valid email or phone number."
            authVM.isUsernameValid = false
        }
    }
}


struct PasswordTextField: View {
    @ObservedObject var authVM: AuthViewModel
    var passType: PasswordType
    @State private var isSecure: Bool = true
    @State private var errorMessage: String? = nil

    private var passwordBinding: Binding<String> {
        switch passType {
        case .confirmPassword: return $authVM.confirmPassword
        case .newPassword: return $authVM.newPassword
        case .currentPassword: return $authVM.currentPassword
        case .password: return $authVM.password
        }
    }

    private var passwordText: String {
        switch passType {
        case .confirmPassword: return "Confirm Password"
        case .newPassword: return "New Password"
        case .currentPassword: return "Current Password"
        case .password: return "Password"
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                if isSecure {
                    SecureField(passwordText, text: passwordBinding)
                        .onChange(of: passwordBinding.wrappedValue) { _ in
                            validatePassword()
                        }
                } else {
                    TextField(passwordText, text: passwordBinding)
                        .onChange(of: passwordBinding.wrappedValue) { _ in
                            validatePassword()
                        }
                }
                Spacer()
                Button(action: {
                    isSecure.toggle()
                }) {
                    Image(systemName: isSecure ? "eye.slash" : "eye")
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity, maxHeight: 50)
            .background(Color.optionBtn1)
            .cornerRadius(100)
            
            if let error = errorMessage {
                Text(error)
                    .font(.footnote)
                    .foregroundColor(.red)
            }
        }
    }

    private func validatePassword() {
        switch passType {
        case .currentPassword:
            errorMessage = passwordBinding.wrappedValue.isEmpty ? "Please enter your current password." : nil
        case .newPassword:
            let pattern = #"^(?=.*[A-Z])(?=.*[a-z])(?=.*\d).{8,}$"#
            let isValid = NSPredicate(format: "SELF MATCHES %@", pattern).evaluate(with: passwordBinding.wrappedValue)
            errorMessage = passwordBinding.wrappedValue.isEmpty ? "Please enter a new password." : !isValid ? "New password must include upper, lower, and numeric characters." : nil
        case .confirmPassword:
            errorMessage = passwordBinding.wrappedValue.isEmpty ? "Please confirm your password." : passwordBinding.wrappedValue != authVM.newPassword ? "Passwords do not match." : nil
        case .password:
            errorMessage = passwordBinding.wrappedValue.isEmpty ? "Please enter your password." : nil
        }
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
                .frame(maxWidth: maxWidth, maxHeight: 60)
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
            .frame(maxWidth: .infinity, maxHeight: 60)
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
        .keyboardType(.numberPad)
        .padding(16)
        .frame(maxWidth: .infinity, maxHeight: 50)
        .background(Color.optionBtn1)
        .cornerRadius(100)
    }

    
}

