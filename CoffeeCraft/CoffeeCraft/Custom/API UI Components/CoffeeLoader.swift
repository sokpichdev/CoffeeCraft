//
//  CoffeeLoader.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 1/29/26.
//
import SwiftUI

struct CoffeeLoader: View {
    @State private var fillLevel: CGFloat = 0
    
    var body: some View {
        ZStack {
            // Filled coffee cup (clipped to show fill level)
            Image(systemName: "cup.and.saucer.fill")
                .font(.system(size: 50))
                .foregroundColor(.coffeeBrown)
                .mask(
                    VStack {
                        Spacer()
                        Rectangle()
                            .frame(height: 50 * fillLevel)
                    }
                    .frame(height: 50)
                )
            
            // Cup outline (always visible)
            Image(systemName: "cup.and.saucer")
                .font(.system(size: 50))
                .foregroundColor(.coffeeBrown.opacity(0.3))
        }
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.coffeeCream)
                .shadow(color: .black.opacity(0.1), radius: 20, y: 10)
        )
        .onAppear {
            withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                fillLevel = 1.2
            }
        }
    }
}
