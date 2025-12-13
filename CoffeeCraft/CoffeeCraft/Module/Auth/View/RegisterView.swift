//
//  RegisterView.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 12/13/25.
//
import SwiftUI

struct RegisterView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @Binding var name: String
    @Binding var email: String
    @Binding var password: String
    @Binding var role: UserRole
    @State private var isLoading = false
    @FocusState private var focusedField: Field?

    enum Field {
        case name, email, password
    }

    var body: some View {
        VStack(spacing: 16) {
            MaterialTextField(
                text: $name,
                placeholder: "Full Name")
            
            MaterialTextField(
                text: $email,
                placeholder: "Email Address",
                keyboardType: .emailAddress,
                fieldtype: .email
            )

            MaterialTextField(
                text: $password,
                placeholder: "Password",
                fieldtype: .password
            )

            Picker("Role", selection: $role) {
                Text("Customer").tag(UserRole.customer)
                Text("Manager").tag(UserRole.manager)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.top, 6)

            Button {
                Task {
                    isLoading = true
                    do {
                        try await authVM.signUp(name: name, email: email, password: password, role: role)
                    } catch {
                        print("Sign Up Error: \(error.localizedDescription)")
                    }
                    isLoading = false
                }
            } label: {
                HStack {
                    if isLoading {
                        ProgressView().tint(.white)
                    } else {
                        Text("Sign Up").fontWeight(.semibold)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.brown.gradient)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .shadow(color: .brown.opacity(0.4), radius: 6, y: 4)
            }
            .disabled(isLoading || name.isEmpty || email.isEmpty || password.isEmpty)
        }
        .padding(24)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: .black.opacity(0.25), radius: 10, x: 0, y: 8)
    }
}
