//
//  PickupReadyBanner.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 15/03/2026.
//
//  Order Module — Pickup Flow
//  Shown in OrderDetailView when a pickup order reaches "Ready" status.
//  Pulses to draw attention and offers a one-tap Directions button.
//

import SwiftUI

// MARK: - PickupReadyBanner

struct PickupReadyBanner: View {

    let branchName:  String
    let onDirections: () -> Void

    @State private var isPulsing = false

    var body: some View {
        VStack(spacing: 12) {

            // ── Header ──────────────────────────────────────────────
            HStack(spacing: 12) {
                // Pulsing checkmark
                ZStack {
                    Circle()
                        .fill(Color.semanticSuccess.opacity(isPulsing ? 0.22 : 0.10))
                        .frame(width: 48, height: 48)
                        .animation(
                            .easeInOut(duration: 1.2).repeatForever(autoreverses: true),
                            value: isPulsing
                        )
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 26, weight: .semibold))
                        .foregroundColor(Color.semanticSuccess)
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text("Your order is ready!")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(Color.textPrimary)
                    Text("Head to \(branchName) to collect")
                        .font(.system(size: 13))
                        .foregroundColor(Color.textSecondary)
                        .lineLimit(1)
                }

                Spacer()
            }

            // ── Directions button ────────────────────────────────────
            Button(action: onDirections) {
                HStack(spacing: 8) {
                    Image(systemName: "map.fill")
                        .font(.system(size: 14, weight: .semibold))
                    Text("Get Directions")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                }
                .foregroundColor(Color.semanticSuccess)
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color.semanticSuccess.opacity(0.12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .strokeBorder(Color.semanticSuccess.opacity(0.35), lineWidth: 1.5)
                        )
                )
            }
            .buttonStyle(BounceButtonStyle())
            .accessibilityLabel("Get directions to \(branchName)")
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.surfacePrimary)
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .strokeBorder(Color.semanticSuccess.opacity(0.3), lineWidth: 1)
                )
                .shadow(color: Color.semanticSuccess.opacity(0.10), radius: 8, x: 0, y: 3)
        )
        .onAppear { isPulsing = true }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Your order is ready for pickup at \(branchName). Double tap to get directions.")
    }
}
