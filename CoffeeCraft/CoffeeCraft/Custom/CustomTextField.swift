//
//  CustomTextField.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 11/1/25.
//
import SwiftUI

struct CustomTextField: View {
    var title: String
    @Binding var text: String
    var icon: String = ""
    var keyboardType: UIKeyboardType = .default

    var body: some View {
        HStack {
            if !icon.isEmpty {
                Image(systemName: icon)
                    .foregroundColor(.accentPrimary)
            }
            TextField(title, text: $text)
                .keyboardType(keyboardType)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
        }
        .padding()
        .background(.white.opacity(0.9))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
