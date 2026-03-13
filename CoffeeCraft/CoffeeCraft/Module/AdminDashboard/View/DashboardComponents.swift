//
//  DashboardComponents.swift
//  CoffeeCraft
//
//  Palette-aware shared components for all Admin Dashboard screens.
//  Uses semantic Color tokens (Color.surfacePrimary, .textPrimary, etc.)
//  so every palette (Brown / Strawberry / Matcha / Oreo) and dark mode work
//  automatically without any hardcoded hex values.
//

import SwiftUI

// MARK: - Stat Card

/// 2-column metric card. Pass `tintBackground: true` for health-signal cards
/// (completion rate, cancellation rate) so the accent colour fills the background
/// — making green / orange / red immediately readable at a glance.
struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    var isLoading: Bool = false
    /// When true the card background is tinted with `color`. Use for status
    /// metrics where the colour IS the signal (cancellation rate, etc.).
    var tintBackground: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.subheadline)
                    .foregroundStyle(tintBackground ? color : color)
                Text(title)
                    .font(.caption)
                    .foregroundStyle(tintBackground ? color.opacity(0.85) : Color.textSecondary)
            }
            if isLoading {
                ShimmerView()
                    .frame(width: 80, height: 22)
                    .clipShape(RoundedRectangle(cornerRadius: 4))
            } else {
                Text(value)
                    .font(.title3.bold())
                    .foregroundStyle(tintBackground ? color : Color.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            tintBackground
                ? color.opacity(0.10)
                : Color.surfacePrimary,
            in: RoundedRectangle(cornerRadius: 14)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(color.opacity(tintBackground ? 0.30 : 0.15), lineWidth: 1)
        )
    }
}

// MARK: - Chart Card Container

/// Consistent card wrapper for every chart section across dashboard screens.
struct ChartCard<Content: View>: View {
    let title: String
    let subtitle: String
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(Color.textPrimary)
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(Color.textMuted)
            }
            content()
        }
        .padding(16)
        .background(Color.surfacePrimary, in: RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.borderColor, lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
    }
}

// MARK: - Dashboard Loading Placeholder

struct DashboardLoadingPlaceholder: View {
    var count: Int = 3

    var body: some View {
        VStack(spacing: 16) {
            ForEach(0..<count, id: \.self) { _ in
                ShimmerView()
                    .frame(maxWidth: .infinity)
                    .frame(height: 120)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            }
        }
    }
}

// MARK: - Dashboard Empty State

struct DashboardEmptyState: View {
    var icon: String = "chart.xyaxis.line"
    var title: String = "No data for this period"
    var message: String = "Place some orders to see analytics appear here."

    var body: some View {
        VStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(Color.accentPrimary.opacity(0.08))
                    .frame(width: 72, height: 72)
                Image(systemName: icon)
                    .font(.system(size: 30))
                    .foregroundStyle(Color.accentPrimary.opacity(0.5))
            }
            Text(title)
                .font(.headline)
                .foregroundStyle(Color.textSecondary)
            Text(message)
                .font(.subheadline)
                .foregroundStyle(Color.textMuted)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 52)
        .padding(.horizontal, 32)
    }
}
