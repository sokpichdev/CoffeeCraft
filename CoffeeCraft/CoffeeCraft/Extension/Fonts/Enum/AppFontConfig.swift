//
//  AppFontConfig.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 2/3/26.
//

import SwiftUI
import UIKit

enum AppFontConfig {
    
    /// Change this ONE line to switch the entire app font
    static var primary: AppFont = .system
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
    case system
    case nokora
    case roboto
    case poppins
    case montserrat
    case nunito // body, button, text, Prices
    case playfairDisplay
    case libreBaskerville // Big Title, Header
    
    private var family: String {
        switch self {
        case .system: return ""
        case .nokora:      return "Nokora"
        case .roboto:      return "Roboto"
        case .poppins:     return "Poppins"
        case .montserrat:  return "Montserrat"
        case .nunito:      return "Nunito"
        case .playfairDisplay: return "PlayfairDisplay"
        case .libreBaskerville: return "LibreBaskerville"
        }
    }
    
    func name(for weight: AppFontWeight) -> String {
        "\(family)-\(weight.suffix)"
    }
}
