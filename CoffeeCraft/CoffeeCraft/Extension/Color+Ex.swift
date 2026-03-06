//
//  Color+Ex.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 12/29/25.
//  Updated: Full adaptive token system (light + dark mode)
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
        let r = (rgbValue & 0xff0000) >> 16
        let g = (rgbValue & 0xff00) >> 8
        let b = rgbValue & 0xff
        self.init(red: CGFloat(r) / 0xff, green: CGFloat(g) / 0xff, blue: CGFloat(b) / 0xff)
    }

    static func random(randomOpacity: Bool = false) -> Color {
        Color(red: .random(in: 0...1), green: .random(in: 0...1),
              blue: .random(in: 0...1), opacity: randomOpacity ? .random(in: 0...1) : 1)
    }
}

// MARK: - Semantic Design Tokens  (Adaptive Light / Dark)
//
//  Token map:
//  ┌─────────────────────┬──────────────┬──────────────┐
//  │ Token               │ Light        │ Dark         │
//  ├─────────────────────┼──────────────┼──────────────┤
//  │ bgPrimary           │ #F5EDE4      │ #1A0F0A      │
//  │ bgSecondary         │ #FDF6EF      │ #231510      │
//  │ surfacePrimary      │ #FFFFFF      │ #2E1C14      │
//  │ surfaceSub          │ #F0E6DA      │ #3A241A      │
//  │ borderColor         │ #E2D3C4      │ #4A2E22      │
//  │ textPrimary         │ #1E110A      │ #F5E8DC      │
//  │ textSecondary       │ #6B4E3D      │ #D4A882      │
//  │ textMuted           │ #A0856E      │ #8C6652      │
//  │ accentPrimary       │ #6F4E37      │ #9E6B4F      │
//  │ accentGold          │ #C8860A      │ #E8A020      │
//  │ semanticSuccess     │ #5A8A3C      │ #72B048      │
//  │ semanticWarning     │ #C97C1A      │ #E89F40      │
//  │ semanticError       │ #B03A2A      │ #E05040      │
//  └─────────────────────┴──────────────┴──────────────┘

// extension Color {
//
//    // ── Backgrounds ──────────────────────────────────────────────
//    /// Main app background. Warm cream (light) / Deep espresso (dark).
//    static let bgPrimary      = Color("bgPrimary")
//    /// Secondary background for grouped list sections.
//    static let bgSecondary    = Color("bgSecondary")
//
//    // ── Surfaces / Cards ─────────────────────────────────────────
//    /// Primary card / sheet surface.
//    static let surfacePrimary = Color("surfacePrimary")
//    /// Sub-surface for nested rows, chips, tag backgrounds.
//    static let surfaceSub     = Color("surfaceSub")
//    /// Dividers, card strokes, input borders in idle state.
//    static let borderColor    = Color("borderColor")
//
//    // ── Typography ───────────────────────────────────────────────
//    /// Body copy, titles — highest contrast.
//    static let textPrimary    = Color("textPrimary")
//    /// Subtitles, secondary labels.
//    static let textSecondary  = Color("textSecondary")
//    /// Placeholders, timestamps, muted captions.
//    static let textMuted      = Color("textMuted")
//
//    // ── Brand Accents ─────────────────────────────────────────────
//    /// Primary CTA: buttons, tab highlights, active states.
//    static let accentPrimary  = Color("accentPrimary")
//    /// Rewards / Points / premium CTAs only.
//    static let accentGold     = Color("accentGold")
//
//    // ── Semantic Status ───────────────────────────────────────────
//    /// Completed, success, active states.
//    static let semanticSuccess = Color("semanticSuccess")
//    /// Pending, in-progress, coming soon.
//    static let semanticWarning = Color("semanticWarning")
//    /// Errors, cancellations, form failures.
//    static let semanticError   = Color("semanticError")
// }
//
//// MARK: - Legacy Coffee Brand Tokens  (backward compat — now all adaptive)
// extension Color {
//    static let coffeeBrown      = Color("coffeeBrown")
//    static let coffeeLight      = Color("coffeeLight")
//    static let coffeeDarkBrown  = Color("coffeeDarkBrown")
//    static let coffeeCream      = Color("coffeeCream")
//    static let coffeeWarmBrown  = Color("coffeeWarmBrown")
//    static let coffeeOliveGreen = Color("coffeeOliveGreen")
//
//    static let caramelGold   = Color("caramelGold")
//    static let cinnamonSpice = Color("cinnamonSpice")
//    static let mochaRose     = Color("mochaRose")
//    static let vanillaYellow = Color("vanillaYellow")
//
//    static let leafGreen    = Color("leafGreen")
//    static let warningAmber = Color("warningAmber")
//    static let errorRed     = Color("errorRed")
//
//    static let mainCreamBg   = Color("mainCreamBg")
//    static let ashWood       = Color("ashWood")
//    static let creamWhite    = Color("creamWhite")
//    static let espressoBlack = Color("espressoBlack")
//    static let parchment     = Color("parchment")
// }

// MARK: - Gradient Helpers
extension LinearGradient {
    /// Primary brand gradient: coffee brown → light.
    static let brandPrimary = LinearGradient(
        colors: [Color.accentPrimary, Color.coffeeLight],
        startPoint: .topLeading, endPoint: .bottomTrailing
    )
    /// Gold reward gradient.
    static let brandGold = LinearGradient(
        colors: [Color.accentGold, Color.coffeeLight],
        startPoint: .leading, endPoint: .trailing
    )
    /// Wallet card: rich espresso → caramel.
    static let walletCard = LinearGradient(
        colors: [Color.coffeeDarkBrown, Color.coffeeBrown, Color.accentGold],
        startPoint: .topLeading, endPoint: .bottomTrailing
    )
}
