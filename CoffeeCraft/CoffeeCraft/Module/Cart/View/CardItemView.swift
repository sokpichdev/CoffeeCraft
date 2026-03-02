//
//  CardItemView.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 11/1/25.
//
import SwiftUI

struct CardItemView: View {
    let item: CartItem
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            AsyncImageCard(imageURL: item.product.imageURL, height: 60, width: 60, corner: 10)
            
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 4) {
                    if item.quantity > 1 {
                        Text("×\(item.quantity)")
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundColor(.coffeeBrown)
                    }
                    Text(item.product.name)
                        .font(.subheadline)
                        .fontWeight(.bold)
                }

                if !item.selections.isEmpty {
                    ForEach(item.selections.keys.sorted(), id: \.self) { key in
                        if let value = item.selections[key], !value.isEmpty {
                            Text("\(key): \(value)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                }

                if !item.extras.isEmpty {
                    Text("Extras: \(item.extras.joined(separator: ", "))")
                        .font(.caption2)
                        .foregroundColor(.gray)
                }
            }
            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text(String(format: "$%.2f", item.totalPrice))
                    .font(.subheadline.bold())

                // Show unit price if qty > 1
                if item.quantity > 1 {
                    Text(String(format: "$%.2f ea", item.totalPrice / Double(item.quantity))) /// ea = each
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(Color(.tertiarySystemBackground))
        .cornerRadius(14)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}
