//
//  CoffeeCraftApp.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 10/20/25.
//

import SwiftUI
import Firebase

enum FirebaseEnvironment {
    case dev, sit, uat, prod
}

@main
struct CoffeeCraftApp: App {
    @StateObject var authVM = AuthViewModel()
    // Set which environment you want to run
    var currentEnv: FirebaseEnvironment {
        #if Dev
        return .dev
        #elseif SIT
        return .sit
        #elseif UAT
        return .uat
        #else
        return .prod
        #endif
    }

    init() {
        configureFirebase(for: currentEnv)
    }

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                RootView()
                    .environmentObject(authVM)
            }
        }
    }

    func configureFirebase(for env: FirebaseEnvironment) {
        var plistName: String

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
