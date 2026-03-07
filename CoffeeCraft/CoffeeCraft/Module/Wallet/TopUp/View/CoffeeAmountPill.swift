//
//  CoffeeAmountPill.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 3/7/26.
//
import SwiftUI

struct CoffeeAmountPill: View {
    
    let amount: Double
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text("$\(Int(amount))")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(isSelected ? Color.bgPrimary : Color.accentPrimary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(isSelected ? Color.accentPrimary : Color.surfaceSub)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(
                            isSelected ? Color.accentPrimary : Color.borderColor,
                            lineWidth: isSelected ? 2 : 1
                        )
                )
                .shadow(
                    color: isSelected ? Color.accentPrimary.opacity(0.28) : .clear,
                    radius: 8, x: 0, y: 4
                )
        }
        .buttonStyle(.plain)
        .scaleEffect(isSelected ? 1.03 : 1.0)
        .animation(.spring(response: 0.25, dampingFraction: 0.8), value: isSelected)
    }
}
