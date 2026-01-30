//
//  CoffeeLoaderView.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 1/29/26.
//
import SwiftUI

struct CoffeeLoaderView: View {
    @State private var fillLevel: CGFloat = 0

    var imageSize: CGFloat = 50
    var body: some View {
        ZStack {
            // Filled coffee cup (clipped to show fill level)
            Image(systemName: "cup.and.saucer.fill")
                .font(.system(size: imageSize))
                .foregroundColor(.coffeeOliveGreen)
                .mask(
                    VStack {
                        Spacer()
                        Rectangle()
                            .frame(height: imageSize * fillLevel)
                    }
                    .frame(height: imageSize)
                )
            
            // Cup outline (always visible)
            Image(systemName: "cup.and.saucer")
                .font(.system(size: imageSize))
                .foregroundColor(.coffeeBrown.opacity(0.3))
        }
        .padding(8)
        .background(
            Image(systemName: "cup.and.saucer.fill")
                .font(.system(size: imageSize * 1.1))
                .foregroundColor(.coffeeDarkBrown)
                .shadow(color: .black.opacity(0.1), radius: 20, y: 10)
        )
        .onAppear {
            withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                fillLevel = 1.2
            }
        }
    }
}
