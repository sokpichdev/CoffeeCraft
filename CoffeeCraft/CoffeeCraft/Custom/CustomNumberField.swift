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

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.brown)
            TextField(title, value: $value, format: .number)
                .keyboardType(.decimalPad)
                .textFieldStyle(PlainTextFieldStyle())
                .padding(10)
        }
        .padding(.horizontal)
        .background(RoundedRectangle(cornerRadius: 10).fill(Color.white))
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}
