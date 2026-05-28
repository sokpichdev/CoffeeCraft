//
//  AppEnvironment.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 28/05/2026.
//

import Foundation

/// Process-wide environment overrides used for demos and screenshots.
/// In release builds `now` always returns the real current date.
enum AppEnvironment {
    #if DEBUG
    /// Set to a fixed date to pin "now" for demos/screenshots. nil = real time.
    /// Example: ISO8601DateFormatter().date(from: "2026-03-26T12:00:00Z")
    static var demoNow: Date? = ISO8601DateFormatter().date(from: "2026-03-26T12:00:00Z")
    #endif

    static var now: Date {
        #if DEBUG
        return demoNow ?? Date()
        #else
        return Date()
        #endif
    }
}
