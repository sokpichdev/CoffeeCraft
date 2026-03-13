//
//  FirebaseAuthRepository.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 3/11/26.
//
//  Live Firebase Auth + Firestore implementation of AuthRepositoryProtocol.
//  All Auth.auth() and db.collection("users") calls that previously
//  lived inside AuthViewModel now live here.
//

import FirebaseAuth
import FirebaseFirestore
import Foundation

struct FirebaseAuthRepository: AuthRepositoryProtocol {

    private let db = Firestore.firestore()

    // MARK: - Auth

    func signIn(email: String, password: String) async throws -> String {
        let result = try await Auth.auth().signIn(withEmail: email, password: password)
        return result.user.uid
    }

    func createUser(email: String, password: String) async throws -> String {
        let result = try await Auth.auth().createUser(withEmail: email, password: password)
        return result.user.uid
    }

    func signOut() throws {
        try Auth.auth().signOut()
    }

    func sendPasswordReset(email: String) async throws {
        try await Auth.auth().sendPasswordReset(withEmail: email)
    }

    // MARK: - Firestore — User Document

    func fetchUser(uid: String) async throws -> User {
        let snapshot = try await db.collection("users").document(uid).getDocument()

        guard let data = snapshot.data() else {
            throw NSError(
                domain: "UserDataError",
                code: 404,
                userInfo: [NSLocalizedDescriptionKey: "User data not found for uid: \(uid)"]
            )
        }

        let roleString = data["role"] as? String ?? "customer"

        var dateOfBirth: Date?
        if let ts = data["dateOfBirth"] as? Timestamp {
            dateOfBirth = ts.dateValue()
        }

        return User(
            id: uid,
            name: data["name"] as? String ?? "",
            email: data["email"] as? String ?? "",
            role: UserRole(rawValue: roleString) ?? .customer,
            phoneNumber: data["phoneNumber"] as? String,
            gender: data["gender"] as? String,
            dateOfBirth: dateOfBirth,
            city: data["city"] as? String
        )
    }

    func saveUser(_ user: User, uid: String) async throws {
        try await db.collection("users").document(uid).setData([
            "name":      user.name,
            "email":     user.email,
            "role":      user.role.rawValue,
            "createdAt": FieldValue.serverTimestamp()   // Required by analytics queries
        ])
    }

    func updateUser(_ user: User, uid: String) async throws {
        var data: [String: Any] = [
            "name": user.name,
            "email": user.email
        ]
        if let phone = user.phoneNumber { data["phoneNumber"] = phone }
        if let gender = user.gender { data["gender"] = gender }
        if let dob = user.dateOfBirth { data["dateOfBirth"] = Timestamp(date: dob) }
        if let city = user.city { data["city"] = city }

        try await db.collection("users").document(uid).setData(data, merge: true)
    }
}
