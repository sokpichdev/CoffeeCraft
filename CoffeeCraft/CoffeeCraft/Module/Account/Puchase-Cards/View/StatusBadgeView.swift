//
//  StatusBadgeView.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 1/28/26.
//
import SwiftUI

struct StatusBadgeView: View {
    let icon: String
    let text: String
    var textColor: Color = .textPrimary
    let bgColor: Color
    
    var body: some View {
        HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.caption2)
                    .foregroundColor(textColor).colorScheme(.dark)
                Text(text)
                    .font(.caption)
                    .foregroundColor(textColor).colorScheme(.dark)
        }
        .foregroundStyle(.white)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(
            Capsule()
                .fill(bgColor).colorScheme(.dark)
        )
        .shadow(color: bgColor.opacity(0.15), radius: 2, x: 0, y: 1)
    }
}
