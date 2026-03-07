//
//  BankRow.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 3/7/26.
//
import SwiftUI

struct BankRow: View {
    let bank: BankOption
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(bank.color.opacity(0.12))
                        .frame(width: 48, height: 48)
                    
                    Image(systemName: bank.icon)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(bank.color)
                }
                
                VStack(alignment: .leading, spacing: 3) {
                    Text(bank.name)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(Color.textPrimary)
                    
                    Text(bank.description)
                        .font(.caption)
                        .foregroundColor(Color.textMuted)
                        .lineLimit(1)
                }
                
                Spacer()
                
                ZStack {
                    Circle()
                        .strokeBorder(
                            isSelected ? Color.accentPrimary : Color.borderColor,
                            lineWidth: 2
                        )
                        .frame(width: 22, height: 22)
                    
                    if isSelected {
                        Circle()
                            .fill(Color.accentPrimary)
                            .frame(width: 12, height: 12)
                            .transition(.scale.combined(with: .opacity))
                    }
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? Color.accentPrimary.opacity(0.06) : Color.surfacePrimary)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(
                        isSelected ? Color.accentPrimary.opacity(0.4) : Color.borderColor.opacity(0.6),
                        lineWidth: 1.5
                    )
            )
            .shadow(
                color: isSelected ? Color.accentPrimary.opacity(0.12) : Color.accentPrimary.opacity(0.04),
                radius: isSelected ? 6 : 2, y: 2
            )
        }
        .buttonStyle(.plain)
    }
}
