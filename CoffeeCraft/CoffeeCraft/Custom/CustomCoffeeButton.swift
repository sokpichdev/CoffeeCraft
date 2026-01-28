//
//  CustomCoffeeButton.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 1/28/26.
//
import SwiftUI

struct CustomCoffeeButton: View {
    var title: String = ""
    var buttonImage: String = ""
    var foregroundColor: Color = .white
    var bgColors: [Color] = []
    var verticalPadding: CGFloat = 12
    var horinzontalPadding: CGFloat = 16
    var maxWidth: CGFloat? = .infinity
    var onClicked: (() -> Void)
    var body: some View {
        Button {
            onClicked()
        } label: {
            HStack(spacing: 6) {
                if buttonImage != "" {
                    Image(systemName: buttonImage)
                }
                if title != "" {
                    Text(title)
                }
            }
            .font(.headline.weight(.semibold))
            .foregroundStyle(foregroundColor)
            .frame(maxWidth: maxWidth)
            .padding(.vertical, verticalPadding)
            .padding(.horizontal, horinzontalPadding)
            .background(
                LinearGradient(
                    colors: bgColors,
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .strokeBorder(Color.coffeeBrown.opacity(0.3), lineWidth: 1)
            )
        }
    }
}
