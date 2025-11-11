//
//  CustomSingleSelectionview.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 11/1/25.
//
import SwiftUI

struct CustomSingleSelectionview: View {
    let title: String
    var sizePrice: Double = 0.0
    let options: [String: Double]
    @Binding var selected: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(Array(options.keys), id: \.self) { option in
                        let price = options[option] ?? 0.0

                        VStack(spacing: 4) {
                            Text(option)
                                .padding(.vertical, 8)
                                .padding(.horizontal, 16)
                                .background(selected == option ? Color.brown : Color.gray.opacity(0.2))
                                .foregroundColor(selected == option ? .white : .primary)
                                .cornerRadius(12)
                                .onTapGesture { selected = option }

                            if price > 0 {
                                Text("$\(price + sizePrice, specifier: "%.2f")")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            } else {
                                Spacer()
                            }
                        }
                    }
                }
            }
        }
        .padding(.vertical, 4)
        .onAppear {
            if let zeroPriceOption = options.first(where: { $1 == 0.0 })?.key {
                selected = zeroPriceOption
            }
        }
    }
}
