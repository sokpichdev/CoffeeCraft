//
//  CoffeeToast.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 1/29/26.
//
import SwiftUI

struct CoffeeToast: View {
    let message: String
    let type: AlertType
    let duration: Double
    let onDismiss: () -> Void
    
    @State private var progress: CGFloat = 1.0
    @State private var offset: CGFloat = 0
    @State private var iconScale: CGFloat = 0
    @State private var iconRotation: Double = 0
    
    var body: some View {
        HStack(spacing: 12) {
            // Animated icon
            ZStack {
                Circle()
                    .fill(type.color.opacity(1))
                    .frame(width: 32, height: 32)
                
                Image(systemName: type.icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .scaleEffect(iconScale)
                    .rotationEffect(.degrees(iconRotation))
            }
            
            // Message
            Text(message)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.primary)
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            ZStack(alignment: .leading) {
                // Background
                RoundedRectangle(cornerRadius: 0)
                    .fill(.ultraThinMaterial)
                    .shadow(color: .black.opacity(0.1), radius: 12, y: 6)
                
                // Progress bar
                    RoundedRectangle(cornerRadius: 0)
                        .fill(
                            LinearGradient(
                                colors: [type.color.opacity(0.5), type.color.opacity(0.25)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: (UIScreen.main.bounds.width - 32)  * progress)
            }
        )
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .strokeBorder(type.color.opacity(0.3), lineWidth: 1)
        )
        .offset(x: offset)
        .gesture(
            DragGesture()
                .onChanged { gesture in
                    if gesture.translation.width < 0 {
                        offset = gesture.translation.width
                    }
                }
                .onEnded { gesture in
                    if gesture.translation.width < -100 {
                        dismissToast()
                    } else {
                        withAnimation(.spring(response: 0.3)) {
                            offset = 0
                        }
                    }
                }
        )
        .onAppear {
            triggerHaptic()
            animateAppearance()
            startProgressTimer()
        }
    }
    
    private func animateAppearance() {
        // Icon animations
        withAnimation(.spring(response: 0.4, dampingFraction: 0.6).delay(0.1)) {
            iconScale = 1.0
        }
    }
    
    private func startProgressTimer() {
        withAnimation(.linear(duration: duration)) {
            progress = 0
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            dismissToast()
        }
    }
    
    private func dismissToast() {
        withAnimation(.easeOut(duration: 0.25)) {
            offset = -400
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            onDismiss()
        }
    }
    
    private func triggerHaptic() {
        let generator = UIImpactFeedbackGenerator(style: type == .success ? .light : .medium)
        generator.impactOccurred()
    }
}
