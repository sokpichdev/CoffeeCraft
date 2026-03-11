//
//  AuthRepositoryProtocol.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 3/11/26.
//
//  Defines all Firebase Auth + Firestore user operations that
//  AuthViewModel depends on. FCM token handling and session state
//  management stay in the ViewModel — they are not Firestore concerns.
//

protocol AuthRepositoryProtocol {

    /// Signs in with email + password. Returns the authenticated user's UID.
    func signIn(email: String, password: String) async throws -> String

    /// Creates a new Firebase Auth account. Returns the new user's UID.
    func createUser(email: String, password: String) async throws -> String

    /// Signs out of Firebase Auth. Throws on failure.
    func signOut() throws

    /// Fetches a User model from the Firestore `users` collection.
    /// Throws if the document does not exist.
    func fetchUser(uid: String) async throws -> User

    /// Writes a new user document to Firestore (used during sign-up).
    func saveUser(_ user: User, uid: String) async throws

    /// Merges updated profile fields into the existing user document.
    func updateUser(_ user: User, uid: String) async throws

    /// Triggers a Firebase password-reset email.
    func sendPasswordReset(email: String) async throws
}
