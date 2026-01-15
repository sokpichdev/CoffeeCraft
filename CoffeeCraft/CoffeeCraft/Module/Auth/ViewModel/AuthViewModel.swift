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
                if let data = snapshot?.data(),
                   let name = data["name"] as? String,
                   let email = data["email"] as? String,
                   let roleString = data["role"] as? String,
                   let role = UserRole(rawValue: roleString) {
                    self.currentUser = User(id: uid, name: name, email: email, role: role)
                }
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
    
    func logout() {
        try? Auth.auth().signOut()
        currentUser = nil
    }
}

extension AuthViewModel {

    func validateEmail() {
        if email.isEmpty {
            emailValidation = .init(isValid: false, message: "Email is required")
        } else if !email.contains("@") {
            emailValidation = .init(isValid: false, message: "Invalid email format")
        } else {
            emailValidation = .init()
        }
    }

    func validatePassword() {
        if password.count < 6 {
            passwordValidation = .init(
                isValid: false,
                message: "Password must be at least 6 characters"
            )
        } else {
            passwordValidation = .init()
        }
    }
    
    func checkUsername() {
        if name.count == 0 {
            nameValidation.isValid = false
            nameValidation.message = "Name cannot be empty"
        } else if name.count < 6 || name.count > 15 {
            nameValidation.isValid = false
            nameValidation.message = "Name must be between 6 - 15 letters"
        } else if name.isContainsLettersAndNumbers() {
            nameValidation.isValid = false
            nameValidation.message = "Name cannot contain numbers"
        } else if !name.checkSpaceAndSpecialChars() {
            nameValidation.isValid = false
            nameValidation.message = "Name cannot contain special characters"
        } else {
            nameValidation.isValid = true
            nameValidation.message = ""
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
    
    func resetForm() {
        email = ""
        password = ""
        name = ""
        role = .customer
        emailValidation = .init()
        passwordValidation = .init()
        nameValidation = .init()
    }

}

