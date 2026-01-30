//
//  AlertManager.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 1/30/26.
//

import SwiftUI

@MainActor
class AlertManager: ObservableObject {
    static let shared = AlertManager()
    
    @Published var showAlert = false
    @Published var currentAlert: AlertModel?
    
    private init() {}
    
    // Show alert with custom message (single button)
    func show(title: String, message: String, type: AlertType) {
        currentAlert = AlertModel(type: type, title: title, message: message)
        showAlert = true
    }
    
    // Show alert with two buttons
    func show(title: String, 
              message: String, 
              type: AlertType,
              primaryAction: AlertAction,
              secondaryAction: AlertAction) {
        currentAlert = AlertModel(
            type: type,
            title: title,
            message: message,
            primaryAction: primaryAction,
            secondaryAction: secondaryAction
        )
        showAlert = true
    }
    
    // Convenience methods for single button alerts
    func showSuccess(title: String = "Success", message: String) {
        show(title: title, message: message, type: .success)
    }
    
    func showError(title: String = "Error", message: String) {
        show(title: title, message: message, type: .error)
    }
    
    func showWarning(title: String = "Warning", message: String) {
        show(title: title, message: message, type: .warning)
    }
    
    // Convenience methods for two button alerts
    func showConfirmation(title: String,
                         message: String,
                         type: AlertType = .warning,
                         confirmTitle: String = "Confirm",
                         cancelTitle: String = "Cancel",
                         onConfirm: @escaping () -> Void) {
        let confirmAction = AlertAction(title: confirmTitle, style: .default) {
            onConfirm()
            self.dismiss()
        }
        let cancelAction = AlertAction(title: cancelTitle, style: .cancel) {
            self.dismiss()
        }
        
        show(title: title, message: message, type: type, primaryAction: confirmAction, secondaryAction: cancelAction)
    }
    
    func showDestructive(title: String,
                        message: String,
                        destructiveTitle: String = "Delete",
                        cancelTitle: String = "Cancel",
                        onDestructive: @escaping () -> Void) {
        let destructiveAction = AlertAction(title: destructiveTitle, style: .destructive) {
            onDestructive()
            self.dismiss()
        }
        let cancelAction = AlertAction(title: cancelTitle, style: .cancel) {
            self.dismiss()
        }
        
        show(title: title, message: message, type: .error, primaryAction: destructiveAction, secondaryAction: cancelAction)
    }
    
    func dismiss() {
        showAlert = false
        currentAlert = nil
    }
}
