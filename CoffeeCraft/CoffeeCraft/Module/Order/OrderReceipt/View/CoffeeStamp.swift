//
//  CoffeeStamp.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 2/26/26.
//
import SwiftUI

struct CoffeeStamp: View {
    let animated: Bool
    @State private var stamped = false
    
    var body: some View {
        ZStack {
            Circle()
                .strokeBorder(Color.coffeeDarkBrown.opacity(0.25), lineWidth: 2)
                .frame(width: 90, height: 90)
            Circle()
                .strokeBorder(Color.coffeeDarkBrown.opacity(0.15), lineWidth: 1)
                .frame(width: 76, height: 76)
            VStack(spacing: 2) {
                Image(systemName: "cup.and.saucer.fill")
                    .font(.title)
                    .foregroundColor(Color.coffeeDarkBrown.opacity(0.5))
                Text("COFFEECRAFT")
                    .font(.caption2).fontWeight(.heavy).fontDesign(.monospaced)
                    .foregroundColor(Color.coffeeDarkBrown.opacity(0.4))
                    .tracking(2)
            }
        }
        .rotationEffect(.degrees(stamped ? -12 : -8))
        .scaleEffect(stamped ? 1 : 0.4)
        .opacity(stamped ? 1 : 0)
        .onAppear {
            if animated {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.6).delay(0.3)) {
                    stamped = true
                }
            } else {
                stamped = true
            }
        }
    }
}
