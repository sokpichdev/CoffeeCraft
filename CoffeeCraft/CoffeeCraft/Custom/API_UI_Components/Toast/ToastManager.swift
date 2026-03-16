//
//  ToastManager.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 2/2/26.
//
import SwiftUI

@MainActor
class ToastManager: ObservableObject {
    static let shared = ToastManager()
    
    @Published var toasts: [ToastItem] = []
    
    // Show toast at specified position
    func show(message: String, type: AlertType, duration: Double = 1.0, position: ToastPosition = .bottom) {
        let toast = ToastItem(message: message, type: type, duration: duration, position: position)
        
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            toasts.append(toast)
        }
    }
    
    // Convenience methods for specific positions
    func showTop(message: String, type: AlertType, duration: Double = 1.0) {
        show(message: message, type: type, duration: duration, position: .top)
    }
    
    func showBottom(message: String, type: AlertType, duration: Double = 1.0) {
        show(message: message, type: type, duration: duration, position: .bottom)
    }
    
    func dismiss(id: UUID) {
        withAnimation(.easeOut(duration: 0.25)) {
            toasts.removeAll { $0.id == id }
        }
    }
}
