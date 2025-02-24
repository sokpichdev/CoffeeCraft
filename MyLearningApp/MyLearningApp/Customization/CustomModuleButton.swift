//
//  CustomModuleButton.swift
//  MyLearningApp
//
//  Created by Sok Pich on 2/10/25.
//

import SwiftUI

// MARK: - Custom Button Component
struct CustomModuleButton: View {
    let name: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(name)
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity, minHeight: 60)
                .background(color.gradient)
                .cornerRadius(12)
                .shadow(color: color.opacity(0.5), radius: 5, x: 0, y: 5)
                .scaleEffect(1.0)
                .animation(.spring(), value: 1.0)
        }
        .padding(.horizontal, 10)
    }
}
