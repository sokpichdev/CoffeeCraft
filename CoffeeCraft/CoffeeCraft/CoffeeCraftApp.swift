//
//  CoffeeCraftApp.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 10/20/25.
//

import SwiftUI
import Firebase

@main
struct CoffeeCraftApp: App {
    @StateObject private var session = UserSession.shared
    @StateObject var authVM = AuthViewModel()
    @StateObject private var themeManager = ThemeManager()

    let currentEnv = Constants.currentEnv

    init() {
        configureFirebase(for: currentEnv)
    }

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

    func configureFirebase(for env: FirebaseEnvironment) {

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
        print("✅ Firebase configured for \(env) with bundle ID: \(options.bundleID)")
    }
}
