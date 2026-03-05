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
                        .foregroundColor(.textPrimary)
                    
                    Spacer()
                    
                    HStack(spacing: 16) {
                        Button(action: onDelete) {
                            Image(systemName: "trash.fill")
                                .foregroundColor(.red)
                                .font(.headline)
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                            .font(.headline)
                            .foregroundColor(Color.accentPrimary)
                    }
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
                    CustomCoffeeButton(title: "Add Option",
                                       buttonImage: "plus.circle.fill",
                                       foregroundColor: Color.accentPrimary,
                                       bgColors: [Color.accentPrimary.opacity(0.1)]) {
                        withAnimation {
                            category.options.append(CustomizationOption(name: "", price: 0.0))
                        }
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
