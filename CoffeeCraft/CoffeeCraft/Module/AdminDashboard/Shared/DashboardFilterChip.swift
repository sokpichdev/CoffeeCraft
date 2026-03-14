//
//  DashboardFilterChip.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 3/14/26.
//
import SwiftUI

struct DashboardFilterChip: View {
    let label: String
    let isSelected: Bool
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.caption.weight(.semibold))
                .foregroundStyle(isSelected ? .white : color)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? color : color.opacity(0.10), in: Capsule())
                .overlay(Capsule().stroke(color.opacity(isSelected ? 0 : 0.25), lineWidth: 1))
        }
        .buttonStyle(.plain)
    }
}
