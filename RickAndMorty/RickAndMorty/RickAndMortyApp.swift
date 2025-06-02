//
//  RickAndMortyApp.swift
//  RickAndMorty
//
//  Created by Sok Pich on 5/21/25.
//

import SwiftUI

@main
struct RickAndMortyApp: App {
    @StateObject private var tabBarManager = TabBarVisibilityManager()
    var body: some Scene {
        WindowGroup {
            TabBarView1().environmentObject(tabBarManager)
//            ContentView()
        }
    }
}
