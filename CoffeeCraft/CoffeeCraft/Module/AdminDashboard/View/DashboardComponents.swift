//
//  DashboardComponents.swift
//  CoffeeCraft
//
//  Palette-aware shared components using semantic Color tokens.
//

import SwiftUI

// MARK: - Stat Card

/// Metric card with optional tinted background for health-signal metrics.
struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    var isLoading: Bool = false
    var tintBackground: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {

            // Icon row
            HStack(spacing: 7) {
                ZStack {
                    Circle()
                        .fill((tintBackground ? color : Color.accentPrimary).opacity(0.12))
                        .frame(width: 30, height: 30)
                    Image(systemName: icon)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(tintBackground ? color : Color.accentPrimary)
                }
                Text(title)
                    .font(.caption.weight(.medium))
                    .foregroundStyle(tintBackground ? color.opacity(0.85) : Color.textSecondary)
                    .lineLimit(1)
            }

            // Value
            if isLoading {
                ShimmerView()
                    .frame(width: 80, height: 22)
                    .clipShape(RoundedRectangle(cornerRadius: 4))
            } else {
                Text(value)
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundStyle(tintBackground ? color : Color.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            tintBackground
                ? color.opacity(0.09)
                : Color.surfacePrimary,
            in: RoundedRectangle(cornerRadius: 14)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(color.opacity(tintBackground ? 0.28 : 0.14), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.03), radius: 6, x: 0, y: 2)
    }
}

// MARK: - Chart Card Container

/// Consistent card wrapper for all chart sections.
struct ChartCard<Content: View>: View {
    let title: String
    let subtitle: String
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Header
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(Color.textPrimary)
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(Color.textMuted)
                }
                Spacer()
            }

            Divider()
                .background(Color.borderColor)

            content()
        }
        .padding(16)
        .background(Color.surfacePrimary, in: RoundedRectangle(cornerRadius: 18))
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(Color.borderColor, lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.04), radius: 10, x: 0, y: 3)
    }
}

// MARK: - Section Header Label

struct SectionHeaderLabel: View {
    let icon: String
    let title: String

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(Color.accentPrimary)
                .frame(width: 26, height: 26)
                .background(Color.accentPrimary.opacity(0.10), in: RoundedRectangle(cornerRadius: 7))
            Text(title)
                .font(.headline.weight(.semibold))
                .foregroundStyle(Color.textPrimary)
        }
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
    var icon: String  = "chart.xyaxis.line"
    var title: String = "No data for this period"
    var message: String = "Place some orders to see analytics appear here."

    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.accentPrimary.opacity(0.07))
                    .frame(width: 80, height: 80)
                Circle()
                    .fill(Color.accentPrimary.opacity(0.04))
                    .frame(width: 60, height: 60)
                Image(systemName: icon)
                    .font(.system(size: 28))
                    .foregroundStyle(Color.accentPrimary.opacity(0.45))
            }
            Text(title)
                .font(.headline.weight(.semibold))
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
