//
//  CoffeeCraftApp.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 10/20/25.
//

import SwiftUI
import FirebaseCore
import FirebaseMessaging
import UserNotifications

@main
struct CoffeeCraftApp: App {
    @StateObject private var session = UserSession.shared
    @StateObject var authVM = AuthViewModel()
    @StateObject private var themeManager = ThemeManager()
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    var body: some Scene {
        WindowGroup {
            CustomNavigationStack {
                RootView()
                    .environmentObject(session)
                    .environmentObject(authVM)
                    .preferredColorScheme(themeManager.theme.colorScheme)
                    .environmentObject(themeManager)
            }
        }
    }
}
