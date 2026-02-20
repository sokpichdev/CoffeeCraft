//
//  FCMTokenService.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 10/22/25.
//
import Foundation
import FirebaseFirestore
import FirebaseAuth
import UIKit

class FCMTokenService {
    static let shared = FCMTokenService()
    private let db = Firestore.firestore()
    
    private init() {}
    
    /// Get unique device identifier
    private var deviceId: String {
        UIDevice.current.identifierForVendor?.uuidString ?? "unknown-device"
    }
    
    /// Save FCM token to Firestore as part of a tokens array
    func saveFCMToken(_ token: String) {
        guard let userId = Auth.auth().currentUser?.uid else {
            AppLog.auth.warning("⚠️ No user logged in — cannot save FCM token")
            return
        }
        
        let userRef = db.collection("users").document(userId)
        
        // First, get the current tokens array
        userRef.getDocument { [weak self] snapshot, error in
            guard let self = self else { return }
            
            if let error = error {
                AppLog.firestore.error("❌ Error fetching user doc: \(error.localizedDescription)")
                return
            }
            
            var tokensArray: [[String: Any]] = []
            
            // Get existing tokens if they exist
            if let data = snapshot?.data(),
               let existingTokens = data["fcmTokens"] as? [[String: Any]] {
                tokensArray = existingTokens
            }
            
            // Check if this device already has a token entry
            let deviceId = self.deviceId
            if let existingIndex = tokensArray.firstIndex(where: { dict in
                dict["deviceId"] as? String == deviceId
            }) {
                // Update existing token for this device
                tokensArray[existingIndex] = [
                    "token": token,
                    "deviceId": deviceId,
                    "platform": "ios",
                    "updatedAt": Timestamp(date: Date())
                ]
                AppLog.firestore.info("🔄 Updating FCM token for device: \(deviceId)")
            } else {
                // Add new token for this device
                tokensArray.append([
                    "token": token,
                    "deviceId": deviceId,
                    "platform": "ios",
                    "updatedAt": Timestamp(date: Date())
                ])
                AppLog.firestore.info("➕ Adding new FCM token for device: \(deviceId)")
            }
            
            // Save the updated array
            userRef.setData([
                "fcmTokens": tokensArray,
                "updatedAt": FieldValue.serverTimestamp()
            ], merge: true) { error in
                if let error = error {
                    AppLog.firestore.error("❌ Error saving FCM token: \(error.localizedDescription)")
                } else {
                    AppLog.firestore.info("✅ FCM token saved for user: \(userId) | devices: \(tokensArray.count)")
                }
            }
        }
    }
    
    /// Remove FCM token for current device from the tokens array
    func removeFCMToken() {
        guard let userId = Auth.auth().currentUser?.uid else {
            AppLog.firestore.error("⚠️ No user logged in, cannot remove FCM token")
            return
        }
        
        let userRef = db.collection("users").document(userId)
        let deviceId = self.deviceId
        
        userRef.getDocument { snapshot, error in
            if let error = error {
                AppLog.firestore.error("❌ Error fetching user doc: \(error.localizedDescription)")
                return
            }
            
            guard let data = snapshot?.data(),
                  var tokensArray = data["fcmTokens"] as? [[String: Any]] else {
                AppLog.auth.warning("⚠️ No tokens found for user")
                return
            }
            
            // Remove token for this device
            tokensArray.removeAll { dict in
                dict["deviceId"] as? String == deviceId
            }
            
            // Update Firestore
            if tokensArray.isEmpty {
                // If no tokens left, remove the field entirely
                userRef.updateData([
                    "fcmTokens": FieldValue.delete(),
                    "updatedAt": FieldValue.serverTimestamp()
                ]) { error in
                    if let error = error {
                        AppLog.firestore.error("❌ Error removing FCM tokens field: \(error.localizedDescription)")
                    } else {
                        AppLog.firestore.info("🗑 Removed FCM token for device: \(deviceId)")
                    }
                }
            } else {
                // Update with remaining tokens
                userRef.updateData([
                    "fcmTokens": tokensArray,
                    "updatedAt": FieldValue.serverTimestamp()
                ]) { error in
                    if let error = error {
                        AppLog.firestore.error("❌ Error removing FCM token: \(error.localizedDescription)")
                    } else {
                        AppLog.firestore.info("✅ FCM token removed for device: \(deviceId) | Remaining devices: \(tokensArray.count)")

                    }
                }
            }
        }
    }
    
    /// Remove all FCM tokens for the user (useful for complete logout/account deletion)
    func removeAllFCMTokens() {
        guard let userId = Auth.auth().currentUser?.uid else {
            AppLog.auth.warning("⚠️ No user logged in — cannot remove FCM token")

            return
        }
        
        let userRef = db.collection("users").document(userId)
        
        userRef.updateData([
            "fcmTokens": FieldValue.delete(),
            "updatedAt": FieldValue.serverTimestamp()
        ]) { error in
            if let error = error {
                AppLog.firestore.error("❌ Error removing all FCM tokens: \(error.localizedDescription)")
            } else {
                AppLog.firestore.info("✅ All FCM tokens removed for user: \(userId)")
            }
        }
    }
    
    /// Clean up old or invalid tokens (optional maintenance method)
    func cleanupOldTokens(olderThanDays days: Int = 30) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        let userRef = db.collection("users").document(userId)
        let cutoffDate = Calendar.current.date(byAdding: .day, value: -days, to: Date()) ?? Date()
        
        userRef.getDocument { snapshot, error in
            if let error = error {
                AppLog.firestore.error("❌ Error fetching user doc: \(error.localizedDescription)")
                return
            }
            
            guard let data = snapshot?.data(),
                  var tokensArray = data["fcmTokens"] as? [[String: Any]] else {
                return
            }
            
            let originalCount = tokensArray.count
            
            // Remove tokens older than cutoff date
            tokensArray.removeAll { dict in
                if let timestamp = dict["updatedAt"] as? Timestamp {
                    return timestamp.dateValue() < cutoffDate
                }
                return false
            }
            
            if tokensArray.count < originalCount {
                userRef.updateData([
                    "fcmTokens": tokensArray,
                    "updatedAt": FieldValue.serverTimestamp()
                ]) { error in
                    if let error = error {
                        AppLog.firestore.error("❌ Error cleaning up tokens: \(error.localizedDescription)")
                    } else {
                        AppLog.firestore.info("🧹 Cleaned \(originalCount - tokensArray.count) old tokens")
                    }
                }
            }
        }
    }
}
