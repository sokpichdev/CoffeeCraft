//
//  DashboardComponents.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 3/12/26.
//
//  Shared UI components used across multiple admin dashboard screens.
//  Extracted from SalesAnalyticsView so 8.3 and future screens reuse
//  the same visual language without duplication.
//
//  ⚠️ ACTION REQUIRED in SalesAnalyticsView.swift:
//  Remove the two `private struct` declarations for `StatCard` and `ChartCard`
//  — they now live here as internal structs.
//

import SwiftUI

// MARK: - Stat Card

/// Small metric card used in the 2×2 summary grid at the top of analytics screens.
struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    var isLoading: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.subheadline)
                    .foregroundStyle(color)
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            if isLoading {
                ShimmerView()
                    .frame(width: 80, height: 22)
                    .clipShape(RoundedRectangle(cornerRadius: 4))
            } else {
                Text(value)
                    .font(.title3.bold())
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(color.opacity(0.15), lineWidth: 1)
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
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline)
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            content()
        }
        .padding(16)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - Dashboard Loading Placeholder

/// Three shimmer card placeholders — used while any analytics screen is loading.
struct DashboardLoadingPlaceholder: View {
    var count: Int = 3

    var body: some View {
        VStack(spacing: 16) {
            ForEach(0..<count, id: \.self) { _ in
                ShimmerView()
                    .frame(maxWidth: .infinity)
                    .frame(height: 180)
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
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 48))
                .foregroundStyle(.tertiary)
            Text(title)
                .font(.headline)
                .foregroundStyle(.secondary)
            Text(message)
                .font(.subheadline)
                .foregroundStyle(.tertiary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 48)
    }
}
