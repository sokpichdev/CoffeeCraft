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
    @Published var currentUser: User?
    @Published var isLoading = true
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

    func logout() {
        try? Auth.auth().signOut()
        currentUser = nil
    }
}
