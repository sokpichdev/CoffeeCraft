//
//  ThemeManager.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 1/20/26.
//
import SwiftUI

final class ThemeManager: ObservableObject {
    @AppStorage("app_theme") private var storedTheme: String = AppTheme.system.rawValue

    @Published var theme: AppTheme = .system

    init() {
        theme = AppTheme(rawValue: storedTheme) ?? .system
    }

    func setTheme(_ newTheme: AppTheme) {
        theme = newTheme
        storedTheme = newTheme.rawValue
    }
}
