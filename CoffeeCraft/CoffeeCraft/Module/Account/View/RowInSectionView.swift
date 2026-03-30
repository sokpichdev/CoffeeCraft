//
//  RowInSectionView.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 3/30/26.
//

import SwiftUI

struct RowInSectionView: View {
    var label: String?
    let title: String
    let systemImage: String
    var badgeCount: Int?
    
    var trailingSystemImage: String = "chevron.right"
    var onClicked: (() -> Void)?
    
    var body: some View {
        Button {
            onClicked?()
        } label: {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(Color(.tertiarySystemGroupedBackground))
                        .frame(width: 36, height: 36)
                    
                    Image(systemName: systemImage)
                        .font(.headline)
                        .foregroundColor(Color.textSecondary)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    if let label = label {
                        Text(label)
                            .font(.caption)
                            .foregroundColor(.textSecondary)
                    }
                    
                    Text(title)
                        .font(.subheadline)
                        .foregroundColor(.textPrimary)
                }
                
                Spacer()
                
                if let count = badgeCount, count > 0 {
                    Text("\\(count)")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(
                            Capsule()
                                .fill(Color.semanticError)
                        )
                }
                
                if onClicked != nil {
                    if trailingSystemImage != "" {
                        Image(systemName: trailingSystemImage)
                            .font(.headline)
                            .foregroundColor(Color.textSecondary)
                    }
                }
            }
            .padding(.vertical, 12)
        }
        .disabled(onClicked == nil)
        .foregroundColor(.textPrimary)
    }
}
