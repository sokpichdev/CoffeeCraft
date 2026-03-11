//
//  UserSession.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 1/28/26.
//

import Combine
import FirebaseCrashlytics
import Foundation

class UserSession: ObservableObject {
    // MARK: - Singleton Instance
    static let shared = UserSession()
    
    // MARK: - Published Properties
    @Published var currentUser: User?
    @Published var isLoggedIn: Bool = false
    
    // MARK: - Private Initializer
    private init() {
        // Private initializer to ensure singleton pattern
    }
    
    // MARK: - User Management Methods
    
    /// Set the current user and update login status
    func setUser(_ user: User) {
        self.currentUser = user
        self.isLoggedIn = true

        // Crashlytics — user id + role key appear on every crash report
        Crashlytics.crashlytics().setUserID(user.id)
        Crashlytics.crashlytics().setCustomValue(user.role.rawValue, forKey: "user_role")

        // Analytics — id + role property attached to all subsequent events
        AnalyticsService.shared.setUser(id: user.id, role: user.role.rawValue)

        AppLog.auth.debug("👤 UserSession.setUser — identity set for uid: \(user.id)")
    }
    
    /// Clear the current user and update login status
    func clearUser() {
        self.currentUser = nil
        self.isLoggedIn = false

        Crashlytics.crashlytics().setUserID("")
        AnalyticsService.shared.clearUser()

        AppLog.auth.debug("👤 UserSession.clearUser — Crashlytics + Analytics identity cleared")
    }
    
    /// Update user information
    func updateUser(_ user: User) {
        self.currentUser = user
    }
    
    // MARK: - Computed Properties for Easy Access
    
    var userId: String? {
        return currentUser?.id
    }
    
    var userName: String? {
        return currentUser?.name
    }
    
    var userEmail: String? {
        return currentUser?.email
    }
    
    var userRole: UserRole? {
        return currentUser?.role
    }
    
    var isCustomer: Bool {
        return currentUser?.role == .customer
    }
    
    var isManager: Bool {
        return currentUser?.role == .manager
    }
    
    // MARK: - Optional User Details
    
    var phoneNumber: String? {
        return currentUser?.phoneNumber
    }
    
    var gender: String? {
        return currentUser?.gender
    }
    
    var dateOfBirth: Date? {
        return currentUser?.dateOfBirth
    }
    
    var city: String? {
        return currentUser?.city
    }
}
