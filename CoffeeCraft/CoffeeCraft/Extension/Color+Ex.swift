//
//  Color+Ex.swift
//  CoffeeCraft
//
//  Updated: Full adaptive token system — palette-aware + light/dark mode.
//  All semantic tokens now read from ThemeManager.shared.palette so
//  switching palette re-renders the entire app automatically.
//

import SwiftUI

// MARK: - Hex Init & Random

extension Color {
    init(hex: String) {
        var hexSanitized = hex
        if hexSanitized.hasPrefix("#") { hexSanitized.removeFirst() }
        let scanner = Scanner(string: hexSanitized)
        var rgbValue: UInt64 = 0
        scanner.scanHexInt64(&rgbValue)
        let red   = (rgbValue & 0xFF0000) >> 16
        let green = (rgbValue & 0x00FF00) >> 8
        let blue  =  rgbValue & 0x0000FF
        self.init(
            red: CGFloat(red)   / 255,
            green: CGFloat(green) / 255,
            blue: CGFloat(blue)  / 255
        )
    }

    static func random(randomOpacity: Bool = false) -> Color {
        Color(
            red: .random(in: 0...1),
            green: .random(in: 0...1),
            blue: .random(in: 0...1),
            opacity: randomOpacity ? .random(in: 0...1) : 1
        )
    }
}

// MARK: - Palette-Aware Semantic Design Tokens
//
//  How it works:
//  ┌──────────────────────────────────────────────────────────────────┐
//  │  Each token calls ThemeManager.shared.palette.dynamicColor(...)  │
//  │  UIColor(dynamicProvider:) handles light ↔ dark switching.       │
//  │  When the user changes the palette, ThemeManager publishes a      │
//  │  change → root @StateObject re-renders → all tokens re-evaluate. │
//  └──────────────────────────────────────────────────────────────────┘

extension Color {

    // ── Backgrounds ───────────────────────────────────────────────────
    /// Main app background.
    static var bgPrimary: Color {
        Color(ThemeManager.shared.palette.dynamicColor(\.bgPrimary))
    }
    /// Secondary background for grouped list sections.
    static var bgSecondary: Color {
        Color(ThemeManager.shared.palette.dynamicColor(\.bgSecondary))
    }

    // ── Surfaces / Cards ─────────────────────────────────────────────
    /// Primary card / sheet surface.
    static var surfacePrimary: Color {
        Color(ThemeManager.shared.palette.dynamicColor(\.surfacePrimary))
    }
    /// Sub-surface for nested rows, chips, tag backgrounds.
    static var surfaceSub: Color {
        Color(ThemeManager.shared.palette.dynamicColor(\.surfaceSub))
    }
    /// Dividers, card strokes, input borders.
    static var borderColor: Color {
        Color(ThemeManager.shared.palette.dynamicColor(\.borderColor))
    }

    // ── Typography ───────────────────────────────────────────────────
    /// Body copy, titles — highest contrast.
    static var textPrimary: Color {
        Color(ThemeManager.shared.palette.dynamicColor(\.textPrimary))
    }
    /// Subtitles, secondary labels.
    static var textSecondary: Color {
        Color(ThemeManager.shared.palette.dynamicColor(\.textSecondary))
    }
    /// Placeholders, timestamps, muted captions.
    static var textMuted: Color {
        Color(ThemeManager.shared.palette.dynamicColor(\.textMuted))
    }

    // ── Brand Accents ────────────────────────────────────────────────
    /// Primary CTA: buttons, tab highlights, active states.
    static var accentPrimary: Color {
        Color(ThemeManager.shared.palette.dynamicColor(\.accentPrimary))
    }
    /// Rewards / Points / premium CTAs.
    static var accentGold: Color {
        Color(ThemeManager.shared.palette.dynamicColor(\.accentGold))
    }

    // ── Semantic Status (unchanged across palettes) ───────────────────
//    static var semanticSuccess: Color { Color("semanticSuccess") }
//    static var semanticWarning: Color { Color("semanticWarning") }
//    static var semanticError:   Color { Color("semanticError")   }

    // ── Legacy named colors (kept for backward compat) ─────────────────
    static var commonGray: Color { Color("CommonGray") }
    static var coffeeBrown: Color { Color("coffeeBrown") }
    static var coffeeLight: Color { Color("coffeeLight") }
    static var coffeeDarkBrown: Color { Color("coffeeDarkBrown") }
    static var coffeeCream: Color { Color("coffeeCream") }
    static var coffeeWarmBrown: Color { Color("coffeeWarmBrown") }
    static var coffeeOliveGreen: Color { Color("coffeeOliveGreen")}
    static var caramelGold: Color { Color("caramelGold") }
    static var cinnamonSpice: Color { Color("cinnamonSpice") }
    static var mochaRose: Color { Color("mochaRose") }
    static var vanillaYellow: Color { Color("vanillaYellow")   }
    static var leafGreen: Color { Color("leafGreen") }
    static var warningAmber: Color { Color("warningAmber") }
    static var errorRed: Color { Color("errorRed") }
    static var mainCreamBg: Color { Color("mainCreamBg") }
    static var ashWood: Color { Color("ashWood") }
    static var creamWhite: Color { Color("creamWhite") }
    static var espressoBlack: Color { Color("espressoBlack") }
    static var parchment: Color { Color("parchment") }
}

// MARK: - Gradient Helpers
extension LinearGradient {
    /// Primary brand gradient: coffee brown → light.
    static let brandPrimary = LinearGradient(
        colors: [Color.accentPrimary, Color.accentPrimary.opacity(0.6)],
        startPoint: .topLeading, endPoint: .bottomTrailing
    )
    /// Gold reward gradient.
    static let brandGold = LinearGradient(
        colors: [Color.accentGold, Color.accentPrimary.opacity(0.6)],
        startPoint: .leading, endPoint: .trailing
    )
    /// Wallet card: rich espresso → caramel.
    static let walletCard = LinearGradient(
        colors: [Color.accentPrimary, Color.accentPrimary, Color.accentGold],
        startPoint: .topLeading, endPoint: .bottomTrailing
    )
}

// MARK: - UIColor Extensions for Palette Tokens
// Makes our palette tokens available as UIColor for UIKit components

extension UIColor {
    static var textPrimaryUI: UIColor { ThemeManager.shared.palette.dynamicColor(\.textPrimary) }
    static var textSecondaryUI: UIColor { ThemeManager.shared.palette.dynamicColor(\.textSecondary) }
    static var accentPrimaryUI: UIColor { ThemeManager.shared.palette.dynamicColor(\.accentPrimary) }
    static var bgPrimaryUI: UIColor { ThemeManager.shared.palette.dynamicColor(\.bgPrimary) }
    static var surfacePrimaryUI: UIColor { ThemeManager.shared.palette.dynamicColor(\.surfacePrimary) }
    static var borderColorUI: UIColor { ThemeManager.shared.palette.dynamicColor(\.borderColor) }
}
