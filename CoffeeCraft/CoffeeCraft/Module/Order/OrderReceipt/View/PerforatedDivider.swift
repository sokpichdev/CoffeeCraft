//
//  PerforatedDivider.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 2/26/26.
//
import SwiftUI

// MARK: - Perforated Edge Divider
struct PerforatedDivider: View {
    var body: some View {
        GeometryReader { geo in
            let dotDiameter: CGFloat = 8
            let spacing: CGFloat = 12
            let count = Int(geo.size.width / (dotDiameter + spacing))
            HStack(spacing: spacing) {
                ForEach(0..<count, id: \.self) { _ in
                    Circle()
                        .fill(Color(.systemGroupedBackground))
                        .frame(width: dotDiameter, height: dotDiameter)
                }
            }
            .frame(maxWidth: .infinity)
        }
        .frame(height: 8)
    }
}
