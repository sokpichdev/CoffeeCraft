//
//  KPICard.swift
//  CoffeeCraft
//

import SwiftUI

// MARK: - KPI Card

struct KPICard: View {
    
    let title: String
    let value: String
    let icon: String
    let accentColor: Color
    var subtitle: String?
    var subtitleIsPositive: Bool?
    var isLoading: Bool = false
    
    var body: some View {
        HStack {
            RoundedRectangle(cornerRadius: 3)
                .fill(accentColor)
                .frame(width: 4)
                .padding(.vertical, -14)
                .padding(.leading, 0)
            VStack(alignment: .leading, spacing: 0) {
                
                // Icon + title row
                HStack(spacing: 8) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 9)
                            .fill(accentColor.opacity(0.13))
                            .frame(width: 34, height: 34)
                        Image(systemName: icon)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(accentColor)
                    }
                    Text(title)
                        .font(.caption.weight(.medium))
                        .foregroundStyle(Color.textSecondary)
                        .lineLimit(1)
                    Spacer()
                }
                .padding(.bottom, 12)
                
                // Value
                if isLoading {
                    ShimmerView()
                        .frame(width: 90, height: 28)
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                        .padding(.bottom, 8)
                } else {
                    Text(value)
                        .font(.system(size: 26, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.textPrimary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.65)
                        .padding(.bottom, 6)
                }
                
                // Subtitle / change indicator
                if let subtitle {
                    if isLoading {
                        ShimmerView()
                            .frame(width: 64, height: 11)
                            .clipShape(RoundedRectangle(cornerRadius: 4))
                    } else {
                        HStack(spacing: 3) {
                            if let isPositive = subtitleIsPositive {
                                Image(systemName: isPositive ? "arrow.up.right" : "arrow.down.right")
                                    .font(.system(size: 9, weight: .bold))
                                    .foregroundStyle(isPositive ? Color.semanticSuccess : Color.semanticError)
                            }
                            Text(subtitle)
                                .font(.caption2)
                                .foregroundStyle(subtitleColor)
                        }
                    }
                }
                Spacer(minLength: 0)
            }
            Spacer()
        }
        .padding(EdgeInsets(top: 14, leading: 0, bottom: 14, trailing: 14))
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.surfacePrimary)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 3)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.borderColor, lineWidth: 1)
        )
    }
    
    private var subtitleColor: Color {
        guard let isPositive = subtitleIsPositive else { return .textMuted }
        return isPositive ? .semanticSuccess : .semanticError
    }
}
