//
//  ProductCardView.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 10/20/25.
//
import SwiftUI
import SDWebImageSwiftUI

struct ProductCardView: View {
    let product: Product
    let cardHeight: CGFloat = 240 // Fixed height for all cards

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            WebImage(url: URL(string: product.imageURL))
                .resizable()
                .scaledToFill()
                .frame(width: 140, height: 140)
                .clipShape(RoundedRectangle(cornerRadius: 16))

            // Flexible text area
            VStack(alignment: .leading, spacing: 4) {
                Text(product.name)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                    .lineLimit(2)   // limit lines to prevent overflow

                Text("$\(product.price, specifier: "%.2f")")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .frame(maxHeight: .infinity) // take remaining space
        }
        .padding()
        .frame(width: 160, height: cardHeight) // fixed card height
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(radius: 2)
    }
}

// MARK: - Menu Item Row
struct MenuItemRow: View {
    let item: MenuItem

    var body: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 6) {
                Text(item.name)
                    .font(.system(size: 16, weight: .semibold))
                Text(String(format: "$%.2f", item.price))
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }
            Spacer()
            WebImage(url: URL(string: item.image))
                .resizable()
                .scaledToFill()
                .frame(width: 80, height: 80)
                .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .padding()
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 15))
        .shadow(color: .gray.opacity(0.1), radius: 3, x: 0, y: 1)
    }
}
