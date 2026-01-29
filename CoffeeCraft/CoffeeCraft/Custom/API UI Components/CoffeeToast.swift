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
    @State private var checkmarkProgress: CGFloat = 0
    
    var body: some View {
        HStack(spacing: 12) {
            // Animated icon
            ZStack {
                Circle()
                    .fill(type.color.opacity(0.2))
                    .frame(width: 32, height: 32)
                
                if type == .success {
                    AnimatedCheckmark(progress: checkmarkProgress, color: type.color)
                        .frame(width: 16, height: 16)
                } else {
                    Image(systemName: type.icon)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(type.color)
                        .scaleEffect(iconScale)
                        .rotationEffect(.degrees(iconRotation))
                }
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
                RoundedRectangle(cornerRadius: 16)
                    .fill(.ultraThinMaterial)
                    .shadow(color: .black.opacity(0.1), radius: 12, y: 6)
                
                // Progress bar
                GeometryReader { geo in
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            LinearGradient(
                                colors: [type.color.opacity(0.3), type.color.opacity(0.1)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geo.size.width * progress)
                }
            }
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
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
        if type == .success {
            withAnimation(.easeOut(duration: 0.5).delay(0.1)) {
                checkmarkProgress = 1.0
            }
        } else if type == .error {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.5).delay(0.1)) {
                iconScale = 1.0
                iconRotation = 360
            }
        } else {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.6).delay(0.1)) {
                iconScale = 1.0
            }
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

// Toast Manager for stacking multiple toasts
class ToastManager: ObservableObject {
    @Published var toasts: [ToastItem] = []
    
    func show(message: String, type: AlertType, duration: Double = 3.0) {
        let toast = ToastItem(message: message, type: type, duration: duration)
        
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            toasts.append(toast)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            self.dismiss(id: toast.id)
        }
    }
    
    func dismiss(id: UUID) {
        withAnimation(.easeOut(duration: 0.25)) {
            toasts.removeAll { $0.id == id }
        }
    }
}

struct ToastItem: Identifiable {
    let id = UUID()
    let message: String
    let type: AlertType
    let duration: Double
}

// View modifier for easy toast presentation
struct ToastModifier: ViewModifier {
    @ObservedObject var manager: ToastManager
    
    func body(content: Content) -> some View {
        content
            .overlay(alignment: .bottom) {
                VStack(spacing: 12) {
                    ForEach(manager.toasts) { toast in
                        CoffeeToast(
                            message: toast.message,
                            type: toast.type,
                            duration: toast.duration
                        ) {
                            manager.dismiss(id: toast.id)
                        }
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 24)
            }
    }
}

extension View {
    func toastView(manager: ToastManager) -> some View {
        modifier(ToastModifier(manager: manager))
    }
}
