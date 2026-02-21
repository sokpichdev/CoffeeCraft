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

    /// Unique identifier for this physical device
    private var deviceId: String {
        UIDevice.current.identifierForVendor?.uuidString ?? "unknown-device"
    }

    // MARK: - Save token (callback-based, called from Messaging delegate)
    func saveFCMToken(_ token: String) {
        guard let userId = Auth.auth().currentUser?.uid else {
            AppLog.auth.warning("⚠️ No user logged in — cannot save FCM token")
            return
        }

        let userRef = db.collection("users").document(userId)

        userRef.getDocument { [weak self] snapshot, error in
            guard let self = self else { return }

            if let error = error {
                AppLog.firestore.error("❌ Error fetching user doc: \(error.localizedDescription)")
                return
            }

            var tokensArray: [[String: Any]] = []

            if let data = snapshot?.data(),
               let existing = data["fcmTokens"] as? [[String: Any]] {
                tokensArray = existing
            }

            let deviceId = self.deviceId

            if let index = tokensArray.firstIndex(where: { $0["deviceId"] as? String == deviceId }) {
                tokensArray[index] = [
                    "token": token,
                    "deviceId": deviceId,
                    "platform": "ios",
                    "updatedAt": Timestamp(date: Date())
                ]
                AppLog.firestore.info("🔄 Updating FCM token for device: \(deviceId)")
            } else {
                tokensArray.append([
                    "token": token,
                    "deviceId": deviceId,
                    "platform": "ios",
                    "updatedAt": Timestamp(date: Date())
                ])
                AppLog.firestore.info("➕ Adding new FCM token for device: \(deviceId)")
            }

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

    // MARK: - Remove token (async — MUST complete before Auth.signOut())
    // Using async/await here is critical. The old callback version would
    // fire the Firestore write AFTER signOut() already ran, so the token
    // was never actually removed from the previous user's document.
    func removeFCMToken() async {
        guard let userId = Auth.auth().currentUser?.uid else {
            AppLog.firestore.error("⚠️ No user logged in, cannot remove FCM token")
            return
        }

        let userRef = db.collection("users").document(userId)
        let deviceId = self.deviceId

        do {
            let snapshot = try await userRef.getDocument()

            guard let data = snapshot.data(),
                  var tokensArray = data["fcmTokens"] as? [[String: Any]] else {
                AppLog.auth.warning("⚠️ No tokens found for user: \(userId)")
                return
            }

            tokensArray.removeAll { $0["deviceId"] as? String == deviceId }

            if tokensArray.isEmpty {
                // No devices left — remove the field entirely
                try await userRef.updateData([
                    "fcmTokens": FieldValue.delete(),
                    "updatedAt": FieldValue.serverTimestamp()
                ])
                AppLog.firestore.info("🗑 Last token removed, field deleted for device: \(deviceId)")
            } else {
                try await userRef.updateData([
                    "fcmTokens": tokensArray,
                    "updatedAt": FieldValue.serverTimestamp()
                ])
                AppLog.firestore.info("✅ FCM token removed for device: \(deviceId) | Remaining: \(tokensArray.count)")
            }
        } catch {
            AppLog.firestore.error("❌ removeFCMToken failed: \(error.localizedDescription)")
        }
    }

    // MARK: - Remove all tokens (account deletion / full reset)
    func removeAllFCMTokens() async {
        guard let userId = Auth.auth().currentUser?.uid else {
            AppLog.auth.warning("⚠️ No user logged in — cannot remove FCM tokens")
            return
        }

        do {
            try await db.collection("users").document(userId).updateData([
                "fcmTokens": FieldValue.delete(),
                "updatedAt": FieldValue.serverTimestamp()
            ])
            AppLog.firestore.info("✅ All FCM tokens removed for user: \(userId)")
        } catch {
            AppLog.firestore.error("❌ removeAllFCMTokens failed: \(error.localizedDescription)")
        }
    }

    // MARK: - Cleanup old tokens (optional maintenance)
    func cleanupOldTokens(olderThanDays days: Int = 30) async {
        guard let userId = Auth.auth().currentUser?.uid else { return }

        let userRef = db.collection("users").document(userId)
        let cutoffDate = Calendar.current.date(byAdding: .day, value: -days, to: Date()) ?? Date()

        do {
            let snapshot = try await userRef.getDocument()

            guard let data = snapshot.data(),
                  var tokensArray = data["fcmTokens"] as? [[String: Any]] else { return }

            let originalCount = tokensArray.count
            tokensArray.removeAll { dict in
                if let ts = dict["updatedAt"] as? Timestamp {
                    return ts.dateValue() < cutoffDate
                }
                return false
            }

            guard tokensArray.count < originalCount else { return }

            try await userRef.updateData([
                "fcmTokens": tokensArray,
                "updatedAt": FieldValue.serverTimestamp()
            ])
            AppLog.firestore.info("🧹 Cleaned \(originalCount - tokensArray.count) old token(s)")
        } catch {
            AppLog.firestore.error("❌ cleanupOldTokens failed: \(error.localizedDescription)")
        }
    }
}
