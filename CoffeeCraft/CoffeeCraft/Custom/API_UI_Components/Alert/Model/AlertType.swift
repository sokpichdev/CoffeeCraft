//
//  AlertType.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 1/29/26.
//
import SwiftUI

enum AlertType {
    case success, warning, error

    var icon: String {
        switch self {
        case .success: return "checkmark.circle.fill"
        case .warning: return "exclamationmark.triangle.fill"
        case .error: return "xmark.circle.fill"
        }
    }

    var color: Color {
        switch self {
        case .success: return .semanticSuccess
        case .warning: return .semanticWarning
        case .error: return .semanticError
        }
    }
    
    var gradientColors: [Color] {
        switch self {
        case .success: return [Color(red: 0.4, green: 0.7, blue: 0.4), Color(red: 0.35, green: 0.6, blue: 0.35)]
        case .error: return [Color(red: 0.8, green: 0.3, blue: 0.2), Color(red: 0.7, green: 0.25, blue: 0.15)]
        case .warning: return [Color(red: 0.9, green: 0.6, blue: 0.3), Color(red: 0.8, green: 0.5, blue: 0.25)]
        }
    }
}

struct AlertAction {
    let title: String

    let style: ActionStyle
    let action: () -> Void
    
    enum ActionStyle {
        case `default`
        case cancel
        case destructive
        
        var color: Color {
            switch self {
            case .default: return .accentPrimary
            case .cancel: return .accentPrimary.opacity(0.6)
            case .destructive: return Color(red: 0.8, green: 0.3, blue: 0.2) // Coffee-toned red
            }
        }
        
        var gradientColors: [Color] {
            switch self {
            case .default: return [.accentPrimary, .accentPrimary.opacity(0.6)]
            case .cancel: return [.surfaceSub.opacity(0.8), .surfaceSub.opacity(0.6)]
            case .destructive: return [Color(red: 0.8, green: 0.3, blue: 0.2), Color(red: 0.7, green: 0.25, blue: 0.15)]
            }
        }
        
        var foregroundColor: Color {
            switch self {
            case .default: return .white
            case .cancel: return .accentPrimary
            case .destructive: return .white
            }
        }
    }
    
    init(title: String = "", style: ActionStyle = .default, action: @escaping () -> Void = {}) {
        self.title = title
        self.style = style
        self.action = action
    }
}

struct AlertModel {
    let type: AlertType
    let title: String
    let message: String
    let primaryAction: AlertAction?
    let secondaryAction: AlertAction?
    
    // Single button / no-action initializer
    init(type: AlertType, title: String, message: String) {
        self.type = type
        self.title = title
        self.message = message
        self.primaryAction = nil
        self.secondaryAction = nil
    }
    
    // Two-button initializer
    init(
        type: AlertType,
        title: String,
        message: String,
        primaryAction: AlertAction,
        secondaryAction: AlertAction
    ) {
        self.type = type
        self.title = title
        self.message = message
        self.primaryAction = primaryAction
        self.secondaryAction = secondaryAction
    }
    
    var hasTwoButtons: Bool {
        primaryAction != nil && secondaryAction != nil
    }
}
