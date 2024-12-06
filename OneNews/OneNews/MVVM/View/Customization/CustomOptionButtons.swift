//
//  CustomedOptionButtons.swift
//  OneNews
//
//  Created by Sok Pich on 12/6/24.
//

import SwiftUI

struct CustomOptionButtons: View {
    var title: String
    var imageName: String
    var isSelected: Bool
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(isSelected ? "Clicked\(imageName)" : imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 20)
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(isSelected ? .main : .gray)
            }
            .frame(maxWidth: 100, maxHeight: 60)
            .padding(8)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [Color(.systemGray6), .white, Color(.systemGray4)]),
                    startPoint: .top,
                    endPoint: .bottom
                )
            ) // Background gradient
            
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(isSelected ? Color.main : Color.clear, lineWidth: 2) // Add border
            )
            .shadow(radius: 5)
            .padding(5)
        }
    }
}
