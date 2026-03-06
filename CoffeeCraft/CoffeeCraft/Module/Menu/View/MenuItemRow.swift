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
        HStack(alignment: .top) {
            VStack(alignment: .leading) {
                Text(item.name)
                    .font(.headline)
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)
                    .minimumScaleFactor(0.5) // allow shrinking if needed
                    .foregroundColor(.textPrimary)
                Text("$\(item.price, specifier: "%.2f")")
                    .foregroundColor(.textSecondary)
            }
            Spacer()
            AsyncImageCard(imageURL: item.imageURL, height: 78, width: 78, corner: 12)
        }
        .padding(8)
        .frame(height: 90)
        .background {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.surfacePrimary)
                .overlay {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .strokeBorder(Color.border.opacity(0.5), lineWidth: 0.5)
                }
                .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 2)
        }
    }
}
