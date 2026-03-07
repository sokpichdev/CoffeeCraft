//
//  CustomTopupAmountField.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 3/7/26.
//
import SwiftUI

struct CustomTopupAmountField: View {
    
    @Binding var input: String
    @FocusState private var focused: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            Text("$")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(focused ? .accentPrimary : .textSecondary)
            
            TextField("Custom amount", text: $input)
                .keyboardType(.decimalPad)
                .focused($focused)
                .font(.title3)
                .fontWeight(.semibold)
            
            if !input.isEmpty {
                Button {
                    input = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(.secondarySystemGroupedBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(
                    focused ? Color.accentPrimary : Color.accentPrimary.opacity(0.2),
                    lineWidth: focused ? 2 : 1
                )
        )
        .animation(.easeInOut(duration: 0.2), value: focused)
    }
}
