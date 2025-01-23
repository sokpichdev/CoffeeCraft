//
//  OneNewsApp.swift
//  OneNews
//
//  Created by Sok Pich on 12/2/24.
//

import SwiftUI

@main
struct OneNewsApp: App {
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
