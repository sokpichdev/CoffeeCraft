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
            TextField("Email or Phone Number", text: $authVM.username)
            .padding(16)
            .frame(maxWidth: .infinity, maxHeight: 50)
            .background(Color.optionBtn1)
            .cornerRadius(100)
            .onChange(of: authVM.username) { _ in
                authVM.validateUsername()
            }
            if let error = authVM.usernameError {
                HStack {
                    Text(error)
                        .font(.footnote)
                        .foregroundColor(.red)
                    Spacer()
                }
                .padding(.horizontal, 16)
            }
        }
        .keyboardType(.twitter)
    }
}

struct PasswordTextField: View {
    @ObservedObject var authVM: AuthViewModel
    var passType: PasswordType
    @State private var isSecure: Bool = true

    private var passwordBinding: Binding<String> {
        Binding(
            get: {
                switch passType {
                case .confirmPassword: return authVM.confirmPassword
                case .newPassword: return authVM.newPassword
                case .currentPassword: return authVM.currentPassword
                case .password: return authVM.password
                }
            },
            set: { newValue in
                switch passType {
                case .confirmPassword: authVM.confirmPassword = newValue
                case .newPassword: authVM.newPassword = newValue
                case .currentPassword: authVM.currentPassword = newValue
                case .password: authVM.password = newValue
                }
            }
        )
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                if isSecure {
                    SecureField(authVM.passwordText(for: passType), text: passwordBinding)
                        .onChange(of: passwordBinding.wrappedValue) { _ in
                            authVM.validatePassword(for: passType)
                        }
                } else {
                    TextField(authVM.passwordText(for: passType), text: passwordBinding)
                        .onChange(of: passwordBinding.wrappedValue) { _ in
                            authVM.validatePassword(for: passType)
                        }
                }
                Spacer()
                Button(action: {
                    isSecure.toggle()
                }) {
                    CusImage(ImageName: isSecure ? "hide" : "show")
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity, maxHeight: 50)
            .background(Color.optionBtn1)
            .cornerRadius(100)
            
            // Conditionally show the error Text only if the error is not nil
            if let error = getErrorText(for: passType) {
                Text(error)
                    .font(.footnote)
                    .foregroundColor(.red)
            }
        }
    }
    
    private func getErrorText(for passType: PasswordType) -> String? {
        switch passType {
        case .password: return authVM.passwordError
        case .confirmPassword: return authVM.confirmPasswordError
        case .currentPassword: return authVM.currentPasswordError
        case .newPassword: return authVM.newPasswordError
        }
    }
}


struct AuthButton: View {
    var btnType: AuthButtonType
    var maxWidth: CGFloat = .infinity
    var bgColor: Color = .main
    var fgColor: Color = .white
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
        case .submit:
            return "Submit"
        }
    }
    
    var body: some View {
        Button(action: {
            onTap?()
        }) {
            Text(buttonText)
                .fontWeight(.bold)
                .padding(16)
                .frame(maxWidth: maxWidth, maxHeight: 50)
                .background(bgColor)
                .foregroundColor(fgColor)
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
                    Button("Resend") {
                        authVM.otpEnded = false
                        authVM.timerValue = 20
                        authVM.startTimer()
                    }
                    .padding(8)
                    .cornerRadius(8)
                } else {
                    Text("\(authVM.formatTime(authVM.timerValue))")
                        .font(.subheadline)
                        .foregroundColor(.letters)
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

