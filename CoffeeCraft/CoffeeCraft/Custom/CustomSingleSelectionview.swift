//
//  CustomSingleSelectionview.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 11/1/25.
//
import SwiftUI

struct CustomSingleSelectionview: View {
    var title: String
    var options: [String]
    @Binding var selected: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title).font(.headline)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(options, id: \.self) { option in
                        Text(option)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 16)
                            .background(selected == option ? Color.brown : Color.gray.opacity(0.2))
                            .foregroundColor(selected == option ? .white : .primary)
                            .cornerRadius(12)
                            .onTapGesture { selected = option }
                    }
                }
            }
        }
    }
}
