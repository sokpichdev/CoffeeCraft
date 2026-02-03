//
//  Font+Ex.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 12/2/25.
//

import SwiftUI
import UIKit

enum AppFontConfig {
    
    /// Change this ONE line to switch the entire app font
    static var primary: AppFont = .nokora
}

// MARK: - App Font Weight

enum AppFontWeight {
    case black
    case light
    case regular
    case medium
    case semibold
    case bold
    
    var suffix: String {
        switch self {
        case .regular:  return "Regular"
        case .medium:   return "Medium"
        case .semibold: return "SemiBold"
        case .bold:     return "Bold"
        case .black: return "Black"
        case .light:  return "Light"
        }
    }
    
    /// Map to SwiftUI Font.Weight for SF Pro fallback
    var systemWeight: Font.Weight {
        switch self {
        case .regular:  return .regular
        case .medium:   return .medium
        case .semibold: return .semibold
        case .bold:     return .bold
        case .black: return .black
        case .light: return .light
        }
    }
}

// MARK: - App Font Family

enum AppFont {
    case nokora
    case roboto
    case poppins
    case montserrat
    case nunito
    
    private var family: String {
        switch self {
        case .nokora:      return "Nokora"
        case .roboto:      return "Roboto"
        case .poppins:     return "Poppins"
        case .montserrat:  return "Montserrat"
        case .nunito:      return "Nunito"
        }
    }
    
    func name(for weight: AppFontWeight) -> String {
        "\(family)-\(weight.suffix)"
    }
}

// MARK: - Core Font Builder (with SF Pro Fallback)

extension Font {
    
    static func app(
        _ font: AppFont = AppFontConfig.primary,
        weight: AppFontWeight = .regular,
        size: CGFloat,
        relativeTo textStyle: Font.TextStyle = .body
    ) -> Font {
        
        let fontName = font.name(for: weight)
        
        // ✅ Check if custom font exists
        if UIFont(name: fontName, size: size) != nil {
            return Font.custom(
                fontName,
                size: size,
                relativeTo: textStyle
            )
        }
        
        // 🔁 Fallback to SF Pro (system font)
        return Font.system(
            textStyle,
            design: .default
        ).weight(weight.systemWeight)
    }
}

extension Font {

    // MARK: - Large Titles
    static let largeTitle = Font.app(
        weight: .bold,
        size: 34,
        relativeTo: .largeTitle
    )

    // MARK: - Titles
    static let title = Font.app(
        weight: .bold,
        size: 28,
        relativeTo: .title
    )

    static let title2 = Font.app(
        weight: .semibold,
        size: 22,
        relativeTo: .title2
    )

    static let title3 = Font.app(
        weight: .semibold,
        size: 20,
        relativeTo: .title3
    )

    // MARK: - Headline
    static let headline = Font.app(
        weight: .semibold,
        size: 17,
        relativeTo: .headline
    )

    // MARK: - Body
    static let body = Font.app(
        weight: .regular,
        size: 17,
        relativeTo: .body
    )

    static let callout = Font.app(
        weight: .regular,
        size: 16,
        relativeTo: .callout
    )

    static let subheadline = Font.app(
        weight: .regular,
        size: 15,
        relativeTo: .subheadline
    )

    // MARK: - Footnote
    static let footnote = Font.app(
        weight: .regular,
        size: 13,
        relativeTo: .footnote
    )

    // MARK: - Captions
    static let caption = Font.app(
        weight: .medium,
        size: 12,
        relativeTo: .caption
    )

    static let caption2 = Font.app(
        weight: .regular,
        size: 11,
        relativeTo: .caption2
    )
}
