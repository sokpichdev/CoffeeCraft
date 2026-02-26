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
            
            VStack(spacing: 20) {
                ZStack {
                    Circle()
                        .fill(alertModel.type.color.opacity(0.15))
                        .frame(width: 80, height: 80)
                    
                    Image(systemName: alertModel.type.icon)
                        .font(.largeTitle)
                        .foregroundColor(alertModel.type.color)
                        .scaleEffect(iconScale)
                }
                .frame(height: 80)
                
                if alertModel.title != "" {
                    Text(alertModel.title)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                }
                
                if alertModel.message != "" {
                    Text(alertModel.message)
                        .font(.subheadline)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                
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
        CustomCoffeeButton(title: "OK", bgColors: alertModel.type.gradientColors) {
            dismissAlert()
        }
        .shadow(color: alertModel.type.color.opacity(0.3), radius: 8, y: 4)
    }
    
    private var twoButtonLayout: some View {
        HStack(spacing: 12) {
            // Secondary button (usually Cancel)
            if let secondaryAction = alertModel.secondaryAction {
                CustomCoffeeButton(
                    title: secondaryAction.title,
                    foregroundColor: secondaryAction.style.foregroundColor,
                    bgColors: secondaryAction.style.gradientColors
                ) {
                    secondaryAction.action()
                    if secondaryAction.style == .cancel {
                        dismissAlert()
                    }
                }
                .shadow(color: secondaryAction.style.color.opacity(0.2), radius: 6, y: 3)
            }
            
            // Primary button (usually Confirm/Delete)
            if let primaryAction = alertModel.primaryAction {
                CustomCoffeeButton(
                    title: primaryAction.title,
                    foregroundColor: primaryAction.style.foregroundColor,
                    bgColors: primaryAction.style.gradientColors
                ) {
                    primaryAction.action()
                }
                .shadow(color: primaryAction.style.color.opacity(0.3), radius: 8, y: 4)
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
