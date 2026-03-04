//
//  SettingsSection.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 1/20/26.
//
import SwiftUI

struct SettingsSection<Content: View>: View {
    let title: String
    let icon: String
    let content: Content
    
    init(
        title: String,
        icon: String,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.icon = icon
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.headline)
                    .foregroundColor(Color.accentPrimary)
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)
            }
            .padding(.leading, 4)
            
            VStack(spacing: 0) {
                content
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.secondarySystemGroupedBackground))
                    .shadow(color: Color.textPrimary.opacity(0.06), radius: 8, y: 2)
            )
        }
    }
}
