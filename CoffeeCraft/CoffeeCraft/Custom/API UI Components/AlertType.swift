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

struct AlertModel: Identifiable {
    let id = UUID()
    var type: AlertType = .success
    var title: String = ""
    var message: String = ""
}

func successAlert(title: String, message: String) -> AlertModel {
    AlertModel(type: .success, title: title, message: message)
}

func errorAlert(title: String, message: String) -> AlertModel {
    AlertModel(type: .error, title: title, message: message)
}
