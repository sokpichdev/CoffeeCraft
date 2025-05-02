//
//  NotificationAppApp.swift
//  NotificationApp
//
//  Created by Sok Pich on 4/17/25.
//

import SwiftUI

@main
struct NotificationApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            NotificationView()
        }
    }
}

