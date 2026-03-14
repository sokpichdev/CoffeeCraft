//
//  LiveBadge.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 3/14/26.
//
import SwiftUI

struct LiveBadge: View {
    @State private var pulse = false
    
    var body: some View {
        HStack(spacing: 5) {
            Circle()
                .fill(Color.semanticError)
                .frame(width: 7, height: 7)
                .scaleEffect(pulse ? 1.4 : 1.0)
                .animation(.easeInOut(duration: 0.85).repeatForever(autoreverses: true),
                           value: pulse)
                .onAppear { pulse = true }
            Text("LIVE")
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(Color.semanticError)
                .tracking(0.8)
        }
        .padding(.horizontal, 9)
        .padding(.vertical, 5)
        .background(Color.semanticError.opacity(0.10), in: Capsule())
        .overlay(Capsule().stroke(Color.semanticError.opacity(0.25), lineWidth: 1))
    }
}
