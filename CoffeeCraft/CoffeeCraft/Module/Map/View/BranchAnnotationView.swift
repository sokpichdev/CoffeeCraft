//
//  BranchAnnotationView.swift
//  CoffeeCraft
//
//  Map Module — UI Enhanced
//  Richer selected state: name callout above pin, shadow bloom, smoother spring.
//

import SwiftUI

// MARK: - BranchAnnotationView

struct BranchAnnotationView: View {
    let branch: Branch
    let isSelected: Bool

    private let pinSize: CGFloat = 42
    private let selectedSize: CGFloat = 52
    private let tailHeight: CGFloat = 7

    private var size: CGFloat { isSelected ? selectedSize : pinSize }

    var body: some View {
        VStack(spacing: 0) {

            // ── Name callout (only when selected) ──────────────────
            if isSelected {
                Text(branch.name)
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                    .lineLimit(1)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background {
                        Capsule()
                            .fill(Color.accentPrimary)
                            .shadow(color: Color.accentPrimary.opacity(0.5), radius: 8, x: 0, y: 4)
                    }
                    .transition(
                        .asymmetric(
                            insertion: .scale(scale: 0.7, anchor: .bottom).combined(with: .opacity),
                            removal: .scale(scale: 0.7, anchor: .bottom).combined(with: .opacity)
                        )
                    )
                    .padding(.bottom, 5)
            }

            // ── Pin bubble ──────────────────────────────────────────
            ZStack {
                // Outer glow ring when selected
                if isSelected {
                    Circle()
                        .fill(Color.accentPrimary.opacity(0.2))
                        .frame(width: size + 14, height: size + 14)
                }

                Circle()
                    .fill(isSelected ? Color.accentPrimary : Color.surfacePrimary)
                    .frame(width: size, height: size)
                    .shadow(
                        color: isSelected
                            ? Color.accentPrimary.opacity(0.5)
                            : Color.black.opacity(0.14),
                        radius: isSelected ? 14 : 5,
                        x: 0,
                        y: isSelected ? 6 : 2
                    )
                    .overlay {
                        if !isSelected {
                            Circle()
                                .strokeBorder(Color.borderColor, lineWidth: 1)
                        }
                    }

                Image(systemName: "cup.and.saucer.fill")
                    .font(.system(size: isSelected ? 22 : 17, weight: .medium))
                    .foregroundColor(isSelected ? .white : Color.accentPrimary)
                    .symbolRenderingMode(.hierarchical)

                // Closed badge
                if !branch.isOpen {
                    Circle()
                        .fill(Color.semanticError)
                        .frame(width: 15, height: 15)
                        .overlay {
                            Image(systemName: "xmark")
                                .font(.system(size: 7, weight: .black))
                                .foregroundColor(.white)
                        }
                        .offset(x: size * 0.32, y: -(size * 0.32))
                }
            }

            // ── Tail ────────────────────────────────────────────────
            Triangle()
                .fill(isSelected ? Color.accentPrimary : Color.surfacePrimary)
                .frame(width: 10, height: tailHeight)
        }
        .scaleEffect(isSelected ? 1.0 : 0.88)
        .animation(
            .spring(response: 0.38, dampingFraction: 0.62),
            value: isSelected
        )
        .accessibilityLabel("\(branch.name), \(branch.isOpen ? "Open" : "Closed")")
    }
}

// MARK: - Triangle Shape

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
