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
        case .success: return .leafGreen
        case .warning: return .warningAmber
        case .error: return .errorRed
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
            case .default: return .blue
            case .cancel: return .gray
            case .destructive: return .red
            }
        }
    }
    
    init(title: String, style: ActionStyle = .default, action: @escaping () -> Void = {}) {
        self.title = title
        self.style = style
        self.action = action
    }
}

struct AlertModel {
    let type: AlertType = .success
    let title: String = ""
    let message: String = ""
    let primaryAction: AlertAction?
    let secondaryAction: AlertAction?
    
    // Single button initializer (existing behavior)
    init(type: AlertType = .success, title: String = "", message: String = "") {
        self.primaryAction = nil
        self.secondaryAction = nil
    }
    
    // Two button initializer
    init(type: AlertType = .success,
         title: String = "",
         message: String = "",
         primaryAction: AlertAction,
         secondaryAction: AlertAction) {
        self.primaryAction = primaryAction
        self.secondaryAction = secondaryAction
    }
    
    var hasTwoButtons: Bool {
        primaryAction != nil && secondaryAction != nil
    }
}
