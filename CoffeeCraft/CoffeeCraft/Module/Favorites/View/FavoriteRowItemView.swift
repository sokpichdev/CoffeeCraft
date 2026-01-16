//
//  FavoriteRowItemView.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 1/16/26.
//
import SwiftUI
import SDWebImageSwiftUI

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
            
            WebImage(url: URL(string: item.imageURL))
                .resizable()
                .scaledToFill()
                .frame(width: 80, height: 80)
                .cornerRadius(10)
                .shadow(radius: 2)
        }
        .padding(8)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 2)
    }
}
