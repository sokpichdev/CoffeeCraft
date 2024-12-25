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
    var body: some View {
        HStack {
            TextField("Password", text: $authVM.password)
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
struct ConfirmPasswordTextField: View {
    @ObservedObject var authVM: AuthViewModel
    var body: some View {
        HStack {
            TextField("Confirm Password", text: $authVM.confirmpassword)
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

struct LoginButton: View {
    var body: some View  {
        Button(action: {
            
        }) {
            Text("Login")
                .padding(16)
                .frame(maxWidth: .infinity, maxHeight: 45)
                .background(Color.main)
                .foregroundStyle(Color.white)
                .cornerRadius(100)
        }
    }
}
struct SignUpButton: View {
    var body: some View {
        Button(action: {
            
        }) {
            Text("Sign Up")
                .padding(16)
                .frame(maxWidth: .infinity, maxHeight: 45)
                .background(Color.main)
                .foregroundStyle(Color.white)
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
                        authVM.timerValue = 90
                    }) {
                        Text("Resend")
                            .padding(8)
                            .cornerRadius(8)
                    }
                } else {
                    Text("\(formatTime(authVM.timerValue))")
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

    private func formatTime(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let seconds = seconds % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

