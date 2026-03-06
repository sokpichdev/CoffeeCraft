//
//  RowInProfileView.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 1/19/26.
//
import SwiftUI

struct RowInProfileView<Content: View>: View {
    @Binding var title: String
    @Binding var isEditing: Bool
    var previousTitle: String = ""
    var label: String?
    let systemImage: String
    let editType: EditProductType
    
    @ViewBuilder let content: Content
    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(
                        isEditing && (editType == .phone || editType == .email) ?
                        Color(.surfacePrimary).opacity(0.5) : Color(.surfacePrimary)
                    )
                    .frame(width: 36, height: 36)
                
                Image(systemName: systemImage)
                    .font(.headline)
                    .foregroundColor(isEditing && (editType == .phone || editType == .email) ?
                                     Color.textMuted : Color.textSecondary)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                if let label = label {
                    Text(label)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundStyle(.textSecondary)
                }
                
                if isEditing {
                    switch editType {
                    case .name:
                        TextField("", text: $title)
                            .font(.headline)
                            .foregroundStyle(.textPrimary)

                    case .email, .phone:
                        // Email is NOT editable, but color changes when editing
                        Text(title)
                            .font(.headline)
                            .foregroundStyle(.textMuted)

                    default:
                        Text(previousTitle)
                            .font(.headline)
                            .foregroundStyle(.textSecondary.opacity(0.5))
                    }
                } else {
                    Text(title)
                        .font(.headline)
                        .foregroundStyle(.textPrimary)
                }
            }
            
            Spacer()
            
            if (editType == .date || editType == .dropDown) && isEditing {
                content
            }
        }
        .padding(.vertical, 8)
    }
}
