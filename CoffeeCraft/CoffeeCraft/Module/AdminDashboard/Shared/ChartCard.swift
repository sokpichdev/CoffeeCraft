//
//  ChartCard.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 3/14/26.
//
import SwiftUI

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
