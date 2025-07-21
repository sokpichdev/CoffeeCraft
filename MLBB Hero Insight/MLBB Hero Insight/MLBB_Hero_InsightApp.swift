//
//  MLBB_Hero_InsightApp.swift
//  MLBB Hero Insight
//
//  Created by Sok Pich on 6/18/25.
//

import SwiftUI
import SVGKitSwift

@main
struct MLBB_Hero_InsightApp: App {
    @StateObject private var tabBarManager = TabBarVisibilityManager()
    var body: some Scene {
        WindowGroup {
            MainApp().environmentObject(tabBarManager)
        }
    }
}
