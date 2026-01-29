//
//  CoffeeAlert.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 1/29/26.
//
import SwiftUI

struct CoffeeAlert: View {
    let title: String
    let message: String
    let type: AlertType
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
                        .fill(type.color.opacity(0.15))
                        .frame(width: 80, height: 80)
                    
                    Image(systemName: type.icon)
                        .font(.system(size: 36))
                        .foregroundColor(type.color)
                        .scaleEffect(iconScale)
                }
                .frame(height: 80)
                
                // Title
                Text(title)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                // Message
                Text(message)
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
                                colors: [type.color, type.color.opacity(0.8)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(12)
                        .shadow(color: type.color.opacity(0.3), radius: 8, y: 4)
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
            if type == .success {
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
        switch type {
        case .success:
            generator.notificationOccurred(.success)
        case .warning:
            generator.notificationOccurred(.warning)
        case .error:
            generator.notificationOccurred(.error)
        }
    }
}

struct AnimatedCheckmark: View {
    let progress: CGFloat
    let color: Color
    
    var body: some View {
        Canvas { context, size in
            let path = Path { p in
                // Draw checkmark path
                p.move(to: CGPoint(x: size.width * 0.2, y: size.height * 0.5))
                p.addLine(to: CGPoint(x: size.width * 0.4, y: size.height * 0.7))
                p.addLine(to: CGPoint(x: size.width * 0.8, y: size.height * 0.25))
            }
            
            let trimmedPath = path.trimmedPath(from: 0, to: progress)
            
            context.stroke(
                trimmedPath,
                with: .color(color),
                style: StrokeStyle(lineWidth: 4, lineCap: .round, lineJoin: .round)
            )
        }
    }
}
