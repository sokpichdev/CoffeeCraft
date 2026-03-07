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
                        .foregroundStyle(bank.color)
                }
                
                VStack(alignment: .leading, spacing: 3) {
                    Text(bank.name)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    
                    Text(bank.description)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
                
                Spacer()
                
                ZStack {
                    Circle()
                        .strokeBorder(isSelected ? Color.accentPrimary : Color.secondary.opacity(0.3), lineWidth: 2)
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
                    .fill(isSelected ? Color.accentPrimary.opacity(0.06) : Color(.secondarySystemGroupedBackground))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(
                        isSelected ? Color.accentPrimary.opacity(0.4) : Color.clear,
                        lineWidth: 1.5
                    )
            )
            .shadow(
                color: isSelected ? Color.accentPrimary.opacity(0.1) : .clear,
                radius: 4, y: 2
            )
        }
        .buttonStyle(.plain)
    }
}
