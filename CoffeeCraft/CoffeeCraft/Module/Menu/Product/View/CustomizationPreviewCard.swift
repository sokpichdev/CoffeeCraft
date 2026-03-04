//
//  CustomizationPreviewCard.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 1/17/26.
//
import SwiftUI

struct CustomizationPreviewCard: View {
    let category: CustomizationCategory
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            Button(action: {
                withAnimation(.spring(response: 0.3)) {
                    isExpanded.toggle()
                }
            }) {
                HStack(spacing: 12) {
                    Image(systemName: "tag.fill")
                        .font(.headline)
                        .foregroundColor(Color.accentPrimary.opacity(0.7))
                    
                    Text(category.name)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Text("\(category.options.count)")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(.brown)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Capsule().fill(Color.accentPrimary.opacity(0.15)))
                    
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.headline)
                        .foregroundColor(Color.accentPrimary)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
            }
            .buttonStyle(PlainButtonStyle())
            
            if isExpanded {
                Divider()
                    .padding(.horizontal, 12)
                
                // Options list
                VStack(spacing: 6) {
                    ForEach(category.options) { option in
                        HStack {
                            HStack(spacing: 6) {
                                Circle()
                                    .fill(Color.accentPrimary.opacity(0.3))
                                    .frame(width: 4, height: 4)
                                
                                Text(option.name)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            if option.price > 0 {
                                Text("$\(String(format: "%.2f", option.price))")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(.brown)
                            } else {
                                Text("Free")
                                    .font(.subheadline)
                                    .foregroundColor(.green)
                            }
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                    }
                }
                .padding(.bottom, 8)
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(.systemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.accentPrimary.opacity(0.2), lineWidth: 1)
        )
    }
}
