//
//  ReceiptItemRow.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 2/26/26.
//
import SwiftUI

struct ReceiptItemRow: View {
    let item: CartItemData
    var animationDelay: Double = 0

    @State private var appeared = false

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 3) {
                    Text(item.name)
                        .font(.subheadline).fontDesign(.serif)
                        .foregroundColor(Color.coffeeDarkBrown)

                    if let selections = item.selections {
                        let parts = selections.map { "\($0.key): \($0.value)" }.joined(separator: " · ")
                        Text(parts)
                            .font(.caption2).fontDesign(.monospaced)
                            .foregroundColor(.secondary)
                    }

                    if let extras = item.extras, !extras.isEmpty {
                            Text("Extras: ")
                                .font(.caption).fontDesign(.monospaced)
                                .foregroundColor(.secondary) +
                            Text(extras.joined(separator: " · "))
                                .font(.caption2).fontDesign(.monospaced)
                                .foregroundColor(Color.coffeeDarkBrown.opacity(0.6))
                    }
                }
                Spacer()
                Text("$\(item.price, specifier: "%.2f")")
                    .font(.subheadline).fontWeight(.medium).fontDesign(.monospaced)
                    .foregroundColor(Color.coffeeDarkBrown)
            }
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 6)
        .onAppear {
            withAnimation(.easeOut(duration: 0.35).delay(animationDelay)) {
                appeared = true
            }
        }
    }
}
