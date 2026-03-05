//
//  CustomizationOptionRow.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 1/17/26.
//
import SwiftUI

struct CustomizationOptionRow: View {
    @Binding var option: CustomizationOption
    let onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // Delete button (tap version)
            Button(action: {
                withAnimation {
                    onDelete()
                }
            }) {
                Image(systemName: "minus.circle.fill")
                    .font(.title3)
                    .foregroundColor(.red)
            }
            .buttonStyle(PlainButtonStyle())
            
            TextField("Option name", text: $option.name)
                .textFieldStyle(PlainTextFieldStyle())
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(.systemGray6))
                )
            
            HStack(spacing: 4) {
                Text("$")
                    .font(.subheadline)
                    .foregroundColor(.textSecondary)
                
                TextField("0.00", value: $option.price, format: .number.precision(.fractionLength(2)))
                    .textFieldStyle(PlainTextFieldStyle())
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
                    .frame(width: 60)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(.systemGray6))
            )
        }
    }
}
