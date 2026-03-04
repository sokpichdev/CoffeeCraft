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
    var bgColors: [Color] = [Color.accentPrimary, Color.coffeeLight]
    var contentPlacement: ButtonContentPlacement = .center
    var isDisabled: Bool = false
    var verticalPadding: CGFloat = 12
    var horinzontalPadding: CGFloat = 16
    var maxWidth: CGFloat? = .infinity
    var onClicked: (() -> Void)
    var body: some View {
        Button {
            onClicked()
        } label: {
            HStack(spacing: contentPlacement == .center ? 6 : 12) {
                if contentPlacement == .trailing {
                    Spacer()
                }
                if buttonImage != "" {
                    Image(systemName: buttonImage)
                }
                if title != "" {
                    Text(title)
                }
                if contentPlacement == .leading {
                    Spacer()
                }
            }
            .font(.headline).fontWeight(.semibold)
            .foregroundStyle(!isDisabled ? foregroundColor : .primary)
            .frame(maxWidth: maxWidth)
            .padding(.vertical, verticalPadding)
            .padding(.horizontal, horinzontalPadding)
            .background(
                LinearGradient(
                    colors: !isDisabled ? bgColors : [.coffeeCream.opacity(0.5)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .strokeBorder(Color.accentPrimary.opacity(0.3), lineWidth: 1)
            )
        }
        .disabled(isDisabled)
    }
}

enum ButtonContentPlacement {
    case leading
    case trailing
    case center
}
