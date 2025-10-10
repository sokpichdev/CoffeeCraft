//
//  ScanTrackingApp.swift
//  ScanTracking
//
//  Created by Sok Pich on 10/10/25.
//
import SwiftUI
import CoreData
import Foundation

@main
struct ScanTrackingApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
