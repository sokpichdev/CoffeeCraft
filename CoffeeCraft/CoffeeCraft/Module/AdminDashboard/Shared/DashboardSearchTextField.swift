//
//  DashboardSearchTextField.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 3/14/26.
//

import SwiftUI

struct DashboardSearchTextField: View {
    let placeholder: String
    @Binding var text: String
    var onSubmit: () -> Void
    var onClear: () -> Void

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 14))
                .foregroundStyle(Color.textMuted)

            TextField(placeholder, text: $text)
                .autocorrectionDisabled()
                .font(.subheadline)
                .onSubmit {
                    onSubmit()
                }

            if !text.isEmpty {
                Button {
                    text = ""
                    onClear()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(Color.textMuted)
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(
            Color.surfaceSub,
            in: RoundedRectangle(cornerRadius: 12)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.borderColor, lineWidth: 1)
        )
    }
}
