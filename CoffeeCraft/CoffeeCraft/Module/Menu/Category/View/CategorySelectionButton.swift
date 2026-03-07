//
//  CategorySelectionButton.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 11/1/25.
//
import SwiftUI

struct CategorySelectionButton: View {
    let title: String
    let category: String
    let icon: String
    let action: () -> Void
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .foregroundColor(.accentPrimary)
                    .frame(width: 20)

                Text(category.isEmpty ? "Select \(title)..." : category)
                    .foregroundColor(category.isEmpty ? .gray : .primary)
                    .foregroundColor(.textPrimary)
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.headline)
                    .foregroundColor(Color.textSecondary)
            }
            .padding(.vertical, 10)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .tint(.accentPrimary)
        .padding(.horizontal)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(.systemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.borderColor, lineWidth: 0.5)
        )
        .shadow(
            color: colorScheme == .dark ? Color.clear : Color.textPrimary.opacity(0.05),
            radius: 2,
            x: 0,
            y: 1
        )
    }
}
