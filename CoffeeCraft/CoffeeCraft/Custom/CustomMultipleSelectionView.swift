//
//  CustomMultipleSelectionView.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 11/1/25.
//
import SwiftUI

struct CustomMultipleSelectionView: View {
    let title: String
    let options: [String: Double]
    @Binding var selected: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title).font(.headline)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(options.keys.sorted(), id: \.self) { option in
                        let price = options[option] ?? 0
                        VStack(spacing: 4) {
                            Text(option)
                                .padding(.vertical, 8)
                                .padding(.horizontal, 16)
                                .background(selected.contains(option) ? Color.brown : Color.gray.opacity(0.2))
                                .foregroundColor(selected.contains(option) ? .white : .primary)
                                .cornerRadius(12)
                                .onTapGesture {
                                    if selected.contains(option) {
                                        selected.removeAll { $0 == option }
                                    } else {
                                        selected.append(option)
                                    }
                                }
                            if price > 0 {
                                Text("$\(price, specifier: "%.2f")")
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
    }
}
