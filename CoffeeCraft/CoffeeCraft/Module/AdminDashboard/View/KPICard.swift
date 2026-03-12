//
//  KPICard.swift
//  CoffeeCraft
//

import SwiftUI

// MARK: - KPI Card

struct KPICard: View {

    let title: String
    let value: String
    let icon: String
    let accentColor: Color
    var subtitle: String? = nil
    var subtitleIsPositive: Bool?  = nil
    var isLoading: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {

            // Icon chip
            HStack(spacing: 6) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(accentColor.opacity(0.14))
                        .frame(width: 30, height: 30)
                    Image(systemName: icon)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(accentColor)
                }
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.textSecondary)
                    .lineLimit(1)
            }

            // Value
            if isLoading {
                ShimmerView()
                    .frame(width: 88, height: 26)
                    .clipShape(RoundedRectangle(cornerRadius: 4))
            } else {
                Text(value)
                    .font(.title2.bold())
                    .foregroundColor(.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }

            // Subtitle
            if let subtitle {
                if isLoading {
                    ShimmerView()
                        .frame(width: 64, height: 12)
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                } else {
                    HStack(spacing: 3) {
                        if let isPositive = subtitleIsPositive {
                            Image(systemName: isPositive ? "arrow.up.right" : "arrow.down.right")
                                .font(.system(size: 9, weight: .bold))
                                .foregroundColor(isPositive ? Color.semanticSuccess : Color.semanticError)
                        }
                        Text(subtitle)
                            .font(.caption2)
                            .foregroundColor(subtitleColor)
                    }
                }
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.surfacePrimary)
                .shadow(color: Color.black.opacity(0.05), radius: 6, x: 0, y: 2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(accentColor.opacity(0.18), lineWidth: 1)
        )
    }

    private var subtitleColor: Color {
        guard let isPositive = subtitleIsPositive else { return .textMuted }
        return isPositive ? .semanticSuccess : .semanticError
    }
}

// MARK: - Live Badge

struct LiveBadge: View {
    @State private var pulse = false

    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(Color.semanticSuccess)
                .frame(width: 7, height: 7)
                .scaleEffect(pulse ? 1.45 : 1.0)
                .animation(
                    .easeInOut(duration: 0.85).repeatForever(autoreverses: true),
                    value: pulse
                )
                .onAppear { pulse = true }
            Text("LIVE")
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(Color.semanticSuccess)
                .tracking(0.5)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color.semanticSuccess.opacity(0.12), in: Capsule())
    }
}

// MARK: - Revenue Stat Row

/// Used inside the period revenue card to show a comparison stat.
struct RevenueStatRow: View {
    let label: String
    let value: String
    let color: Color

    var body: some View {
        HStack {
            Circle()
                .fill(color.opacity(0.8))
                .frame(width: 8, height: 8)
            Text(label)
                .font(.caption)
                .foregroundColor(.textSecondary)
            Spacer()
            Text(value)
                .font(.caption.bold())
                .foregroundColor(.textPrimary)
        }
    }
}
