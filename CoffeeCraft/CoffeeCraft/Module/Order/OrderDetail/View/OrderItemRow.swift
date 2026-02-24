//
//  OrderItemRow.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 2/24/26.
//
import SwiftUI

struct OrderItemRow: View {
    let item: CartItemData
    let isLast: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                // Item icon/placeholder
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.brown.opacity(0.1))
                        .frame(width: 56, height: 56)
                    
                    Image(systemName: "cup.and.saucer.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.coffeeDarkBrown)
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    Text(item.name)
                        .font(.system(size: 17, weight: .semibold))
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
                                .font(.system(size: 13))
                                .foregroundColor(.secondary)
                            Text(extras.joined(separator: ", "))
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(.primary.opacity(0.8))
                        }
                    }
                }
                
                Spacer()
                
                Text("$\(item.price, specifier: "%.2f")")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(.coffeeDarkBrown)
            }
            
            if !isLast {
                Divider()
                    .background(Color.secondary.opacity(0.15))
                    .padding(.leading, 72)
            }
        }
    }
}
