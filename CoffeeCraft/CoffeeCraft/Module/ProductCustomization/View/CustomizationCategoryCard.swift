//
//  CustomizationCategoryCard.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 1/17/26.
//
import SwiftUI

struct CustomizationCategoryCard: View {
    @Binding var category: CustomizationCategory
    let onDelete: () -> Void
    
    @State private var isExpanded = true
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            Button(action: {
                withAnimation(.spring(response: 0.3)) {
                    isExpanded.toggle()
                }
            }) {
                HStack {
                    Image(systemName: "folder.fill")
                        .foregroundColor(.brown)
                        .font(.title3)
                    
                    TextField("Category name", text: $category.name)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Text("\(category.options.count)")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Capsule().fill(Color.brown))
                    
                    Button(action: onDelete) {
                        Image(systemName: "trash.fill")
                            .foregroundColor(.red)
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(.secondary)
                        .font(.caption)
                }
                .padding()
            }
            .buttonStyle(PlainButtonStyle())
            
            if isExpanded {
                Divider()
                
                // Options list
                VStack(spacing: 12) {
                    ForEach($category.options) { $option in
                        CustomizationOptionRow(
                            option: $option,
                            onDelete: {
                                withAnimation {
                                    if let index = category.options.firstIndex(where: { $0.id == option.id }) {
                                        category.options.remove(at: index)
                                    }
                                }
                            }
                        )
                    }
                    
                    // Add option button
                    Button(action: {
                        withAnimation {
                            category.options.append(CustomizationOption(name: "", price: 0.0))
                        }
                    }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(.brown)
                            Text("Add Option")
                                .fontWeight(.medium)
                                .foregroundColor(.brown)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.brown.opacity(0.1))
                        )
                    }
                }
                .padding()
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        )
    }
}
