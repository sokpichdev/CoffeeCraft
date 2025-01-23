//
//  OneNewsApp.swift
//  OneNews
//
//  Created by Sok Pich on 12/2/24.
//

import SwiftUI
import FirebaseCore

@main
struct OneNewsApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    @AppStorage("isDarkMode") private var isDarkMode = UserPreference.shared.getIsDarkMode()
    var body: some Scene {
        WindowGroup {
            TabBar()
                .preferredColorScheme(isDarkMode ? .dark : .light)

//            AlbumUI()
//            JournalsView()
//            SideMenuView1()
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()

    return true
  }
}
