//
//  OfflineBannerModifier.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 3/11/26.
//
//  A non-intrusive top banner that appears whenever NetworkMonitor.shared
//  reports no connectivity. It slides in from the top and slides back out
//  the moment the connection is restored — no user interaction required.
//
//  USAGE (apply once at the root of the app):
//
//      VStack { ... }
//          .offlineBanner()
//
//  The modifier sits above the existing alert-based offline warning in
//  RootView. Both can coexist: the alert fires once on connectivity change,
//  the banner stays visible for the entire offline duration.
//

import SwiftUI

// MARK: - OfflineBannerModifier

private struct OfflineBannerModifier: ViewModifier {

    @ObservedObject private var network = NetworkMonitor.shared

    func body(content: Content) -> some View {
        ZStack(alignment: .top) {
            content

            if !network.isConnected {
                OfflineBanner()
                    .transition(
                        .asymmetric(
                            insertion: .move(edge: .top).combined(with: .opacity),
                            removal: .move(edge: .top).combined(with: .opacity)
                        )
                    )
                    .zIndex(999)
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: network.isConnected)
    }
}

// MARK: - OfflineBanner (private view)

private struct OfflineBanner: View {

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "wifi.slash")
                .font(.system(size: 13, weight: .semibold))

            Text("You're offline — showing cached data")
                .font(.system(size: 13, weight: .medium))
                .lineLimit(1)

            Spacer(minLength: 0)
        }
        .foregroundColor(.white)
        .padding(.horizontal, 16)
        .padding(.vertical, 9)
        .background(
            Color.orange
                .ignoresSafeArea(edges: .top)    // fills the notch area on modern devices
        )
    }
}

// MARK: - View extension

extension View {
    /// Overlays a persistent offline banner whenever the device has no internet.
    func offlineBanner() -> some View {
        modifier(OfflineBannerModifier())
    }
}
