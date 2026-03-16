//
//  RiderAnnotationView.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 15/03/2026.
//

import SwiftUI

// MARK: - RiderAnnotationView

struct RiderAnnotationView: View {

    let status: DeliveryStatus
    let bearing: CLLocationDirection  // 0–360°

    @State private var isPulsing    = false
    @State private var didBounce    = false
    @State private var bounceOffset: CGFloat = 0

    private let pinSize: CGFloat = 46

    var body: some View {
        ZStack {
            // ── Pulsing glow ring (en-route only) ──────────────────
            if isMoving {
                Circle()
                    .fill(Color.accentPrimary.opacity(isPulsing ? 0.18 : 0.05))
                    .frame(width: pinSize + 28, height: pinSize + 28)
                    .animation(
                        .easeInOut(duration: 1.4).repeatForever(autoreverses: true),
                        value: isPulsing
                    )
            }

            // ── Pin bubble ──────────────────────────────────────────
            Circle()
                .fill(pinFill)
                .frame(width: pinSize, height: pinSize)
                .shadow(
                    color: shadowColor,
                    radius: isMoving ? 14 : 6,
                    x: 0, y: isMoving ? 6 : 2
                )
                .overlay {
                    Circle()
                        .strokeBorder(Color.white.opacity(0.5), lineWidth: 1.5)
                }

            // ── Icon ────────────────────────────────────────────────
            Image(systemName: iconName)
                .font(.system(size: iconSize, weight: .semibold))
                .foregroundColor(.white)
                .symbolRenderingMode(.hierarchical)
                // Rotate to face direction of travel
                .rotationEffect(.degrees(bearing))
                .animation(.linear(duration: 1.8), value: bearing)
        }
        .offset(y: bounceOffset)
        .scaleEffect(didBounce ? 1.18 : 1.0)
        .animation(.spring(response: 0.4, dampingFraction: 0.55), value: didBounce)
        .onChange(of: status) { _, newStatus in
            if newStatus == .riderAssigned {
                bounceIn()
            }
        }
        .onAppear {
            if isMoving { isPulsing = true }
        }
        .onChange(of: isMoving) { _, moving in
            isPulsing = moving
        }
        .accessibilityLabel(accessibilityLabel)
        .accessibilityHidden(false)
    }

    // MARK: - Computed Appearance

    private var isMoving: Bool {
        status == .enRoute || status == .arriving
    }

    private var pinFill: Color {
        switch status {
        case .delivered:     return Color.semanticSuccess
        case .arriving:      return Color.accentPrimary
        default:             return Color.accentPrimary
        }
    }

    private var shadowColor: Color {
        isMoving
            ? Color.accentPrimary.opacity(0.45)
            : Color.black.opacity(0.18)
    }

    private var iconName: String {
        switch status {
        case .delivered:  return "checkmark.circle.fill"
        case .arriving:   return "bicycle"
        default:          return "bicycle"
        }
    }

    private var iconSize: CGFloat {
        status == .delivered ? 20 : 22
    }

    private var accessibilityLabel: String {
        "Delivery rider, \(status.label)"
    }

    // MARK: - Bounce Animation

    private func bounceIn() {
        didBounce    = true
        bounceOffset = -12
        withAnimation(.spring(response: 0.5, dampingFraction: 0.45)) {
            bounceOffset = 0
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.55) {
            didBounce = false
        }
    }
}

// MARK: - CLLocationDirection import shim
// CLLocationDirection is a typealias for Double in CoreLocation.
// We import CoreLocation only here so the annotation view stays pure SwiftUI.
import CoreLocation
