//
//  KPICard.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 3/12/26.
//

import SwiftUI

// MARK: - KPI Card

/// A reusable metric card for the admin dashboard.
///
/// Usage:
/// ```swift
/// KPICard(
///     title: "Revenue Today",
///     value: "$128.50",
///     icon: "dollarsign.circle.fill",
///     accentColor: .green
/// )
/// ```
struct KPICard: View {

    let title: String
    let value: String
    let icon: String
    let accentColor: Color
    var subtitle: String? = nil
    var subtitleIsPositive: Bool? = nil     // nil = neutral (no color)
    var isLoading: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {

            // Header row: icon + title
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.subheadline)
                    .foregroundStyle(accentColor)
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            // Main value
            if isLoading {
                ShimmerView()
                    .frame(width: 90, height: 24)
                    .clipShape(RoundedRectangle(cornerRadius: 4))
            } else {
                Text(value)
                    .font(.title2.bold())
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }

            // Optional subtitle (e.g. change %)
            if let subtitle {
                if isLoading {
                    ShimmerView()
                        .frame(width: 60, height: 14)
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                } else {
                    Text(subtitle)
                        .font(.caption2)
                        .foregroundStyle(subtitleColor)
                }
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(accentColor.opacity(0.15), lineWidth: 1)
        )
    }

    // MARK: - Private

    private var subtitleColor: Color {
        guard let isPositive = subtitleIsPositive else { return .secondary }
        return isPositive ? .green : .red
    }
}

// MARK: - Live Badge

/// Small pulsing dot used next to "Active Orders" to indicate real-time data.
struct LiveBadge: View {
    @State private var pulse = false

    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(.green)
                .frame(width: 7, height: 7)
                .scaleEffect(pulse ? 1.4 : 1.0)
                .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: pulse)
                .onAppear { pulse = true }
            Text("LIVE")
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(.green)
        }
        .padding(.horizontal, 7)
        .padding(.vertical, 3)
        .background(.green.opacity(0.12), in: Capsule())
    }
}
