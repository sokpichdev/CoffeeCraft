//
//  TrackDeliveryButton.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 15/03/2026.
//

import SwiftUI

// MARK: - TrackDeliveryButton

struct TrackDeliveryButton: View {

    let onTap: () -> Void

    @State private var isPulsing = false

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 14) {

                // Animated rider icon
                ZStack {
                    Circle()
                        .fill(Color.accentPrimary.opacity(isPulsing ? 0.22 : 0.12))
                        .frame(width: 48, height: 48)
                        .animation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true),
                                   value: isPulsing)

                    Image(systemName: "bicycle")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(Color.accentPrimary)
                }

                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 6) {
                        Text("Track Delivery")
                            .font(.system(size: 15, weight: .bold, design: .rounded))
                            .foregroundColor(Color.textPrimary)

                        // Live badge
                        HStack(spacing: 4) {
                            Circle()
                                .fill(Color.semanticSuccess)
                                .frame(width: 6, height: 6)
                            Text("LIVE")
                                .font(.system(size: 9, weight: .black, design: .rounded))
                                .foregroundColor(Color.semanticSuccess)
                        }
                        .padding(.horizontal, 7)
                        .padding(.vertical, 3)
                        .background(Capsule().fill(Color.semanticSuccess.opacity(0.12)))
                    }

                    Text("Your rider is on the way")
                        .font(.system(size: 12))
                        .foregroundColor(Color.textMuted)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color.textMuted)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color.surfacePrimary)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .strokeBorder(Color.accentPrimary.opacity(0.25), lineWidth: 1)
                    )
                    .shadow(color: Color.accentPrimary.opacity(0.08), radius: 8, x: 0, y: 3)
            )
        }
        .buttonStyle(BounceButtonStyle())
        .onAppear { isPulsing = true }
        .accessibilityLabel("Track your delivery — live")
        .accessibilityHint("Double tap to open the live delivery map")
    }
}
