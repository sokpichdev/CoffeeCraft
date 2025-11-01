//
//  CustomMultipleSelectionView.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 11/1/25.
//
import SwiftUI

struct CustomMultipleSelectionView: View {
    var title: String
    var options: [String]
    @Binding var selected: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title).font(.headline)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(options, id: \.self) { option in
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
                    }
                }
            }
        }
    }
}
