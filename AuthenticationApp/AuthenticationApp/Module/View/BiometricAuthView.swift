//
//  BiometricAuthView.swift
//  AuthenticationApp
//
//  Created by Sok Pich on 5/19/25.
//

import SwiftUI

struct BiometricAuthView: View {
    @StateObject private var viewModel = BiometricAuthViewModel()

    var body: some View {
        VStack(spacing: 20) {
            Text("Biometric Type: \(viewModel.biometricType.rawValue.capitalized)")
                .font(.headline)

            Text(viewModel.isRegistered ? "🔐 Registered" : "🔓 Not Registered")
                .font(.title)

            if !viewModel.isRegistered {
                Button("Register") {
                    viewModel.registerBiometrics()
                }
                .buttonStyle(.borderedProminent)
            } else if !viewModel.isAuthenticated {
                Button("Authenticate") {
                    viewModel.verifyBiometrics()
                }
                .buttonStyle(.bordered)
            }

            if viewModel.isAuthenticated {
                Text("✅ Authenticated")
                    .foregroundColor(.green)

                Button("Logout") {
                    viewModel.resetBiometricRegistration()
                }
                .foregroundColor(.red)
            }

            if let message = viewModel.message {
                Text(message)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding()
            }
        }
        .padding()
    }
}
