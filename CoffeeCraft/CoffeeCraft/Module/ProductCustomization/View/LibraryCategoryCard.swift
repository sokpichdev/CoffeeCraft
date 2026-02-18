//
//  LibraryCategoryCard.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 1/17/26.
//
import SwiftUI

struct LibraryCategoryCard: View {
    let category: CustomizationCategory
    let isSelected: Bool
    let onToggle: () -> Void
    
    @State private var showDetails = false
    
    var body: some View {
        VStack(spacing: 0) {
            Button(action: onToggle) {
                HStack {
                    // Icon and info
                    HStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(isSelected ? Color.brown : Color.brown.opacity(0.2))
                                .frame(width: 50, height: 50)
                            
                            Image(systemName: isSelected ? "checkmark" : "folder.fill")
                                .font(.title3)
                                .foregroundColor(isSelected ? .white : .brown)
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(category.name)
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            Text("\(category.options.count) options available")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Spacer()
                    
                    // Show details button
                    Button(action: {
                        withAnimation {
                            showDetails.toggle()
                        }
                    }) {
                        Image(systemName: showDetails ? "chevron.up.circle.fill" : "info.circle.fill")
                            .font(.title2)
                            .foregroundColor(Color.brown)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding()
            }
            .buttonStyle(PlainButtonStyle())
            
            if showDetails {
                Divider()
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Options:")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                    
                    ForEach(category.options) { option in
                        HStack {
                            Text(option.name)
                                .font(.subheadline)
                            Spacer()
                            Text(String(format: "$%.2f", option.price))
                                .font(.caption)
                                .foregroundColor(.brown)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Capsule().fill(Color.brown.opacity(0.1)))
                        }
                    }
                }
                .padding()
                .background(Color(.systemGray6).opacity(0.5))
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(isSelected ? Color.brown : Color.clear, lineWidth: 2)
        )
    }
}
