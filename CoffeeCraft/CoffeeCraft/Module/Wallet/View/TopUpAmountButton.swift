//
//  TopUpAmountButton.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 03/03/2026.
//

import SwiftUI

// MARK: - TopUpAmountButton
// Selectable chip used inside TopUpView's amount grid.
// Shows the $ amount, an optional badge ("Popular", "Best Value"),
// and a highlighted selected state.

struct TopUpAmountButton: View {

    let amount: Double
    let badge: String?
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            ZStack(alignment: .topTrailing) {
                VStack(spacing: 6) {
                    Image(systemName: "cup.and.saucer.fill")
                        .font(.title2)
                        .foregroundStyle(isSelected ? .white : Color.coffeeBrown)

                    Text(amount.currencyFormatted)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundStyle(isSelected ? .white : .primary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            isSelected
                                ? LinearGradient(
                                    colors: [Color.coffeeBrown, Color.coffeeLight],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                  )
                                : LinearGradient(
                                    colors: [Color(.secondarySystemGroupedBackground)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                  )
                        )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .strokeBorder(
                            isSelected ? Color.coffeeBrown : Color.coffeeBrown.opacity(0.15),
                            lineWidth: isSelected ? 2 : 1
                        )
                )
                .shadow(
                    color: isSelected ? Color.coffeeBrown.opacity(0.35) : Color.clear,
                    radius: 8, y: 4
                )

                // Badge (e.g. "Popular", "Best Value")
                if let badge {
                    Text(badge)
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background(
                            Capsule().fill(Color.errorRed)
                        )
                        .offset(x: -8, y: 8)
                }
            }
        }
        .buttonStyle(.plain)
        .scaleEffect(isSelected ? 1.03 : 1.0)
        .animation(.spring(duration: 0.25), value: isSelected)
    }
}
