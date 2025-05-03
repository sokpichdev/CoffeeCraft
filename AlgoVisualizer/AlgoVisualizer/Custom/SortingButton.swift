//
//  SortingButton.swift
//  AlgoVisualizer
//
//  Created by Sok Pich on 5/3/25.
//

import SwiftUI

// Custom button for sorting algorithms with improved styling
struct SortingButton: View {
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
                .shadow(radius: 3)
        }
    }
}

struct ColoredControlButton: View {
    let title: String
    let action: () -> Void
    let isDisabled: Bool
    let enabledColor: Color
    let disabledColor: Color

    var body: some View {
        Button(action: {
            if !isDisabled {
                action()
            }
        }) {
            Text(title)
                .frame(maxWidth: .infinity)
                .padding()
                .background(isDisabled ? disabledColor : enabledColor)
                .foregroundColor(.white)
                .cornerRadius(8)
                .shadow(radius: isDisabled ? 0 : 3)
        }
        .disabled(isDisabled)
    }
}
