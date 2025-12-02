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
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .foregroundColor(.brown)
                    .frame(width: 20)

                Text(category.isEmpty ? "Select \(title)..." : category)
                    .foregroundColor(category.isEmpty ? .gray : .primary)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
                    .font(.customCaption)
            }
            .padding(.vertical, 10)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain) // Use .plain to prevent the default button coloring
        .tint(.brown)
        .padding(.horizontal)
        .background(RoundedRectangle(cornerRadius: 10).fill(Color.white))
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}
