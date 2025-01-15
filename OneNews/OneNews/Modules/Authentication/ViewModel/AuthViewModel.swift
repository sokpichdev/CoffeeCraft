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
    @Published var confirmpassword: String = ""
    @Published var isHidePassword: Bool = true
    @Published var otp: String = ""
    @Published var otpEnded: Bool = false
    @Published var timerValue: Int = 20
    @Published var validationError: String? = nil
    @Published var usernameError: String? = nil
    @Published var passwordError: String? = nil
    
    @Published var isUsernameValid: Bool = false
    @Published var isPasswordValid: Bool = false
    
    
    func validateInputs() -> Bool {
        return isUsernameValid && isPasswordValid
    }
    
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
    
    func validatePassword() {
        let passwordPattern = #"^(?=.*[A-Z])(?=.*[a-z])(?=.*\d).{8,}$"#
        let passwordPredicate = NSPredicate(format: "SELF MATCHES %@", passwordPattern)
        
        if passwordPredicate.evaluate(with: password) {
            passwordError = nil
            isPasswordValid = true
        } else if password.isEmpty {
            passwordError = "Please enter Password"
            isPasswordValid = false
        } else {
            passwordError =  "Password must be 6-24 characters long and include both letters and numbers."
            isPasswordValid = false
        }
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


enum PasswordType {
    case password
    case confirmPassword
    case newPassword
}
enum ButtonType {
    case login
    case register
    case confirm
}

