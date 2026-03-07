//
//  CustomNumberField.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 11/1/25.
//
import SwiftUI

struct CustomNumberField: View {
    var title: String
    @Binding var value: Double
    var icon: String
    
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.accentPrimary)
            TextField(title, value: $value, format: .number.precision(.fractionLength(2)))
                .textFieldStyle(PlainTextFieldStyle())
                .keyboardType(.decimalPad)
                .padding(10)
                .foregroundColor(.textPrimary)
        }
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
