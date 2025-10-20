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
