//
//  CustomMultipleSelectionView.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 11/1/25.
//
import SwiftUI

struct CustomMultipleSelectionView: View {
    let title: String
    let options: [String: Double]
    @Binding var selected: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.system(size: 15, weight: .semibold, design: .serif))
                .foregroundColor(Color.accentPrimary)

            ChipFlowLayout(horizontalSpacing: 8, verticalSpacing: 10) {
                ForEach(options.keys.sorted(), id: \.self) { option in
                    let price = options[option] ?? 0
                    let isSelected = selected.contains(option)

                    Button {
                        withAnimation(.easeInOut(duration: 0.18)) {
                            if isSelected {
                                selected.removeAll { $0 == option }
                            } else {
                                selected.append(option)
                            }
                        }
                    } label: {
                        VStack(spacing: 3) {
                            HStack(spacing: 5) {
                                if isSelected {
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 11, weight: .bold))
                                        .foregroundColor(.textPrimary).colorScheme(.dark)
                                        .transition(.scale.combined(with: .opacity))
                                }
                                Text(option)
                                    .font(.system(size: 14, weight: isSelected ? .semibold : .regular))
                                    .foregroundColor(isSelected ? Color.textPrimary
                                                     : Color.coffeeDarkBrown).colorScheme(.dark)
                            }
                            .padding(.vertical, 9)
                            .padding(.horizontal, 18)
                            .background(
                                Capsule()
                                    .fill(isSelected ? Color.accentPrimary : Color.accentPrimary.opacity(0.08))
                            )
                            .overlay(
                                Capsule()
                                    .stroke(Color.border.opacity(isSelected ? 0 : 1), lineWidth: 1)
                            )
                            .shadow(
                                color: isSelected ? Color.border.opacity(0.3) : .clear,
                                radius: 6, x: 0, y: 3
                            )

                            if price > 0 {
                                Text("+$\(price, specifier: "%.2f")")
                                    .font(.system(size: 11, weight: .medium))
                                    .foregroundColor(isSelected ? Color.accentPrimary : .commonGray)
                            } else {
                                Text("Free")
                                    .font(.system(size: 11, weight: .medium))
                                    .foregroundColor(.commonGray.opacity(0.6))
                            }
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
    }
}
