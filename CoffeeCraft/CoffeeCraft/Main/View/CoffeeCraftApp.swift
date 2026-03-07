//
//  CoffeeCraftApp.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 10/20/25.
//

import FirebaseCore
import FirebaseMessaging
import SwiftUI
import UserNotifications

@main
struct CoffeeCraftApp: App {
    @StateObject private var session = UserSession.shared
    @StateObject var authVM = AuthViewModel()
    @StateObject private var orderVM = OrderViewModel()
    @StateObject private var coordinator = NotificationCoordinator.shared
    @StateObject private var themeManager = ThemeManager.shared
    @StateObject private var walletVM = WalletViewModel()

    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    var body: some Scene {
        WindowGroup {
            CustomNavigationStack {
                RootView()
                    .environmentObject(session)
                    .environmentObject(authVM)
                    .environmentObject(orderVM)
                    .environmentObject(coordinator)
                    .environmentObject(walletVM)
                    .environmentObject(themeManager)
                    .preferredColorScheme(themeManager.theme.colorScheme)
                    // Forces full re-render when palette changes so all
                    // Color.accentPrimary / Color.bgPrimary etc. re-evaluate.
                    .id(themeManager.palette.rawValue)
            }
        }
    }
}
