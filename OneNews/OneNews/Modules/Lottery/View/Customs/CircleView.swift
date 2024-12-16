//
//  CircleView.swift
//  OneNews
//
//  Created by Sok Pich on 12/12/24.
//

import SwiftUI

struct CircleView: View {
    @State var number: Int = 0
    var body: some View {
        Circle()
            .fill(Color.white)
            .frame(width: 30, height: 30)
            .overlay(
                Text("\(number)")
                    .font(.caption)
                    .foregroundColor(.black)
            )
            .overlay(
                Circle()
                    .stroke(Color.white.opacity(0.2), lineWidth: 10) // Adds a border
            )
            .shadow(radius: 10) // Adds a shadow
    }
}

struct CircleResult: View {
    @State var number: Int = 0
    var body: some View {
        Circle()
            .fill(Color.percentage)
            .frame(width: 35, height: 35)
            .overlay(
                Text("\(number)")
                    .font(.caption)
                    .foregroundColor(.letters)
            )
            .overlay(
                Circle()
                    .stroke(Color.main, lineWidth: 1) // Adds a border
            )
            .shadow(radius: 2, y: 4) // Adds a shadow
    }
}
