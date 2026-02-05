//
//  FCMTokenService.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 2/5/26.
//
import Foundation
import FirebaseFirestore
import FirebaseAuth

class FCMTokenService {
    static let shared = FCMTokenService()
    private let db = Firestore.firestore()
    
    private init() {}
    
    /// Save FCM token to Firestore for the current user
    func saveFCMToken(_ token: String) {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("⚠️ No user logged in, cannot save FCM token")
            return
        }
        
        let userRef = db.collection("users").document(userId)
        
        userRef.updateData([
            "fcmToken": token,
            "updatedAt": FieldValue.serverTimestamp()
        ]) { error in
            if let error = error {
                print("❌ Error saving FCM token: \(error.localizedDescription)")
            } else {
                print("✅ FCM token saved successfully for user: \(userId)")
            }
        }
    }
    
    /// Remove FCM token from Firestore (call on logout)
    func removeFCMToken() {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("⚠️ No user logged in, cannot remove FCM token")
            return
        }
        
        let userRef = db.collection("users").document(userId)
        
        userRef.updateData([
            "fcmToken": FieldValue.delete(),
            "updatedAt": FieldValue.serverTimestamp()
        ]) { error in
            if let error = error {
                print("❌ Error removing FCM token: \(error.localizedDescription)")
            } else {
                print("✅ FCM token removed successfully for user: \(userId)")
            }
        }
    }
}
