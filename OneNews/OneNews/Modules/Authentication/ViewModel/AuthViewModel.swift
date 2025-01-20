//
//  AuthViewModel.swift
//  OneNews
//
//  Created by Sok Pich on 12/25/24.
//

import SwiftUI
import Combine

class AuthViewModel: ObservableObject {
    @Published var username: String = ""
    
    @Published var password: String = ""
    @Published var passwordError: String? = nil
    
    @Published var currentPassword: String = ""
    @Published var currentPasswordError: String? = nil
    
    @Published var newPassword: String = ""
    @Published var newPasswordError: String? = nil
    
    @Published var confirmPassword: String = ""
    @Published var confirmPasswordError: String? = nil
    
    @Published var isHidePassword: Bool = true
    
    @Published var otp: String = ""
    @Published var otpEnded: Bool = false
    
    @Published var timerValue: Int = 20
    @Published var usernameError: String? = nil
    
    @Published var isUsernameValid: Bool = false
    @Published var isPasswordValid: Bool = false
    
    // MARK: - Validation
    func validateUsername() {
        let emailPattern = #"^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
        let phonePattern = #"^\d{9}$"#
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailPattern)
        let phonePredicate = NSPredicate(format: "SELF MATCHES %@", phonePattern)

        if username.isEmpty {
            usernameError = "Please enter Email or Phone number."
            isUsernameValid = false
        } else if emailPredicate.evaluate(with: username) || phonePredicate.evaluate(with: username) {
            usernameError = nil
            isUsernameValid = true
        } else {
            usernameError = "Please enter a valid email or phone number."
            isUsernameValid = false
        }
    }
    
    func validatePassword(for type: PasswordType) {
        switch type {
        case .currentPassword:
            currentPasswordError = currentPassword.isEmpty ? "Please enter your current password." : nil
        case .newPassword:
            let pattern = #"^(?=.*[A-Z])(?=.*[a-z])(?=.*\d).{8,}$"#
            let isValid = NSPredicate(format: "SELF MATCHES %@", pattern).evaluate(with: newPassword)
            newPasswordError = newPassword.isEmpty ? "Please enter a new password." : !isValid ? "Password must be 8-20 characters long with upper, lower, and numeric characters." : nil
        case .confirmPassword:
            confirmPasswordError = confirmPassword.isEmpty ? "Please confirm your password." : confirmPassword != newPassword ? "Passwords do not match." : nil
        case .password:
            passwordError = password.isEmpty ? "Please enter your password." : nil
        }
    }
    
    func passwordText(for type: PasswordType) -> String {
        switch type {
        case .confirmPassword: return "Confirm Password"
        case .newPassword: return "New Password"
        case .currentPassword: return "Current Password"
        case .password: return "Password"
        }
    }
    
    func clearTextField() {
        username = ""
        password = ""
        newPassword = ""
        confirmPassword = ""
        currentPassword = ""
        passwordError = ""
        usernameError = ""
    }
    
    func startTimer() {
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            if self.timerValue > 0 {
                self.timerValue -= 1
            } else {
                timer.invalidate()
                self.otpEnded = true
            }
        }
    }
    
    func formatTime(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let seconds = seconds % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}



