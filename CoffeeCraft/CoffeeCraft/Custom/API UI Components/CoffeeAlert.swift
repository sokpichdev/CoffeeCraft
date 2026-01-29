//
//  CoffeeAlert.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 1/29/26.
//
import SwiftUI

struct CoffeeAlert: View {
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
                // Close button
                HStack {
                    Spacer()
                    Button(action: dismissAlert) {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.secondary)
                            .padding(8)
                            .background(Color.gray.opacity(0.1))
                            .clipShape(Circle())
                    }
                }
                
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
                
                // Action button
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
            
            // Auto-dismiss for success alerts
            if alertModel.type == .success {
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    dismissAlert()
                }
            }
        }
    }
    
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

extension View {
    func alertView(showAlert: Binding<Bool>, alert: AlertModel) -> some View {
        ZStack {
            self
            
            if showAlert.wrappedValue {
                CoffeeAlert(alertModel: alert) {
                    showAlert.wrappedValue = false
                }
                .transition(.opacity)
            }
        }
    }
}
