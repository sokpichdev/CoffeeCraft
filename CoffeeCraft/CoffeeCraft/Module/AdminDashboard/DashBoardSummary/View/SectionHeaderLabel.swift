//
//  SectionHeaderLabel.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 3/14/26.
//
import SwiftUI

struct SectionHeaderLabel: View {
    let icon: String
    let title: String

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(Color.accentPrimary)
                .frame(width: 26, height: 26)
                .background(Color.accentPrimary.opacity(0.10), in: RoundedRectangle(cornerRadius: 7))
            Text(title)
                .font(.headline.weight(.semibold))
                .foregroundStyle(Color.textPrimary)
        }
    }
}
