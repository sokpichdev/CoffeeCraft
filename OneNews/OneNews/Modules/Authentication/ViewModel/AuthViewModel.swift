//
//  AuthViewModel.swift
//  OneNews
//
//  Created by Sok Pich on 12/25/24.
//

import SwiftUI
import Combine
import FirebaseAuth
import FirebaseCore
import FirebaseFirestore

class AuthViewModel: ObservableObject {
    @Published var isUserLoggedIn: Bool = false

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
    
    @Published var otp: String = "123456"
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
        let mainPassword: String
        
        if newPassword == "" {
            mainPassword = password
        } else if password == "" {
            mainPassword = newPassword
        } else {
            mainPassword = ""
        }
        switch type {
        case .currentPassword:
            currentPasswordError = currentPassword.isEmpty ? "Please enter your current password." : nil
            
        case .newPassword:
            if newPassword.isEmpty {
                newPasswordError = "Please enter a new password."
            } else if !newPassword.isValidPassword {
                newPasswordError = "Password must be 8-20 characters long with upper, lower, and numeric characters."
            } else {
                newPasswordError = nil
            }
            
        case .confirmPassword:
            if confirmPassword.isEmpty {
                confirmPasswordError = "Please confirm your password."
            } else if confirmPassword != mainPassword {
                confirmPasswordError = "Passwords do not match."
            } else {
                confirmPasswordError = nil
            }
            
        case .password:
            if password.isEmpty {
                passwordError = "Please enter a password."
            } else if !password.isValidPassword {
                passwordError = "Password must be 8-20 characters long with upper, lower, and numeric characters."
            } else {
                passwordError = nil
            }
        }
    }
    
    func validateOTP() -> Bool {
        return otp == "123456"
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
    
    // MARK: - REGISTER
    func registerUser() {
        guard !username.isEmpty, !password.isEmpty else {
            self.usernameError = "Please enter a valid email or phone number."
            self.passwordError = "Please enter a password."
            return
        }
        
        // Perform validation
        validateUsername()
        validatePassword(for: .password)
        
        guard isUsernameValid, passwordError == nil else { return }
        
        Auth.auth().createUser(withEmail: username, password: password) { authResult, error in
            if let error = error {
                print("Registration failed: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.usernameError = error.localizedDescription
                }
                return
            }
            
            guard let user = authResult?.user else { return }
            print("User registered successfully: \(user.uid)")
            
            DispatchQueue.main.async {
                self.isUserLoggedIn = true
            }
            
            // Optional: Save additional user info to Firestore
//            self.saveUserDataToFirestore(userID: user.uid)
            
            // Clear fields after registration
            DispatchQueue.main.async {
                self.clearTextField()
            }
        }
    }

    private func saveUserDataToFirestore(userID: String) {
        let db = Firestore.firestore()
        let userData: [String: Any] = [
            "email": username,
            "uid": userID,
            "createdAt": Timestamp(date: Date())
        ]
        
        db.collection("users").document(userID).setData(userData) { error in
            if let error = error {
                print("Failed to save user data: \(error.localizedDescription)")
            } else {
                print("User data saved successfully.")
            }
        }
    }


    // MARK: - LOGIN
    func loginUser(email: String, password: String) {
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let error = error {
                print("Login failed: \(error.localizedDescription)")
                return
            }
            print("User logged in successfully!")
        }
    }
    
    // MARK: - FORGOT PASSWORD
    func sendPasswordReset(email: String) {
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            if let error = error {
                print("Password reset failed: \(error.localizedDescription)")
                return
            }
            print("Password reset email sent!")
        }
    }
    
    // MARK: - CHANGE PASSWORD
    func changePassword(newPassword: String) {
        Auth.auth().currentUser?.updatePassword(to: newPassword) { error in
            if let error = error {
                print("Password change failed: \(error.localizedDescription)")
                return
            }
            print("Password changed successfully!")
        }
    }
    
    // MARK: - LOGOUT
    func logoutUser() {
        do {
            try Auth.auth().signOut()
            print("User logged out successfully!")
        } catch let error {
            print("Logout failed: \(error.localizedDescription)")
        }
    }
    // MARK: - AUTHENTICATION STATES
    func observeAuthState() {
        Auth.auth().addStateDidChangeListener { auth, user in
            DispatchQueue.main.async {
                self.isUserLoggedIn = user != nil
                if let user = user {
                    print("User is logged in: \(user.email ?? "No Email")")
                } else {
                    print("User is logged out")
                }
            }
        }
    }
}



