//
//  AppDelegate.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 2/5/26.
//
//  Sprint 1 additions:
//    • Crashlytics — enabled for SIT / UAT / Prod; disabled in Dev
//    • Firestore offline persistence — 200 MB disk cache
//    • SDWebImage — memory + disk cache limits, scale-down large images,
//                   memory-warning flush
//

import FirebaseCore
import FirebaseCrashlytics
import FirebaseFirestore
import FirebaseMessaging
import SDWebImage
import UIKit
import UserNotifications

class AppDelegate: NSObject, UIApplicationDelegate {
    let currentEnv = Constants.currentEnv
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        // Configure Firebase
        configureFirebase(for: currentEnv)

        // Crashlytics — collect in all envs except Dev
        configureCrashlytics()

        // Firestore offline persistence
        configureFirestorePersistence()

        // SDWebImage caching
        configureImageCache(application)

        // Push notifications
        setupNotifications(application)
        
        return true
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Persist the latest in-memory rider position before the OS may kill the app.
        // This is the primary flush trigger — fires reliably when user swipes app away.
        Task { @MainActor in
            OrderEnvironment.shared.flushAllActiveDeliveries()
        }
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Secondary flush in case the app is force-quit without going to background first.
        Task { @MainActor in
            OrderEnvironment.shared.flushAllActiveDeliveries()
        }
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
        didReceiveRemoteNotification userInfo: [AnyHashable: Any],
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

extension AppDelegate {

    // MARK: Crashlytics

    /// Enables crash collection for SIT / UAT / Prod.
    /// Disabled in Dev so local crashes stay in Xcode, not the Firebase console.
    private func configureCrashlytics() {
        let enabled = currentEnv != .dev
        Crashlytics.crashlytics().setCrashlyticsCollectionEnabled(enabled)
        AppLog.firestore.debug(
            "🔥 Crashlytics collection \(enabled ? "enabled" : "disabled") for env: \(self.currentEnv)")
    }

    // MARK: Firestore Persistence

    /// Turns on Firestore's built-in local disk cache so the app can display
    /// previously-fetched data while offline. Writes made offline are queued
    /// and flushed automatically when connectivity is restored.
    private func configureFirestorePersistence() {
        // persistent cache (disk + offline persistence)
        let persistentCache = PersistentCacheSettings(sizeBytes: 200 * 1024 * 1024 as NSNumber)
        
        let settings = FirestoreSettings()
        settings.cacheSettings = persistentCache

        Firestore.firestore().settings = settings

        AppLog.firestore.debug("💾 Firestore persistence enabled (200 MB cache)")
    }

    // MARK: SDWebImage Cache

    /// Caps in-memory cache at 50 MB and on-disk cache at 200 MB / 7 days.
    /// Large images are scaled down at decode time, reducing RAM pressure.
    /// The memory cache is flushed on OS memory-pressure warnings.
    private func configureImageCache(_ application: UIApplication) {
        SDImageCache.shared.config.maxMemoryCost = 50  * 1024 * 1024   // 50 MB
        SDImageCache.shared.config.maxDiskSize = 200 * 1024 * 1024   // 200 MB
        SDImageCache.shared.config.maxDiskAge = 7 * 24 * 60 * 60    // 7 days
//        SDImageCache.shared.config.shouldDecompressImages = true

        SDWebImageManager.shared.optionsProcessor =
            SDWebImageOptionsProcessor { _, options, context in
                var mutableOptions = options
                mutableOptions.insert(.scaleDownLargeImages)  // thumbnail-safe
                mutableOptions.insert(.retryFailed)           // retry once on transient error
                return SDWebImageOptionsResult(options: mutableOptions, context: context)
            }

        // Flush in-memory cache under OS memory pressure
        NotificationCenter.default.addObserver(
            forName: UIApplication.didReceiveMemoryWarningNotification,
            object: nil,
            queue: .main
        ) { _ in
            SDImageCache.shared.clearMemory()
            AppLog.firestore.warning("⚠️ Memory warning — SDWebImage memory cache cleared")
        }

        AppLog.firestore.debug("🖼️ SDWebImage cache configured (50 MB RAM / 200 MB disk / 7d TTL)")
    }
}
