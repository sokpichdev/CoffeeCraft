//
//  ColorPalette.swift
//  CoffeeCraft
//
//  Color Theme Module — Preset Palettes
//  Each palette defines semantic tokens for both light and dark mode.
//

import SwiftUI

// MARK: - Color Token Set

struct PaletteTokens {
    let bgPrimary:      UIColor
    let bgSecondary:    UIColor
    let surfacePrimary: UIColor
    let surfaceSub:     UIColor
    let borderColor:    UIColor
    let textPrimary:    UIColor
    let textSecondary:  UIColor
    let textMuted:      UIColor
    let accentPrimary:  UIColor
    let accentGold:     UIColor
}

// MARK: - ColorPalette Enum

enum ColorPalette: String, CaseIterable, Identifiable {
    case brown
    case strawberry
    case matcha
    case oreo

    var id: String { rawValue }

    // MARK: Display Info

    var title: String {
        switch self {
        case .brown:      return "Brown"
        case .strawberry: return "Strawberry"
        case .matcha:     return "Matcha"
        case .oreo:       return "Oreo"
        }
    }

    var subtitle: String {
        switch self {
        case .brown:      return "Warm espresso tones"
        case .strawberry: return "Soft rose & berry"
        case .matcha:     return "Fresh sage & green"
        case .oreo:       return "Clean black & white"
        }
    }

    var emoji: String {
        switch self {
        case .brown:      return "☕"
        case .strawberry: return "🍓"
        case .matcha:     return "🍵"
        case .oreo:       return "🖤"
        }
    }

    // MARK: Swatch Preview Colors (for the picker UI)

    var swatchColors: [Color] {
        switch self {
        case .brown:
            return [Color(hex: "#6F4E37"), Color(hex: "#C8860A"), Color(hex: "#F5EDE4"), Color(hex: "#A0856E")]
        case .strawberry:
            return [Color(hex: "#C44569"), Color(hex: "#E8780A"), Color(hex: "#FFF0F3"), Color(hex: "#B87080")]
        case .matcha:
            return [Color(hex: "#4A7C59"), Color(hex: "#8A9A0A"), Color(hex: "#EFF5EE"), Color(hex: "#6A9E7A")]
        case .oreo:
            return [Color(hex: "#222222"), Color(hex: "#C8860A"), Color(hex: "#F5F5F5"), Color(hex: "#888888")]
        }
    }

    // MARK: Light Mode Tokens

    var light: PaletteTokens {
        switch self {

        case .brown:
            return PaletteTokens(
                bgPrimary:      UIColor(hex: "#F5EDE4"),
                bgSecondary:    UIColor(hex: "#FDF6EF"),
                surfacePrimary: UIColor(hex: "#FFFFFF"),
                surfaceSub:     UIColor(hex: "#F0E6DA"),
                borderColor:    UIColor(hex: "#E2D3C4"),
                textPrimary:    UIColor(hex: "#1E110A"),
                textSecondary:  UIColor(hex: "#6B4E3D"),
                textMuted:      UIColor(hex: "#A0856E"),
                accentPrimary:  UIColor(hex: "#6F4E37"),
                accentGold:     UIColor(hex: "#C8860A")
            )

        case .strawberry:
            return PaletteTokens(
                bgPrimary:      UIColor(hex: "#FFF0F3"),
                bgSecondary:    UIColor(hex: "#FFF8F9"),
                surfacePrimary: UIColor(hex: "#FFFFFF"),
                surfaceSub:     UIColor(hex: "#FFE4EA"),
                borderColor:    UIColor(hex: "#FFCCD5"),
                textPrimary:    UIColor(hex: "#2D0A10"),
                textSecondary:  UIColor(hex: "#8B3A4A"),
                textMuted:      UIColor(hex: "#B87080"),
                accentPrimary:  UIColor(hex: "#C44569"),
                accentGold:     UIColor(hex: "#E8780A")
            )

        case .matcha:
            return PaletteTokens(
                bgPrimary:      UIColor(hex: "#EFF5EE"),
                bgSecondary:    UIColor(hex: "#F7FBF6"),
                surfacePrimary: UIColor(hex: "#FFFFFF"),
                surfaceSub:     UIColor(hex: "#E0EEE0"),
                borderColor:    UIColor(hex: "#C8DCC8"),
                textPrimary:    UIColor(hex: "#0A1E0A"),
                textSecondary:  UIColor(hex: "#3A6B3A"),
                textMuted:      UIColor(hex: "#6A9E7A"),
                accentPrimary:  UIColor(hex: "#4A7C59"),
                accentGold:     UIColor(hex: "#8A9A0A")
            )

        case .oreo:
            return PaletteTokens(
                bgPrimary:      UIColor(hex: "#F5F5F5"),
                bgSecondary:    UIColor(hex: "#FAFAFA"),
                surfacePrimary: UIColor(hex: "#FFFFFF"),
                surfaceSub:     UIColor(hex: "#EEEEEE"),
                borderColor:    UIColor(hex: "#DDDDDD"),
                textPrimary:    UIColor(hex: "#111111"),
                textSecondary:  UIColor(hex: "#444444"),
                textMuted:      UIColor(hex: "#888888"),
                accentPrimary:  UIColor(hex: "#222222"),
                accentGold:     UIColor(hex: "#C8860A")
            )
        }
    }

    // MARK: Dark Mode Tokens

    var dark: PaletteTokens {
        switch self {

        case .brown:
            return PaletteTokens(
                bgPrimary:      UIColor(hex: "#1A0F0A"),
                bgSecondary:    UIColor(hex: "#231510"),
                surfacePrimary: UIColor(hex: "#2E1C14"),
                surfaceSub:     UIColor(hex: "#3A241A"),
                borderColor:    UIColor(hex: "#4A2E22"),
                textPrimary:    UIColor(hex: "#F5E8DC"),
                textSecondary:  UIColor(hex: "#D4A882"),
                textMuted:      UIColor(hex: "#8C6652"),
                accentPrimary:  UIColor(hex: "#9E6B4F"),
                accentGold:     UIColor(hex: "#E8A020")
            )

        case .strawberry:
            return PaletteTokens(
                bgPrimary:      UIColor(hex: "#1A080B"),
                bgSecondary:    UIColor(hex: "#220C10"),
                surfacePrimary: UIColor(hex: "#2E1016"),
                surfaceSub:     UIColor(hex: "#3A161E"),
                borderColor:    UIColor(hex: "#4A202A"),
                textPrimary:    UIColor(hex: "#FFE8EC"),
                textSecondary:  UIColor(hex: "#E89090"),
                textMuted:      UIColor(hex: "#A05060"),
                accentPrimary:  UIColor(hex: "#E05878"),
                accentGold:     UIColor(hex: "#E8A020")
            )

        case .matcha:
            return PaletteTokens(
                bgPrimary:      UIColor(hex: "#0A150A"),
                bgSecondary:    UIColor(hex: "#101E10"),
                surfacePrimary: UIColor(hex: "#162616"),
                surfaceSub:     UIColor(hex: "#1E301E"),
                borderColor:    UIColor(hex: "#2A422A"),
                textPrimary:    UIColor(hex: "#E0F0E0"),
                textSecondary:  UIColor(hex: "#90C890"),
                textMuted:      UIColor(hex: "#508050"),
                accentPrimary:  UIColor(hex: "#5AAA72"),
                accentGold:     UIColor(hex: "#A0C020")
            )

        case .oreo:
            return PaletteTokens(
                bgPrimary:      UIColor(hex: "#0A0A0A"),
                bgSecondary:    UIColor(hex: "#111111"),
                surfacePrimary: UIColor(hex: "#1A1A1A"),
                surfaceSub:     UIColor(hex: "#222222"),
                borderColor:    UIColor(hex: "#333333"),
                textPrimary:    UIColor(hex: "#F0F0F0"),
                textSecondary:  UIColor(hex: "#BBBBBB"),
                textMuted:      UIColor(hex: "#777777"),
                accentPrimary:  UIColor(hex: "#E0E0E0"),
                accentGold:     UIColor(hex: "#E8A020")
            )
        }
    }

    // MARK: Dynamic UIColor resolver

    func dynamicColor(
        _ keyPath: KeyPath<PaletteTokens, UIColor>
    ) -> UIColor {
        UIColor { traits in
            traits.userInterfaceStyle == .dark
                ? self.dark[keyPath: keyPath]
                : self.light[keyPath: keyPath]
        }
    }
}

// MARK: - UIColor Hex Init

extension UIColor {
    convenience init(hex: String) {
        var sanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        if sanitized.hasPrefix("#") { sanitized.removeFirst() }
        var rgb: UInt64 = 0
        Scanner(string: sanitized).scanHexInt64(&rgb)
        let r = CGFloat((rgb & 0xFF0000) >> 16) / 255
        let g = CGFloat((rgb & 0x00FF00) >> 8)  / 255
        let b = CGFloat( rgb & 0x0000FF)          / 255
        self.init(red: r, green: g, blue: b, alpha: 1)
    }
}
