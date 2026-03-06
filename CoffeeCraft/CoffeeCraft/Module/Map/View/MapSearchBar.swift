//
//  MapSearchBar.swift
//  CoffeeCraft
//
//  Map Module — UI Enhanced
//  Glass material, focus ring, polished clear animation.
//

import SwiftUI

// MARK: - MapSearchBar

struct MapSearchBar: View {

    @Binding var text: String
    var onClear: () -> Void

    @FocusState private var isFocused: Bool

    var body: some View {
        HStack(spacing: 10) {
            // Search icon — animates to accent when focused
            Image(systemName: "magnifyingglass")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(isFocused ? Color.accentPrimary : Color.textMuted)
                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isFocused)

            TextField("Search branches…", text: $text)
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .foregroundStyle(Color.textPrimary)
                .focused($isFocused)
                .autocorrectionDisabled()
                .submitLabel(.search)
                .accessibilityLabel("Search branches by name or address")

            // Animated clear button
            if !text.isEmpty {
                Button {
                    withAnimation(.spring(response: 0.25, dampingFraction: 0.65)) {
                        text = ""
                    }
                    onClear()
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 16))
                        .foregroundStyle(Color.textMuted.opacity(0.7))
                        .symbolRenderingMode(.hierarchical)
                }
                .buttonStyle(BounceButtonStyle())
                .transition(
                    .asymmetric(
                        insertion: .scale(scale: 0.5).combined(with: .opacity),
                        removal: .scale(scale: 0.5).combined(with: .opacity)
                    )
                )
                .accessibilityLabel("Clear search")
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 11)
        .background {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(.regularMaterial)
                .overlay {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .strokeBorder(
                            isFocused
                                ? Color.accentPrimary.opacity(0.4)
                                : Color.primary.opacity(0.07),
                            lineWidth: isFocused ? 1.5 : 0.5
                        )
                }
                .shadow(color: .black.opacity(isFocused ? 0.12 : 0.07), radius: isFocused ? 12 : 6, x: 0, y: 3)
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isFocused)
    }
}
