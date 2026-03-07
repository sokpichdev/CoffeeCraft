//
//  ColorThemePickerView.swift
//  CoffeeCraft
//
//  Color Theme Picker — Account › Personal › Color Theme
//  Shows a visual card grid for each palette with live swatch preview.
//

import SwiftUI

struct ColorThemePickerView: View {
    @ObservedObject private var themeManager = ThemeManager.shared
    @Environment(\.dismiss) private var dismiss

    private let columns = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 24) {
                headerDescription
                paletteGrid
                Spacer(minLength: 32)
            }
            .padding(.horizontal)
            .padding(.top, 12)
        }
        .background(Color.bgPrimary)
        .customNavigationBar("Color Theme") {
            ToolBarButton.back {
                dismiss()
            }
        }
    }

    // MARK: Header

    private var headerDescription: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Choose a palette that feels like you.")
                .font(.subheadline)
                .foregroundColor(Color.textSecondary)
        }
    }

    // MARK: Palette Grid

    private var paletteGrid: some View {
        LazyVGrid(columns: columns, spacing: 16) {
            ForEach(ColorPalette.allCases) { palette in
                PaletteCard(
                    palette: palette,
                    isSelected: themeManager.palette == palette
                ) {
                    themeManager.setPalette(palette)
                }
            }
        }
    }
}

// MARK: - Palette Card

private struct PaletteCard: View {
    let palette: ColorPalette
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 12) {

                // ── Swatch Row ───────────────────────────────────────
                HStack(spacing: 6) {
                    ForEach(Array(palette.swatchColors.enumerated()), id: \.offset) { _, color in
                        Circle()
                            .fill(color)
                            .frame(width: 24, height: 24)
                            .shadow(color: color.opacity(0.4), radius: 3, y: 2)
                    }
                    Spacer()
                }

                // ── Name + Subtitle ──────────────────────────────────
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 6) {
                        Text(palette.emoji)
                            .font(.subheadline)
                        Text(palette.title)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(Color.textPrimary)
                    }
                    Text(palette.subtitle)
                        .font(.caption)
                        .foregroundColor(Color.textMuted)
                        .lineLimit(1)
                }

                // ── Selected Badge ───────────────────────────────────
                HStack {
                    Spacer()
                    if isSelected {
                        HStack(spacing: 4) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.caption)
                            Text("Active")
                                .font(.caption2)
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(Color.accentPrimary)
                        .transition(.scale.combined(with: .opacity))
                    }
                }
                .frame(height: 16)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(Color.surfacePrimary)
                    .overlay(
                        RoundedRectangle(cornerRadius: 18)
                            .strokeBorder(
                                isSelected ? Color.accentPrimary : Color.borderColor,
                                lineWidth: isSelected ? 2 : 1
                            )
                    )
                    .shadow(
                        color: isSelected
                            ? Color.accentPrimary.opacity(0.20)
                            : Color.textPrimary.opacity(0.06),
                        radius: isSelected ? 10 : 6,
                        y: 4
                    )
            )
            .scaleEffect(isSelected ? 1.02 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
        }
        .buttonStyle(.plain)
    }
}
