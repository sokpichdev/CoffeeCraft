//
//  ThemeManager.swift
//  CoffeeCraft
//
//  Manages both appearance mode (light/dark/system)
//  and the active color palette (Brown, Strawberry, Matcha, Oreo).
//

import SwiftUI

final class ThemeManager: ObservableObject {
    static let shared = ThemeManager()

    // MARK: Appearance (light / dark / system)

    @AppStorage("app_theme") private var storedTheme: String = AppTheme.system.rawValue

    @Published var theme: AppTheme = .system {
        didSet { storedTheme = theme.rawValue }
    }

    // MARK: Color Palette

    @AppStorage("color_palette") private var storedPalette: String = ColorPalette.brown.rawValue

    @Published var palette: ColorPalette = .brown {
        didSet { storedPalette = palette.rawValue }
    }

    // MARK: Init

    private init() {
        theme   = AppTheme(rawValue: storedTheme)      ?? .system
        palette = ColorPalette(rawValue: storedPalette) ?? .brown
    }

    // MARK: Setters

    func setTheme(_ newTheme: AppTheme) {
        theme = newTheme
    }

    func setPalette(_ newPalette: ColorPalette) {
        withAnimation(.easeInOut(duration: 0.35)) {
            palette = newPalette
        }
    }
}
