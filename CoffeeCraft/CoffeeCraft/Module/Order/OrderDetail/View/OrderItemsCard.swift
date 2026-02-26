//
//  OrderItemsCard.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 2/24/26.
//
import SwiftUI

struct OrderItemsCard: View {
    let items: [CartItemData]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Items")
                    .font(.title3).fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text("\(items.count) item\(items.count == 1 ? "" : "s")")
                    .font(.subheadline).fontWeight(.medium)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.secondary.opacity(0.1))
                    .cornerRadius(12)
            }
            
            VStack(spacing: 16) {
                ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                    OrderItemRow(item: item, isLast: index == items.count - 1)
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color(.secondarySystemGroupedBackground))
                .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 4)
        )
    }
}


struct OrderItemRow: View {
    let item: CartItemData
    let isLast: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                AsyncImageCard(imageURL: item.imageURL, height: 56, width: 56, corner: 12)
                
                VStack(alignment: .leading, spacing: 6) {
                    Text(item.name)
                        .font(.body).fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    // Selections
                    if let selections = item.selections, !selections.isEmpty {
                        VStack(alignment: .leading, spacing: 4) {
                            ForEach(selections.sorted(by: { $0.key < $1.key }), id: \.key) { key, value in
                                HStack(spacing: 4) {
                                    Text("•")
                                        .foregroundColor(.secondary)
                                    Text(key)
                                        .font(.system(size: 13))
                                        .foregroundColor(.secondary)
                                    Text("·")
                                        .foregroundColor(.secondary.opacity(0.5))
                                    Text(value)
                                        .font(.system(size: 13, weight: .medium))
                                        .foregroundColor(.primary.opacity(0.8))
                                }
                            }
                        }
                    }
                    
                    // Extras
                    if let extras = item.extras, !extras.isEmpty {
                        HStack(spacing: 4) {
                            Text("• Extras:")
                                .font(.footnote)
                                .foregroundColor(.secondary)
                            Text(extras.joined(separator: ", "))
                                .font(.footnote).fontWeight(.medium)
                                .foregroundColor(.primary.opacity(0.8))
                        }
                    }
                }
                
                Spacer()
                
                Text("$\(item.price, specifier: "%.2f")")
                    .font(.body).fontWeight(.bold)
                    .foregroundColor(.coffeeCream)
            }
            
            if !isLast {
                Divider()
                    .background(Color.secondary.opacity(0.15))
                    .padding(.leading, 72)
            }
        }
    }
}
