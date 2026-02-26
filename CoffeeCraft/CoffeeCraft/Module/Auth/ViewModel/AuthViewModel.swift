//
//  AuthViewModel.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 10/20/25.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import FirebaseMessaging

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
    private var fcmTokenObserver: NSObjectProtocol?

    init() {
        checkUser()
        
        // Listen for FCM token updates
        fcmTokenObserver = NotificationCenter.default.addObserver(
            forName: Notification.Name("FCMToken"),
            object: nil,
            queue: .main
        ) { notification in
            if let token = notification.userInfo?["token"] as? String {
                AppLog.auth.debug("🔄 FCM token updated via NotificationCenter: \(token)")
            }
        }
    }
    
    deinit {
        if let observer = fcmTokenObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }

    func checkUser() {
        isLoading = true

        guard let user = Auth.auth().currentUser else {
            AppLog.auth.debug("👤 checkUser — no authenticated user found, skipping fetch")
            isLoading = false
            return
        }

        AppLog.auth.debug("👤 checkUser — existing session found for uid: \(user.uid)")

        Task {
            do {
                try await fetchUserData(uid: user.uid)
                AppLog.auth.debug("✅ checkUser — user data fetched successfully")
                isLoading = false
            } catch {
                AppLog.auth.error("❌ checkUser — failed to fetch user data: \(error.localizedDescription)")
                isLoading = false
                UserSession.shared.clearUser()
                AlertManager.shared.showError(
                    title: "Session Error",
                    message: "Failed to load user data"
                )
            }
        }
    }
    
    func fetchUserData(uid: String, showLoader: Bool = false) async throws {
        AppLog.auth.debug("🔍 fetchUserData — uid: \(uid), showLoader: \(showLoader)")
        
        if showLoader {
            LoaderManager.shared.showLoading()
        }
        
        do {
            let snapshot = try await db
                .collection("users")
                .document(uid)
                .getDocument()

            guard let data = snapshot.data() else {
                AppLog.auth.error("❌ fetchUserData — no data found for uid: \(uid)")
                if showLoader { LoaderManager.shared.hideLoading() }
                throw NSError(domain: "UserDataError", code: 404, userInfo: [NSLocalizedDescriptionKey: "User data not found"])
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
            AppLog.printItem(user, label: "Fetched User", logger: AppLog.auth)

            if showLoader {
                LoaderManager.shared.hideLoading()
                AlertManager.shared.showSuccess(message: "User data loaded successfully")
            }
        } catch {
            AppLog.auth.error("❌ fetchUserData — error: \(error.localizedDescription)")
            if showLoader {
                LoaderManager.shared.hideLoading()
                AlertManager.shared.showError(
                    title: "Failed to Load User Data",
                    message: error.localizedDescription
                )
            }
            throw error
        }
    }

    func signUp(
        name: String,
        email: String,
        password: String,
        role: UserRole,
        completion: @escaping (Result<User, Error>) -> Void
    ) async {
        AppLog.auth.debug("📝 signUp — attempting for email: \(email), role: \(role.rawValue)")
        LoaderManager.shared.showLoading(autoHide: true)
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
                UserSession.shared.setUser(user)
            }
            
            AppLog.auth.debug("✅ signUp — success, uid: \(uid), email: \(email)")
            AppLog.printItem(user, label: "Signed Up User", logger: AppLog.auth)
            
            completion(.success(user))
            LoaderManager.shared.hideLoading()
            ToastManager.shared.show(message: "Signed Up Successfully", type: .success)
        } catch {
            AppLog.auth.error("❌ signUp — failed for email: \(email): \(error.localizedDescription)")
            LoaderManager.shared.hideLoading()
            AlertManager.shared.showError(title: "Sign Up Error", message: error.localizedDescription)
            completion(.failure(error))
        }
    }
    
    func login(email: String, password: String) async -> Bool {
        AppLog.auth.debug("🔐 login — attempting for email: \(email)")
        
        do {
            isLoading = true
            LoaderManager.shared.showLoading()

            let result = try await Auth.auth().signIn(withEmail: email, password: password)

            AppLog.auth.debug("✅ login — Firebase sign-in success, uid: \(result.user.uid)")
            
            handleSuccessfulLogin()
            try await fetchUserData(uid: result.user.uid)
            try await MinimumLoadingTime(2).waitIfNeeded()
            
            LoaderManager.shared.hideLoading()
            isLoading = false

            AppLog.auth.debug("✅ login — fully completed for uid: \(result.user.uid)")
            AlertManager.shared.showSuccess(message: "Logged in successfully")
            return true
        } catch {
            AppLog.auth.error("❌ login — failed for email: \(email): \(error.localizedDescription)")
            LoaderManager.shared.hideLoading()
            isLoading = false
            AlertManager.shared.showError(
                title: "Login Error",
                message: error.localizedDescription
            )
            return false
        }
    }

    func handleSuccessfulLogin() {
        AppLog.auth.debug("🔑 handleSuccessfulLogin — requesting FCM token")
        
        Messaging.messaging().token { token, error in
            if let error = error {
                AppLog.auth.error("❌ handleSuccessfulLogin — FCM token fetch failed: \(error.localizedDescription)")
            } else if let token = token {
                AppLog.auth.debug("🔑 handleSuccessfulLogin — FCM token retrieved: \(token)")
                FCMTokenService.shared.saveFCMToken(token)
            }
        }
    }
    
    func sendPasswordReset(email: String) async throws {
        AppLog.auth.debug("📧 sendPasswordReset — sending to: \(email)")
        do {
            try await Auth.auth().sendPasswordReset(withEmail: email)
            AppLog.auth.debug("✅ sendPasswordReset — email sent to: \(email)")
        } catch {
            AppLog.auth.error("❌ sendPasswordReset — failed for \(email): \(error.localizedDescription)")
            throw error
        }
    }
    
    func logout(onResult: @escaping (Bool) -> Void) {
        AppLog.auth.debug("🚪 logout — attempting sign out")

        Task {
            // ✅ AWAIT token removal BEFORE signing out.
            // removeFCMToken() is async — if we don't await it,
            // Auth.signOut() fires first and the Firestore write
            // never completes, leaving the old token in the
            // previous user's document.
            await FCMTokenService.shared.removeFCMToken()

            do {
                try Auth.auth().signOut()
                UserSession.shared.clearUser()
                AppLog.auth.debug("✅ logout — token removed, sign out successful")
                onResult(true)
            } catch let error as NSError {
                AppLog.auth.error("❌ logout — sign out failed: \(error.localizedDescription)")
                AlertManager.shared.showError(title: "Error signing out", message: error.localizedDescription)
                onResult(false)
            }
        }
    }
    
    func updateProfile(user: User) async -> Bool {
        guard let uid = Auth.auth().currentUser?.uid else {
            AppLog.auth.error("❌ updateProfile — no authenticated user found")
            return false
        }

        AppLog.auth.debug("✏️ updateProfile — updating uid: \(uid)")
        AppLog.printItem(user, label: "Profile Update Payload", logger: AppLog.auth)

        do {
            LoaderManager.shared.showLoading()

            var data: [String: Any] = [
                "name": user.name,
                "email": user.email
            ]

            if let phone = user.phoneNumber { data["phoneNumber"] = phone }
            if let gender = user.gender { data["gender"] = gender }
            if let dob = user.dateOfBirth { data["dateOfBirth"] = Timestamp(date: dob) }
            if let city = user.city { data["city"] = city }

            try await db
                .collection("users")
                .document(uid)
                .setData(data, merge: true)

            try await fetchUserData(uid: uid)

            LoaderManager.shared.hideLoading()
            AppLog.auth.debug("✅ updateProfile — profile updated successfully for uid: \(uid)")
            return true
        } catch {
            AppLog.auth.error("❌ updateProfile — failed for uid: \(uid): \(error.localizedDescription)")
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

    func validateStrictPassword() {
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
