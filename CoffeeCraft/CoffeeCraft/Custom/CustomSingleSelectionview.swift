//
//  CustomSingleSelectionview.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 11/1/25.
//
import SwiftUI

struct CustomSingleSelectionview: View {
    let title: String
    var sizePrice: Double = 0.0
    let options: [String: Double]
    @Binding var selected: String

    /// If the group contains at least one free option, the user must always
    /// have something selected — deselect is not allowed.
    /// If all options are paid, the user can opt out entirely.
    private var hasIncludedOption: Bool {
        options.values.contains(where: { $0 == 0.0 })
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.system(size: 15, weight: .semibold, design: .serif))
                .foregroundColor(Color.accentPrimary)

            ChipFlowLayout(horizontalSpacing: 8, verticalSpacing: 10) {
                ForEach(Array(options.keys.sorted()), id: \.self) { option in
                    let price = options[option] ?? 0.0
                    let isSelected = selected == option

                    Button {
                        if isSelected && !hasIncludedOption {
                            // All options are paid — allow opting out
                            selected = ""
                        } else {
                            // Group has a free option — must always have a selection
                            selected = option
                        }
                    } label: {
                        VStack(spacing: 3) {
                            Text(option)
                                .font(.system(size: 14, weight: isSelected ? .semibold : .regular))
                                .foregroundColor(isSelected ? .white : Color.accentPrimary)
                                .padding(.vertical, 9)
                                .padding(.horizontal, 18)
                                .background(
                                    Capsule()
                                        .fill(isSelected ? Color.accentPrimary : Color.accentPrimary.opacity(0.08))
                                )
                                .overlay(
                                    Capsule()
                                        .stroke(Color.accentPrimary.opacity(isSelected ? 0 : 0.2), lineWidth: 1)
                                )
                                .shadow(
                                    color: isSelected ? Color.accentPrimary.opacity(0.3) : .clear,
                                    radius: 6, x: 0, y: 3
                                )

                            if price > 0 {
                                Text("+$\(price, specifier: "%.2f")")
                                    .font(.system(size: 11, weight: .medium))
                                    .foregroundColor(isSelected ? Color.accentPrimary : .secondary)
                            } else {
                                Text("Included")
                                    .font(.system(size: 11, weight: .medium))
                                    .foregroundColor(.secondary.opacity(0.6))
                            }
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                    .animation(.easeInOut(duration: 0.18), value: selected)
                }
            }
        }
        .onAppear {
            if selected.isEmpty, let zeroPriceOption = options.first(where: { $1 == 0.0 })?.key {
                selected = zeroPriceOption
            }
        }
    }
}
