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
    var label: String? = nil
    let systemImage: String
    let editType: EditProductType
    
    @ViewBuilder let content: Content
    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(Color(.tertiarySystemGroupedBackground))
                    .frame(width: 36, height: 36)
                
                Image(systemName: systemImage)
                    .font(.headline)
                    .foregroundColor(Color.brown)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                if let label = label {
                    Text(label)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundStyle(.secondary)
                }
                
                if isEditing {
                    switch editType {
                    case .name:
                        TextField("", text: $title)
                            .font(.headline)
                            .foregroundStyle(.primary)

                    case .phone:
                        TextField("", text: $title)
                            .keyboardType(.phonePad)
                            .font(.headline)
                            .foregroundStyle(.primary)

                    case .email:
                        // Email is NOT editable, but color changes when editing
                        Text(title)
                            .font(.headline)
                            .foregroundStyle(.secondary)

                    default:
                        Text(previousTitle)
                            .font(.headline)
                            .foregroundStyle(.secondary.opacity(0.5))
                    }
                } else {
                    Text(title)
                        .font(.headline)
                        .foregroundStyle(.primary)
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
