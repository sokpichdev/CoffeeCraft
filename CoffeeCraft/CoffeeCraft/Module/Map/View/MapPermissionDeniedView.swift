//
//  MapPermissionDeniedView.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 06/03/2026.
//  Map Module — Phase 1: Basic Map Integration
//

import SwiftUI

// MARK: - MapPermissionDeniedView

struct MapPermissionDeniedView: View {

    var body: some View {
        ZStack {
            Color.bgPrimary.ignoresSafeArea()

            VStack(spacing: 0) {

                Spacer()

                // MARK: Icon
                ZStack {
                    Circle()
                        .fill(Color.accentPrimary.opacity(0.1))
                        .frame(width: 100, height: 100)

                    Image(systemName: "location.slash.fill")
                        .font(.system(size: 42, weight: .medium))
                        .foregroundStyle(.accentPrimary)
                }
                .padding(.bottom, 28)

                // MARK: Title
                Text("Location Access Needed")
                    .font(.custom("Nunito-Bold", size: 22))
                    .foregroundStyle(.textPrimary)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 12)

                // MARK: Description
                Text("CoffeeCraft uses your location to show\nnearby branches and deliver right to you.")
                    .font(.custom("Nunito-Regular", size: 15))
                    .foregroundStyle(.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, 40)
                    .padding(.bottom, 36)

                // MARK: Open Settings CTA
                Button(action: openAppSettings) {
                    HStack(spacing: 8) {
                        Image(systemName: "gear")
                            .font(.system(size: 15, weight: .semibold))
                        Text("Open Settings")
                            .font(.custom("Nunito-SemiBold", size: 16))
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(Color.accentPrimary)
                    .cornerRadius(14)
                    .padding(.horizontal, 40)
                }
                .accessibilityLabel("Open app settings to enable location access")

                Spacer()
                Spacer()
            }
        }
    }

    // MARK: - Helpers

    private func openAppSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }
}
