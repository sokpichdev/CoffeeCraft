//
//  CustomSecureField.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 11/1/25.
//
import SwiftUI

struct CustomSecureField: View {
    var title: String
    @Binding var text: String
    var icon: String = ""

    var body: some View {
        HStack {
            if !icon.isEmpty {
                Image(systemName: icon)
                    .foregroundColor(.brown)
            }
            SecureField(title, text: $text)
        }
        .padding()
        .background(.white.opacity(0.9))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
