//
//  MenuItemRow.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 10/20/25.
//
import SwiftUI

// MARK: - Menu Item Row
struct MenuItemRow: View {
    let item: Product
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(item.name).font(.headline).multilineTextAlignment(.leading)
                    .foregroundColor(.primary)
                Text("$\(item.price, specifier: "%.2f")")
                    .foregroundColor(.secondary)
            }
            Spacer()
            AsyncImageCard(imageURL: item.imageURL, height: 60, width: 60, corner: 10)
        }
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.coffeeCream.opacity(0.4), lineWidth: 1)
        )
    }
}

