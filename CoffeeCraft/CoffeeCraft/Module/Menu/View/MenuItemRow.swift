//
//  MenuItemRow.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 10/20/25.
//
import SwiftUI
import SDWebImageSwiftUI

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
            WebImage(url: URL(string: item.imageURL))
                .resizable()
                .indicator(.activity)
                .frame(width: 60, height: 60)
                .cornerRadius(10)
        }
        .padding(8)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 1)
    }
}

