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
    
    func show(message: String, type: AlertType, duration: Double = 3.0) {
        let toast = ToastItem(message: message, type: type, duration: duration)
        
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            toasts.append(toast)
        }
    }
    
    func dismiss(id: UUID) {
        withAnimation(.easeOut(duration: 0.25)) {
            toasts.removeAll { $0.id == id }
        }
    }
}
