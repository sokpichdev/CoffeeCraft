//
//  CustomProductTextField.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 11/1/25.
//
import SwiftUI

struct CustomProductTextField: View {
    var title: String
    @Binding var text: String
    var icon: String
    
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.brown)
            TextField(title, text: $text)
                .textFieldStyle(PlainTextFieldStyle())
                .padding(10)
        }
        .padding(.horizontal)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(.systemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color(.systemGray4), lineWidth: 0.5)
        )
        .shadow(
            color: colorScheme == .dark ? Color.clear : Color.textPrimary.opacity(0.05),
            radius: 2,
            x: 0,
            y: 1
        )
    }
}
