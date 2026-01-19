//
//  AuthViewModel.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 10/20/25.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

@MainActor
class AuthViewModel: ObservableObject {
    // MARK: - Form Fields
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var name: String = ""
    @Published var role: UserRole = .customer
    
    // MARK: - Validation State
    @Published var emailValidation = FieldValidation()
    @Published var passwordValidation = FieldValidation()
    @Published var nameValidation = FieldValidation()
    
    // MARK: - UI State
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var currentUser: User?
    
    private let db = Firestore.firestore()
    
    init() {
        checkUser()
    }

    func checkUser() {
        if let user = Auth.auth().currentUser {
            fetchUserData(uid: user.uid)
        } else {
            isLoading = false
        }
    }

    func fetchUserData(uid: String) {
        db.collection("users").document(uid).getDocument { snapshot, error in
            DispatchQueue.main.async {
                guard let data = snapshot?.data() else {
                    self.isLoading = false
                    return
                }
                
                let name = data["name"] as? String ?? ""
                let email = data["email"] as? String ?? ""
                let roleString = data["role"] as? String ?? "customer"
                let role = UserRole(rawValue: roleString) ?? .customer
                
                let phoneNumber = data["phoneNumber"] as? String
                let gender = data["gender"] as? String
                let city = data["city"] as? String
                
                // Convert Firestore Timestamp to Swift Date
                var dateOfBirth: Date? = nil
                if let dobTimestamp = data["dateOfBirth"] as? Timestamp {
                    dateOfBirth = dobTimestamp.dateValue()
                }
                
                self.currentUser = User(
                    id: uid,
                    name: name,
                    email: email,
                    role: role,
                    phoneNumber: phoneNumber,
                    gender: gender,
                    dateOfBirth: dateOfBirth,
                    city: city
                )
                
                self.isLoading = false
            }
        }
    }

    func signUp(name: String, email: String, password: String, role: UserRole) async throws {
        let result = try await Auth.auth().createUser(withEmail: email, password: password)
        let uid = result.user.uid
        let user = User(id: uid, name: name, email: email, role: role)

        try await db.collection("users").document(uid).setData([
            "name": name,
            "email": email,
            "role": role.rawValue
        ])

        DispatchQueue.main.async {
            self.currentUser = user
        }
    }

    func login(email: String, password: String) async throws {
        let result = try await Auth.auth().signIn(withEmail: email, password: password)
        fetchUserData(uid: result.user.uid)
    }
    func sendPasswordReset(email: String) async throws {
        try await Auth.auth().sendPasswordReset(withEmail: email)
    }
    
    func logout(onResult: @escaping (Bool) -> Void) {
        do {
            try Auth.auth().signOut()
            self.currentUser = nil
            onResult(true)
        } catch let error as NSError {
            print("Error signing out: \(error.localizedDescription)")
            onResult(false)
        }
    }
    
    func updateProfile(user: User) async -> Bool {
        guard let uid = Auth.auth().currentUser?.uid else { return false }

        var data: [String: Any] = [
            "name": user.name,
            "email": user.email
        ]

        if let phone = user.phoneNumber { data["phoneNumber"] = phone }
        if let gender = user.gender { data["gender"] = gender }
        if let dob = user.dateOfBirth {
            data["dateOfBirth"] = Timestamp(date: dob)
        }
        if let city = user.city { data["city"] = city }

        do {
            try await db.collection("users")
                .document(uid)
                .setData(data, merge: true)

            // Refresh current user
            fetchUserData(uid: uid)
            return true
        } catch {
            print("Update profile failed:", error.localizedDescription)
            return false
        }
    }
}

extension AuthViewModel {

    func validateEmail() {
        if email.isEmpty {
            emailValidation = .init(isValid: false, message: "Email is required")
        } else if !email.isValidEmail() {
            emailValidation = .init(isValid: false, message: "Invalid email format")
        } else {
            emailValidation = .init()
        }
    }

    func validateStrictPassword() { // strict validation
        if password.isEmpty {
            passwordValidation = .init(isValid: false, message: "Password is required")
        } else if password.count < 8 {
            passwordValidation = .init(isValid: false, message: "Password must be at least 8 characters")
        } else if password.count > 20 {
            passwordValidation = .init(isValid: false, message: "Password must be less than 20 characters")
        } else if !password.containsUppercase() {
            passwordValidation = .init(isValid: false, message: "Password must contain at least one uppercase letter")
        } else if !password.containsLowercase() {
            passwordValidation = .init(isValid: false, message: "Password must contain at least one lowercase letter")
        } else if !password.containsNumber() {
            passwordValidation = .init(isValid: false, message: "Password must contain at least one number")
        } else if !password.containsSpecialCharacter() {
            passwordValidation = .init(isValid: false, message: "Password must contain at least one special character (!@#$%^&*)")
        } else if password.contains(" ") {
            passwordValidation = .init(isValid: false, message: "Password cannot contain spaces")
        } else {
            passwordValidation = .init()
        }
    }
    
    func validatePassword() {
        if password.isEmpty {
            passwordValidation = .init(isValid: false, message: "Password is required")
        } else if password.contains(" ") {
            passwordValidation = .init(isValid: false, message: "Password cannot contain spaces")
        } else if password.count < 8 {
            passwordValidation = .init(isValid: false, message: "Password must be at least 8 characters")
        } else if !password.containsLetterAndNumber() {
            passwordValidation = .init(isValid: false, message: "Password must contain both letters and numbers")
        } else {
            passwordValidation = .init()
        }
    }
    
    func checkUsername() {
        if name.count == 0 {
            nameValidation = .init(isValid: false, message: "Name cannot be empty")
        } else if name.count < 6 || name.count > 15 {
            nameValidation = .init(isValid: false, message: "Name must be between 6 - 15 letters")
        } else if name.isContainsLettersAndNumbers() {
            nameValidation = .init(isValid: false, message: "Name cannot contain numbers")
        } else if !name.checkSpaceAndSpecialChars() {
            nameValidation = .init(isValid: false, message: "Name cannot contain special characters")
        } else {
            nameValidation = .init()
        }
    }

    func validateLoginForm() -> Bool {
        validateEmail()
        validatePassword()
        return emailValidation.isValid && passwordValidation.isValid
    }

    func validateRegisterForm() -> Bool {
        checkUsername()
        validateEmail()
        validatePassword()
        return nameValidation.isValid &&
               emailValidation.isValid &&
               passwordValidation.isValid
    }
    
    func resetForm(isResetEmail: Bool = false) {
        if isResetEmail {
            email = ""
        }
        password = ""
        name = ""
        role = .customer
        emailValidation = .init()
        passwordValidation = .init()
        nameValidation = .init()
    }

}

