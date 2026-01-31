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
    
    // Access user through singleton instead of storing locally
    var currentUser: User? {
        return UserSession.shared.currentUser
    }
    
    private let db = Firestore.firestore()
    
    init() {
        checkUser()
    }

    func checkUser() {
        isLoading = true

        guard let user = Auth.auth().currentUser else {
            isLoading = false
            return
        }

        Task {
            do {
                try await fetchUserData(uid: user.uid)
                isLoading = false
            } catch {
                isLoading = false
                UserSession.shared.clearUser()
                AlertManager.shared.showError(
                    title: "Session Error",
                    message: "Failed to load user data"
                )
            }
        }
    }
    
    func fetchUserData(uid: String) async throws {
        let snapshot = try await db
            .collection("users")
            .document(uid)
            .getDocument()

        guard let data = snapshot.data() else {
            throw NSError(domain: "UserDataError", code: 404)
        }

        let name = data["name"] as? String ?? ""
        let email = data["email"] as? String ?? ""
        let roleString = data["role"] as? String ?? "customer"
        let role = UserRole(rawValue: roleString) ?? .customer

        let phoneNumber = data["phoneNumber"] as? String
        let gender = data["gender"] as? String
        let city = data["city"] as? String

        var dateOfBirth: Date?
        if let dobTimestamp = data["dateOfBirth"] as? Timestamp {
            dateOfBirth = dobTimestamp.dateValue()
        }

        let user = User(
            id: uid,
            name: name,
            email: email,
            role: role,
            phoneNumber: phoneNumber,
            gender: gender,
            dateOfBirth: dateOfBirth,
            city: city
        )

        UserSession.shared.setUser(user)
    }

    func signUp(
        name: String,
        email: String,
        password: String,
        role: UserRole,
        completion: @escaping (Result<User, Error>) -> Void
    ) async {
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            let uid = result.user.uid
            
            let user = User(id: uid, name: name, email: email, role: role)
            
            try await db.collection("users").document(uid).setData([
                "name": name,
                "email": email,
                "role": role.rawValue
            ])
            
            await MainActor.run {
                // Store user in singleton
                UserSession.shared.setUser(user)
            }
            
            completion(.success(user))
            
        } catch {
            completion(.failure(error))
        }
    }
    
    func login(email: String, password: String) async {
        do {
            isLoading = true
            LoaderManager.shared.showLoading()

            let result = try await Auth.auth()
                .signIn(withEmail: email, password: password)

            try await fetchUserData(uid: result.user.uid)
            try await MinimumLoadingTime(2).waitIfNeeded()
            
            LoaderManager.shared.hideLoading()
            isLoading = false

            AlertManager.shared.showSuccess(message: "Logged in successfully")
        } catch {
            LoaderManager.shared.hideLoading()
            isLoading = false

            AlertManager.shared.showError(
                title: "Login Error",
                message: error.localizedDescription
            )
        }
    }

    
    func sendPasswordReset(email: String) async throws {
        try await Auth.auth().sendPasswordReset(withEmail: email)
    }
    
    func logout(onResult: @escaping (Bool) -> Void) {
        do {
            try Auth.auth().signOut()
            // Clear user from singleton
            UserSession.shared.clearUser()
            onResult(true)
        } catch let error as NSError {
            AlertManager.shared.showError(title: "Error signing out", message: error.localizedDescription)
            onResult(false)
        }
    }
    
    func updateProfile(user: User) async -> Bool {
        guard let uid = Auth.auth().currentUser?.uid else {
            return false
        }

        do {
            LoaderManager.shared.showLoading()

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

            try await db
                .collection("users")
                .document(uid)
                .setData(data, merge: true)

            // ✅ Ensure local user is updated
            try await fetchUserData(uid: uid)

            LoaderManager.shared.hideLoading()
            AlertManager.shared.showSuccess(message: "Profile updated successfully")

            return true
        } catch {
            LoaderManager.shared.hideLoading()
            AlertManager.shared.showError(
                title: "Update Failed",
                message: error.localizedDescription
            )
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
