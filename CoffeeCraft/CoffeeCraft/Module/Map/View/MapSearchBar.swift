//
//  MapSearchBar.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 3/6/26.
//  Map Module — Phase 5
//  Floating search bar shown above the branch strip.
//  Filters branches by name or address with a 0.3s debounce.
//

import SwiftUI

// MARK: - MapSearchBar

struct MapSearchBar: View {

    @Binding var text: String
    var onClear: () -> Void

    @FocusState private var isFocused: Bool

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(isFocused ? .accentPrimary : .textMuted)
                .animation(.easeInOut(duration: 0.2), value: isFocused)

            TextField("Search branches…", text: $text)
                .font(.custom("Nunito-SemiBold", size: 14))
                .foregroundStyle(.textPrimary)
                .focused($isFocused)
                .autocorrectionDisabled()
                .accessibilityLabel("Search branches by name or address")

            if !text.isEmpty {
                Button {
                    text = ""
                    onClear()
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 15))
                        .foregroundStyle(.textMuted)
                }
                .transition(.opacity.combined(with: .scale))
                .accessibilityLabel("Clear search")
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(Color.surfacePrimary)
        .cornerRadius(14)
        .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 3)
        .animation(.easeInOut(duration: 0.2), value: text.isEmpty)
    }
}
