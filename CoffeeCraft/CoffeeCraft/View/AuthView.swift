//
//  AuthView.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 10/20/25.
//
import SwiftUI

struct AuthView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @State private var email = ""
    @State private var password = ""
    @State private var name = ""
    @State private var role: UserRole = .customer
    @State private var isLogin = true

    var body: some View {
        VStack(spacing: 16) {
            Text(isLogin ? "Login" : "Sign Up")
                .font(.largeTitle).bold()

            if !isLogin {
                TextField("Name", text: $name)
            }

            TextField("Email", text: $email)
                .textInputAutocapitalization(.never)
                .keyboardType(.emailAddress)
            SecureField("Password", text: $password)

            if !isLogin {
                Picker("Role", selection: $role) {
                    Text("Customer").tag(UserRole.customer)
                    Text("Manager").tag(UserRole.manager)
                }
                .pickerStyle(SegmentedPickerStyle())
            }

            Button(isLogin ? "Login" : "Sign Up") {
                Task {
                    do {
                        if isLogin {
                            try await authVM.login(email: email, password: password)
                        } else {
                            try await authVM.signUp(name: name, email: email, password: password, role: role)
                        }
                    } catch {
                        print("Error: \(error.localizedDescription)")
                    }
                }
            }

            Button(isLogin ? "Create account" : "Already have an account? Login") {
                isLogin.toggle()
            }
        }
        .padding()
    }
}
