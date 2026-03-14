//
//  DashboardComponents.swift
//  CoffeeCraft
//
//  Palette-aware shared components using semantic Color tokens.
//

import SwiftUI

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
