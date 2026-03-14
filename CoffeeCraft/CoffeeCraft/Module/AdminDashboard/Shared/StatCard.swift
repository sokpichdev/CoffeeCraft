//
//  StatCard.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 3/14/26.
//
import SwiftUI

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
