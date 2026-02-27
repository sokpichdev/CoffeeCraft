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

                    if let selections = item.selections, !selections.isEmpty {
                        VStack(alignment: .leading, spacing: 2) {
                            ForEach(selections.sorted(by: { $0.key < $1.key }), id: \.key) { key, value in
                                HStack(alignment: .top, spacing: 4) {
                                    Text("\(key):")
                                        .font(.caption2)
                                        .fontWeight(.semibold)
                                        .fontDesign(.monospaced)
                                        .foregroundColor(Color.coffeeDarkBrown.opacity(0.4))

                                    Text(value)
                                        .font(.caption2)
                                        .fontDesign(.monospaced)
                                        .foregroundColor(Color.coffeeDarkBrown.opacity(0.7))
                                }
                            }
                        }
                    }

                    if let extras = item.extras, !extras.isEmpty {
                        HStack(alignment: .top, spacing: 4) {
                            Text("Extras:")
                                .font(.caption2)
                                .fontDesign(.monospaced)
                                .foregroundColor(Color.coffeeDarkBrown.opacity(0.4))

                            Text(extras.joined(separator: ", "))
                                .font(.caption2)
                                .fontDesign(.monospaced)
                                .foregroundColor(Color.coffeeDarkBrown.opacity(0.7))
                        }
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
