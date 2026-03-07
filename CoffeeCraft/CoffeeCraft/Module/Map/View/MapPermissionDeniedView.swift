//
//  MapPermissionDeniedView.swift
//  CoffeeCraft
//
//  Map Module — UI Enhanced
//  Apple-style: ambient mesh background, animated icon ring, warm coffee tones.
//

import SwiftUI

// MARK: - MapPermissionDeniedView

struct MapPermissionDeniedView: View {

    @State private var ringScale: CGFloat = 1.0
    @State private var ringOpacity: Double = 0.15
    @State private var appeared = false

    var body: some View {
        ZStack {
            // ── Ambient background ──────────────────────────────────
            Color.bgPrimary.ignoresSafeArea()

            // Subtle warm radial glow behind icon
            RadialGradient(
                colors: [Color.accentPrimary.opacity(0.12), Color.clear],
                center: .center,
                startRadius: 20,
                endRadius: 240
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                // ── Animated Icon ───────────────────────────────────
                ZStack {
                    // Pulsing ring
                    Circle()
                        .strokeBorder(Color.accentPrimary.opacity(ringOpacity), lineWidth: 1.5)
                        .frame(width: 112, height: 112)
                        .scaleEffect(ringScale)

                    // Filled backing circle
                    Circle()
                        .fill(Color.accentPrimary.opacity(0.1))
                        .frame(width: 88, height: 88)

                    Image(systemName: "location.slash.fill")
                        .font(.system(size: 38, weight: .medium))
                        .foregroundColor(Color.accentPrimary)
                        .symbolRenderingMode(.hierarchical)
                }
                .offset(y: appeared ? 0 : 16)
                .opacity(appeared ? 1 : 0)
                .padding(.bottom, 32)

                // ── Title ───────────────────────────────────────────
                Text("Location Access Needed")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundColor(Color.textPrimary)
                    .multilineTextAlignment(.center)
                    .offset(y: appeared ? 0 : 10)
                    .opacity(appeared ? 1 : 0)
                    .padding(.bottom, 10)

                // ── Description ─────────────────────────────────────
                Text("CoffeeCraft uses your location to show\nnearby branches and deliver right to you.")
                    .font(.system(size: 15, weight: .regular))
                    .foregroundColor(Color.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, 44)
                    .offset(y: appeared ? 0 : 8)
                    .opacity(appeared ? 1 : 0)
                    .padding(.bottom, 40)

                // ── CTA Button ──────────────────────────────────────
                Button(action: openAppSettings) {
                    HStack(spacing: 8) {
                        Image(systemName: "gear")
                            .font(.system(size: 15, weight: .semibold))
                        Text("Open Settings")
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(Color.accentPrimary)
                            .shadow(color: Color.accentPrimary.opacity(0.4), radius: 14, x: 0, y: 6)
                    )
                    .padding(.horizontal, 40)
                }
                .buttonStyle(BounceButtonStyle())
                .offset(y: appeared ? 0 : 8)
                .opacity(appeared ? 1 : 0)
                .accessibilityLabel("Open app settings to enable location access")

                Spacer()
                Spacer()
            }
        }
        .onAppear {
            // Staggered entrance
            withAnimation(.spring(response: 0.6, dampingFraction: 0.75).delay(0.05)) {
                appeared = true
            }
            // Pulsing ring loop
            withAnimation(
                .easeInOut(duration: 1.8)
                .repeatForever(autoreverses: true)
                .delay(0.5)
            ) {
                ringScale = 1.18
                ringOpacity = 0.0
            }
        }
    }

    // MARK: - Helpers

    private func openAppSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }
}
