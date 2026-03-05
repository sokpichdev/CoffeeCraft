//
//  BranchAnnotationView.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 06/03/2026.
//


//
//  BranchAnnotationView.swift
//  CoffeeCraft
//
//  Created by Sok Pich
//  Map Module — Phase 2: Branches on Map
//

import SwiftUI

// MARK: - BranchAnnotationView

struct BranchAnnotationView: View {
    let branch: Branch
    let isSelected: Bool

    // MARK: - Layout constants

    private let pinSize: CGFloat = 44
    private let selectedSize: CGFloat = 56
    private let tailHeight: CGFloat = 8

    private var size: CGFloat { isSelected ? selectedSize : pinSize }

    var body: some View {
        VStack(spacing: 0) {
            // ── Bubble ──────────────────────────────────────────────
            ZStack {
                Circle()
                    .fill(isSelected ? Color.accentPrimary : Color.surfacePrimary)
                    .frame(width: size, height: size)
                    .shadow(
                        color: isSelected
                            ? Color.accentPrimary.opacity(0.45)
                            : Color.black.opacity(0.12),
                        radius: isSelected ? 10 : 5,
                        x: 0,
                        y: isSelected ? 4 : 2
                    )
                    .overlay(
                        Circle()
                            .strokeBorder(
                                isSelected ? Color.clear : Color.border,
                                lineWidth: 1.5
                            )
                    )

                // Coffee cup icon
                Image(systemName: "cup.and.saucer.fill")
                    .font(.system(size: isSelected ? 22 : 18, weight: .medium))
                    .foregroundStyle(isSelected ? .white : .accentPrimary)

                // Closed overlay badge
                if !branch.isOpen {
                    Circle()
                        .fill(Color.semanticError)
                        .frame(width: 14, height: 14)
                        .overlay(
                            Image(systemName: "xmark")
                                .font(.system(size: 7, weight: .black))
                                .foregroundStyle(.white)
                        )
                        .offset(x: size * 0.3, y: -(size * 0.3))
                }
            }

            // ── Tail ────────────────────────────────────────────────
            Triangle()
                .fill(isSelected ? Color.accentPrimary : Color.surfacePrimary)
                .frame(width: 10, height: tailHeight)
                .shadow(
                    color: Color.black.opacity(0.08),
                    radius: 2, x: 0, y: 2
                )
        }
        .scaleEffect(isSelected ? 1.0 : 0.9)
        .animation(.spring(response: 0.3, dampingFraction: 0.65), value: isSelected)
        .accessibilityLabel(
            "\(branch.name), \(branch.isOpen ? "Open" : "Closed")"
        )
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

//// MARK: - Preview
//
//#Preview {
//    HStack(spacing: 24) {
//        BranchAnnotationView(branch: MockBranchData.all[0], isSelected: false)
//        BranchAnnotationView(branch: MockBranchData.all[0], isSelected: true)
//        BranchAnnotationView(branch: MockBranchData.all[2], isSelected: false) // closed
//    }
//    .padding(32)
//    .background(Color.bgPrimary)
//}
