//
//  AppDelegate.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 2/5/26.
//
import UIKit
import FirebaseCore
import FirebaseMessaging
import UserNotifications

class AppDelegate: NSObject, UIApplicationDelegate {
    let currentEnv = Constants.currentEnv
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
        // Configure Firebase
        configureFirebase(for: currentEnv)
        
        // Setup notifications
        setupNotifications(application)
        
        return true
    }
    
    // MARK: - Notification Setup
    
    private func setupNotifications(_ application: UIApplication) {
        // Set delegates
        UNUserNotificationCenter.current().delegate = self
        Messaging.messaging().delegate = self
        Messaging.messaging().isAutoInitEnabled = true
        
        // Request permissions
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { granted, error in
            if granted {
                AppLog.firestore.info("✅ Notification permission granted")
            } else if let error = error {
                AppLog.firestore.error("❌ Notification permission error: \(error.localizedDescription)")
            } else {
                AppLog.firestore.error("❌ Notification permission denied")
            }
        }
        
        // Register for remote notifications
        application.registerForRemoteNotifications()
    }
    
    // MARK: - Remote Notification Registration
    
    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        // Pass device token to FCM
        Messaging.messaging().apnsToken = deviceToken
        
        // Log device token for debugging
        let tokenString = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        AppLog.firestore.info("📱 APNs Device Token: \(tokenString)")
    }
    
    func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
        AppLog.firestore.error("❌ Failed to register for remote notifications: \(error.localizedDescription)")
    }
    
    // MARK: - Background Notification Handling
    
    func application(
        _ application: UIApplication,
        didReceiveRemoteNotification userInfo: [AnyHashable : Any],
        fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
    ) {
        AppLog.printItem(userInfo, label: "📩 Remote notification received")
        // Inform FCM about the message
        Messaging.messaging().appDidReceiveMessage(userInfo)
        
        completionHandler(.newData)
    }
}

// MARK: - UNUserNotificationCenterDelegate

extension AppDelegate: UNUserNotificationCenterDelegate {
    
    /// Handle notification when app is in foreground
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        let userInfo = notification.request.content.userInfo
        AppLog.printItem(userInfo, label: "📬 Notification received in foreground")

        
        // Inform FCM about the message
        Messaging.messaging().appDidReceiveMessage(userInfo)
        
        // Show notification banner and play sound even when app is in foreground
        completionHandler([.banner, .sound, .badge])
    }
    
    /// Handle notification tap
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo
        AppLog.printItem(userInfo, label: "📬 Notification received in foreground")
        
        // Inform FCM about the message
        Messaging.messaging().appDidReceiveMessage(userInfo)
        
        // Handle deep linking to order
        if let orderId = userInfo["orderId"] as? String {
            AppLog.firestore.debug("🔗 Deep linking to order: \(orderId)")
            NotificationCenter.default.post(
                name: Notification.Name("NavigateToOrder"),
                object: nil,
                userInfo: ["orderId": orderId]
            )
        }
        
        completionHandler()
    }
}

// MARK: - MessagingDelegate

extension AppDelegate: MessagingDelegate {
    
    /// Handle FCM token refresh
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        guard let token = fcmToken else {
            AppLog.firestore.warning("⚠️ FCM token is nil")
            return
        }
        
        AppLog.firestore.info("🔑 FCM Token: \(token)")
        
        // Save token to Firestore
        FCMTokenService.shared.saveFCMToken(token)
        
        // Broadcast token to other parts of the app
        NotificationCenter.default.post(
            name: Notification.Name("FCMToken"),
            object: nil,
            userInfo: ["token": token]
        )
    }
}

// MARK: - Firebase Configuration

extension AppDelegate {
    
    private func configureFirebase(for env: FirebaseEnvironment) {
        let plistName: String
        
        switch env {
        case .dev:  plistName = "GoogleService-Info-Dev"
        case .sit:  plistName = "GoogleService-Info-SIT"
        case .uat:  plistName = "GoogleService-Info-UAT"
        case .prod: plistName = "GoogleService-Info"
        }
        
        guard let filePath = Bundle.main.path(forResource: plistName, ofType: "plist") else {
            fatalError("❌ Could not find plist file: \(plistName).plist")
        }
        
        guard let options = FirebaseOptions(contentsOfFile: filePath) else {
            fatalError("❌ Could not load Firebase options from plist: \(plistName).plist")
        }
        
        FirebaseApp.configure(options: options)
        AppLog.firestore.debug("Firebase configured for \(env) with bundle ID: \(options.bundleID)")
    }
}
