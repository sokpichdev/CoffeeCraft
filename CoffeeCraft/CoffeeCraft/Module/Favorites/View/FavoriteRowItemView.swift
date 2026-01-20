//
//  FavoriteRowItemView.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 1/16/26.
//
import SwiftUI

struct FavoriteRowItemView: View {
    let item: FavoriteItem
    
    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 6) {
                Text(item.productName)
                    .font(.headline)
                    .lineLimit(1)
                
                if !item.customizations.isEmpty {
                    Text(item.customizations.map { "\($0.value)" }.joined(separator: ", "))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                Text(String(format: "$%.2f", item.basePrice))
                    .font(.subheadline)
                    .bold()
                    .foregroundColor(.brown)
            }
            
            Spacer()
            AsyncImageCard(imageURL: item.imageURL, height: 80, width: 80, corner: 10)
                .shadow(radius: 2)
        }
        .padding(8)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 2)
    }
}
