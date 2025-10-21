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
    @StateObject var authVM = AuthViewModel()
    @StateObject var cartManager = CartManager()
    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(authVM)
                .environmentObject(cartManager)
        }
    }
}
