//
//  SavedLocationAnnotationView.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 15/03/2026.
//

import SwiftUI

// MARK: - SavedLocationAnnotationView

struct SavedLocationAnnotationView: View {

    let location:   SavedLocation
    let isSelected: Bool

    private let pinSize: CGFloat     = 40
    private let selectedSize: CGFloat = 50

    private var size: CGFloat { isSelected ? selectedSize : pinSize }

    var body: some View {
        VStack(spacing: 0) {

            // Label callout (selected only)
            if isSelected {
                Text(location.label)
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                    .lineLimit(1)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background {
                        Capsule()
                            .fill(Color.accentGold)
                            .shadow(color: Color.accentGold.opacity(0.5), radius: 8, x: 0, y: 4)
                    }
                    .transition(
                        .asymmetric(
                            insertion: .scale(scale: 0.7, anchor: .bottom).combined(with: .opacity),
                            removal:   .scale(scale: 0.7, anchor: .bottom).combined(with: .opacity)
                        )
                    )
                    .padding(.bottom, 5)
            }

            // Pin bubble
            ZStack {
                // Glow ring when selected
                if isSelected {
                    Circle()
                        .fill(Color.accentGold.opacity(0.2))
                        .frame(width: size + 14, height: size + 14)
                }

                Circle()
                    .fill(isSelected ? Color.accentGold : Color.surfacePrimary)
                    .frame(width: size, height: size)
                    .shadow(
                        color: isSelected
                            ? Color.accentGold.opacity(0.5)
                            : Color.black.opacity(0.14),
                        radius: isSelected ? 12 : 5,
                        x: 0,
                        y: isSelected ? 5 : 2
                    )
                    .overlay {
                        if !isSelected {
                            Circle().strokeBorder(Color.borderColor, lineWidth: 1)
                        }
                    }

                Image(systemName: location.isDefault ? "house.fill" : "mappin.circle.fill")
                    .font(.system(size: isSelected ? 20 : 16, weight: .medium))
                    .foregroundColor(isSelected ? .white : Color.accentGold)
                    .symbolRenderingMode(.hierarchical)
            }

            // Tail
            Triangle()
                .fill(isSelected ? Color.accentGold : Color.surfacePrimary)
                .frame(width: 10, height: 7)
        }
        .scaleEffect(isSelected ? 1.0 : 0.9)
        .animation(.spring(response: 0.38, dampingFraction: 0.62), value: isSelected)
        .accessibilityLabel("\(location.label), \(location.address)")
        .accessibilityHint("Saved delivery address")
    }
}

// MARK: - Triangle (reused shape — keep local to avoid symbol collision)

private struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.closeSubpath()
        return path
    }
}
