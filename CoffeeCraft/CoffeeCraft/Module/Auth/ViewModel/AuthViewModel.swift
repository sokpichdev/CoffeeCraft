//
//  AuthViewModel.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 10/20/25.
//
//  Sprint 2: Firestore + Auth.auth() removed — all data access goes through
//  AuthRepositoryProtocol. FCM token handling and UserSession management
//  stay here as they are not repository concerns.
//  Performance trace added on login() (auth_login).
//

import FirebaseAuth
import FirebaseCrashlytics
import FirebaseFirestore
import FirebaseMessaging
import SwiftUI

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

    var currentUser: User? { UserSession.shared.currentUser }

    private let authRepo: AuthRepositoryProtocol
    private var fcmTokenObserver: NSObjectProtocol?

    init(authRepo: AuthRepositoryProtocol = FirebaseAuthRepository()) {
        self.authRepo = authRepo
        checkUser()

        fcmTokenObserver = NotificationCenter.default.addObserver(
            forName: Notification.Name("FCMToken"),
            object: nil,
            queue: .main
        ) { notification in
            if let token = notification.userInfo?["token"] as? String {
                AppLog.auth.debug("🔄 FCM token updated: \(token)")
            }
        }
    }

    deinit {
        if let observer = fcmTokenObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }

    // MARK: - Session Restore

    func checkUser() {
        guard UserSession.shared.currentUser == nil else {
            AppLog.auth.debug("👤 checkUser — session already active, skipping")
            return
        }
        isLoading = true
        // FirebaseAuth.Auth.auth().currentUser is a fast local check — no Firestore call
        guard let uid = FirebaseAuth.Auth.auth().currentUser?.uid else {
            AppLog.auth.debug("👤 checkUser — no session, skipping")
            isLoading = false
            return
        }
        AppLog.auth.debug("👤 checkUser — restoring session for uid: \(uid)")
        Task {
            do {
                try await fetchUserData(uid: uid)
                isLoading = false
            } catch {
                isLoading = false
                UserSession.shared.clearUser()
                AlertManager.shared.showError(title: "Session Error", message: "Failed to load user data")
            }
        }
    }

    // MARK: - Fetch User (shared between restore + login)

    func fetchUserData(uid: String, showLoader: Bool = false) async throws {
        AppLog.auth.debug("🔍 fetchUserData — uid: \(uid)")
        if showLoader { LoaderManager.shared.showLoading() }

        do {
            let user = try await authRepo.fetchUser(uid: uid)
            UserSession.shared.setUser(user)
//            AppLog.printItem(user, label: "Fetched User", logger: AppLog.auth)
            if showLoader { LoaderManager.shared.hideLoading() }
        } catch {
            AppLog.auth.error("❌ fetchUserData error: \(error.localizedDescription)")
            if showLoader {
                LoaderManager.shared.hideLoading()
                AlertManager.shared.showError(title: "Failed to Load User Data", message: error.localizedDescription)
            }
            throw error
        }
    }

    // MARK: - Sign Up

    func signUp(
        name: String,
        email: String,
        password: String,
        role: UserRole,
        completion: @escaping (Result<User, Error>) -> Void
    ) async {
        AppLog.auth.debug("📝 signUp — email: \(email)")
        LoaderManager.shared.showLoading(autoHide: true)

        do {
            let uid  = try await authRepo.createUser(email: email, password: password)
            let user = User(id: uid, name: name, email: email, role: role)
            try await authRepo.saveUser(user, uid: uid)

            UserSession.shared.setUser(user)
            AnalyticsService.shared.log(.signup)

            AppLog.auth.debug("✅ signUp — uid: \(uid)")
            completion(.success(user))
            LoaderManager.shared.hideLoading()
            ToastManager.shared.show(message: "Signed Up Successfully", type: .success)
        } catch {
            Crashlytics.crashlytics().record(error: error)
            AppLog.auth.error("❌ signUp failed: \(error.localizedDescription)")
            LoaderManager.shared.hideLoading()
            AlertManager.shared.showError(title: "Sign Up Error", message: error.localizedDescription)
            completion(.failure(error))
        }
    }

    // MARK: - Login

    func login(email: String, password: String) async -> Bool {
        AppLog.auth.debug("🔐 login — email: \(email)")
        isLoading = true
        LoaderManager.shared.showLoading()

        do {
            let uid = try await PerformanceService.shared.trace(.authLogin) {
                try await authRepo.signIn(email: email, password: password)
            }
            AppLog.auth.debug("✅ Firebase sign-in success, uid: \(uid)")
            handleSuccessfulLogin()
            try await fetchUserData(uid: uid)
            try await MinimumLoadingTime(2).waitIfNeeded()

            LoaderManager.shared.hideLoading()
            isLoading = false
            AnalyticsService.shared.log(.login(method: "email"))
            AlertManager.shared.showSuccess(message: "Logged in successfully")
            return true
        } catch {
            Crashlytics.crashlytics().record(error: error)
            AppLog.auth.error("❌ login failed: \(error.localizedDescription)")
            LoaderManager.shared.hideLoading()
            isLoading = false
            AlertManager.shared.showError(title: "Login Error", message: error.localizedDescription)
            return false
        }
    }

    func handleSuccessfulLogin() {
        Messaging.messaging().token { token, error in
            if let error {
                AppLog.auth.error("❌ FCM token fetch failed: \(error.localizedDescription)")
            } else if let token {
                FCMTokenService.shared.saveFCMToken(token)
            }
        }
    }

    // MARK: - Password Reset

    func sendPasswordReset(email: String) async throws {
        AppLog.auth.debug("📧 sendPasswordReset — \(email)")
        do {
            try await authRepo.sendPasswordReset(email: email)
            AppLog.auth.debug("✅ Password reset email sent to: \(email)")
        } catch {
            AppLog.auth.error("❌ sendPasswordReset failed: \(error.localizedDescription)")
            throw error
        }
    }

    // MARK: - Logout

    func logout(onResult: @escaping (Bool) -> Void) {
        AppLog.auth.debug("🚪 logout — attempting sign out")
        Task {
            await FCMTokenService.shared.removeFCMToken()
            do {
                try authRepo.signOut()
                UserSession.shared.clearUser()
                AnalyticsService.shared.log(.logout)
                AppLog.auth.debug("✅ logout — successful")
                onResult(true)
            } catch {
                Crashlytics.crashlytics().record(error: error)
                AppLog.auth.error("❌ logout failed: \(error.localizedDescription)")
                AlertManager.shared.showError(title: "Error signing out", message: error.localizedDescription)
                onResult(false)
            }
        }
    }

    // MARK: - Update Profile

    func updateProfile(user: User) async -> Bool {
        guard let uid = FirebaseAuth.Auth.auth().currentUser?.uid else {
            AppLog.auth.error("❌ updateProfile — no authenticated user")
            return false
        }
        AppLog.auth.debug("✏️ updateProfile — uid: \(uid)")
        do {
            LoaderManager.shared.showLoading()
            try await authRepo.updateUser(user, uid: uid)
            try await fetchUserData(uid: uid)
            LoaderManager.shared.hideLoading()
            AppLog.auth.debug("✅ updateProfile — success")
            return true
        } catch {
            Crashlytics.crashlytics().record(error: error)
            AppLog.auth.error("❌ updateProfile failed: \(error.localizedDescription)")
            LoaderManager.shared.hideLoading()
            AlertManager.shared.showError(title: "Update Failed", message: error.localizedDescription)
            return false
        }
    }
}

// MARK: - Form Validation (unchanged)

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
            passwordValidation = .init(isValid: false,
                                       message: "Password must contain at least one special character (!@#$%^&*)")
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
        if name.isEmpty {
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
        return nameValidation.isValid && emailValidation.isValid && passwordValidation.isValid
    }

    func resetForm(isResetEmail: Bool = false) {
        if isResetEmail { email = "" }
        password = ""
        name = ""
        role = .customer
        emailValidation = .init()
        passwordValidation = .init()
        nameValidation = .init()
    }
}
