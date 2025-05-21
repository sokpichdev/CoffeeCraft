//
//  BiometricAuthViewModel.swift
//  AuthenticationApp
//
//  Created by Sok Pich on 5/19/25.
//

import Foundation
import LocalAuthentication
import SwiftUI

class BiometricAuthViewModel: ObservableObject {
    @Published var isRegistered = false
    @Published var isAuthenticated = false
    @Published var message: String?
    @Published var biometricType: BiometricType = .none
    
    private let registrationKey = "isBiometricRegistered"
    private let authKey = "authenticatedBiometricUser"
    
    init() {
        self.isRegistered = UserDefaults.standard.bool(forKey: registrationKey)
        self.isAuthenticated = KeychainHelper.shared.read(forKey: authKey) == "true"
        self.biometricType = detectBiometricType()
    }
    
    func registerBiometrics() {
        authenticate(reason: "Register with your biometrics") { success in
            if success {
                UserDefaults.standard.set(true, forKey: self.registrationKey)
                KeychainHelper.shared.save("true", forKey: self.authKey)
                self.isRegistered = true
                self.isAuthenticated = true
                self.message = "Biometric registered and authenticated!"
            } else {
                self.message = "Registration failed."
            }
        }
    }
    
    func verifyBiometrics() {
        authenticate(reason: "Authenticate to continue") { success in
            if success {
                self.isAuthenticated = true
                self.message = "Authentication successful!"
                KeychainHelper.shared.save("true", forKey: self.authKey)
            } else {
                self.message = "Authentication failed."
            }
        }
    }
    
    func resetBiometricRegistration() {
        UserDefaults.standard.removeObject(forKey: registrationKey)
        KeychainHelper.shared.delete(forKey: authKey)
        self.isRegistered = false
        self.isAuthenticated = false
        self.message = "Biometric registration reset."
    }
    
    private func authenticate(reason: String, completion: @escaping (Bool) -> Void) {
        let context = LAContext()
        var error: NSError?

        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            biometricType = detectBiometricType(context: context)
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, _ in
                DispatchQueue.main.async {
                    completion(success)
                }
            }
        } else {
            DispatchQueue.main.async {
                self.message = error?.localizedDescription ?? "Biometric not available"
                self.biometricType = .none
                completion(false)
            }
        }
    }
    
    private func detectBiometricType(context: LAContext = LAContext()) -> BiometricType {
        var error: NSError?
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            switch context.biometryType {
            case .faceID:
                return .faceID
            case .touchID:
                return .touchID
            default:
                return .none
            }
        }
        return .none
    }
}

enum BiometricType: String {
    case none
    case touchID
    case faceID
}
