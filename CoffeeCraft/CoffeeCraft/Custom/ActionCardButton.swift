//
//  ActionCardButton.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 2/3/26.
//
import SwiftUI

struct ActionCardButton: View {
    let iconName: String
    let title: String
    let subtitle: String
    let gradientColors: [Color]
    let shadowColor: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: iconName)
                    .font(.title3)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.headline)
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.headline)
                    .foregroundColor(.white)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(
                LinearGradient(
                    colors: gradientColors,
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .foregroundColor(.white)
            .cornerRadius(16)
            .shadow(color: shadowColor.opacity(0.3), radius: 8, x: 0, y: 4)
        }
    }
}
