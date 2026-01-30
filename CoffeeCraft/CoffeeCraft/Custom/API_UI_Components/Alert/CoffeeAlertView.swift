//
//  CoffeeAlertView.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 1/29/26.
//
import SwiftUI

struct CoffeeAlertView: View {
    var alertModel: AlertModel
    let onDismiss: () -> Void
    
    @State private var scale: CGFloat = 0.8
    @State private var opacity: Double = 0
    @State private var iconScale: CGFloat = 0
    
    var body: some View {
        ZStack {
            // Backdrop - tappable to dismiss
            Rectangle()
                .fill(.black.opacity(0.8))
                .ignoresSafeArea()
                .opacity(opacity)
                .onTapGesture {
                    dismissAlert()
                }
            
            // Alert content
            VStack(spacing: 20) {
                // Animated icon
                ZStack {
                    Circle()
                        .fill(alertModel.type.color.opacity(0.15))
                        .frame(width: 80, height: 80)
                    
                    Image(systemName: alertModel.type.icon)
                        .font(.system(size: 36))
                        .foregroundColor(alertModel.type.color)
                        .scaleEffect(iconScale)
                }
                .frame(height: 80)
                
                // Title
                Text(alertModel.title)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                // Message
                Text(alertModel.message)
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                
                // Action buttons
                if alertModel.hasTwoButtons {
                    twoButtonLayout
                } else {
                    singleButtonLayout
                }
            }
            .padding(28)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.2), radius: 30, y: 15)
            )
            .padding(.horizontal, 40)
            .scaleEffect(scale)
            .opacity(opacity)
        }
        .onAppear {
            triggerHaptic()
            animateAppearance()
            
            // Auto-dismiss for success alerts (only if single button)
            if alertModel.type == .success && !alertModel.hasTwoButtons {
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    dismissAlert()
                }
            }
        }
    }
    
    // MARK: - Button Layouts
    
    private var singleButtonLayout: some View {
        Button(action: dismissAlert) {
            Text("OK")
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    LinearGradient(
                        colors: [alertModel.type.color, alertModel.type.color.opacity(0.8)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(12)
                .shadow(color: alertModel.type.color.opacity(0.3), radius: 8, y: 4)
        }
    }
    
    private var twoButtonLayout: some View {
        HStack(spacing: 12) {
            // Secondary button (usually Cancel)
            if let secondaryAction = alertModel.secondaryAction {
                Button(action: {
                    secondaryAction.action()
                    if secondaryAction.style == .cancel {
                        dismissAlert()
                    }
                }) {
                    Text(secondaryAction.title)
                        .font(.headline)
                        .foregroundColor(secondaryAction.style.color)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(secondaryAction.style.color, lineWidth: 2)
                        )
                }
            }
            
            // Primary button (usually Confirm/Delete)
            if let primaryAction = alertModel.primaryAction {
                Button(action: {
                    primaryAction.action()
                }) {
                    Text(primaryAction.title)
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            LinearGradient(
                                colors: [
                                    primaryAction.style.color,
                                    primaryAction.style.color.opacity(0.8)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(12)
                        .shadow(color: primaryAction.style.color.opacity(0.3), radius: 8, y: 4)
                }
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func animateAppearance() {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
            scale = 1.0
            opacity = 1.0
        }
        
        withAnimation(.spring(response: 0.3, dampingFraction: 0.6).delay(0.2)) {
            iconScale = 1.0
        }
    }
    
    private func dismissAlert() {
        withAnimation(.easeOut(duration: 0.25)) {
            scale = 0.8
            opacity = 0
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            onDismiss()
        }
    }
    
    private func triggerHaptic() {
        let generator = UINotificationFeedbackGenerator()
        switch alertModel.type {
        case .success:
            generator.notificationOccurred(.success)
        case .warning:
            generator.notificationOccurred(.warning)
        case .error:
            generator.notificationOccurred(.error)
        }
    }
}
