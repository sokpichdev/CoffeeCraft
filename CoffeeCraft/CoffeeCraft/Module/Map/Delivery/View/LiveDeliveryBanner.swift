//
//  LiveDeliveryBanner.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 15/03/2026.
//

import SwiftUI

// MARK: - LiveDeliveryBanner

struct LiveDeliveryBanner: View {

    let onTap: () -> Void

    @State private var isAnimating = false

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 10) {

                // Pulsing dot
                ZStack {
                    Circle()
                        .fill(Color.accentPrimary.opacity(isAnimating ? 0.25 : 0.0))
                        .frame(width: 28, height: 28)
                        .animation(.easeOut(duration: 1.0).repeatForever(autoreverses: false),
                                   value: isAnimating)

                    Circle()
                        .fill(Color.accentPrimary)
                        .frame(width: 10, height: 10)
                }

                Text("Rider on the way — tap to track")
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundColor(Color.accentPrimary)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(Color.accentPrimary.opacity(0.6))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 9)
            .background(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(Color.accentPrimary.opacity(0.08))
            )
        }
        .buttonStyle(BounceButtonStyle())
        .onAppear { isAnimating = true }
        .accessibilityLabel("Rider on the way. Tap to open live tracking.")
    }
}
