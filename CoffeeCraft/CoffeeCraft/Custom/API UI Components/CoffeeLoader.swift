//
//  CoffeeLoader.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 1/29/26.
//
import SwiftUI

struct CoffeeLoader: View {
    @State private var fillLevel: CGFloat = 0
    @State private var steamOffset: [CGFloat] = [0, 0, 0]
    @State private var currentFactIndex = 0
    @State private var glowOpacity: Double = 0.3
    
    let coffeeFacts = [
        "Coffee beans are actually seeds...",
        "Espresso means 'pressed out' in Italian",
        "Coffee is the second most traded commodity",
        "A coffee tree can live up to 100 years",
        "The most expensive coffee comes from civet poop"
    ]
    
    var body: some View {
        VStack(spacing: 20) {
            ZStack {
                // Glow effect
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color.coffeeBrown.opacity(glowOpacity), .clear],
                            center: .center,
                            startRadius: 20,
                            endRadius: 60
                        )
                    )
                    .frame(width: 120, height: 120)
                    .onAppear {
                        withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                            glowOpacity = 0.6
                        }
                    }
                
                // Coffee cup with fill animation
                ZStack(alignment: .bottom) {
                    // Cup outline
                    Image(systemName: "cup.and.saucer")
                        .font(.system(size: 50))
                        .foregroundColor(.coffeeBrown)
                    
                    // Coffee fill
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [Color.coffeeBrown, Color.coffeeBrown.opacity(0.7)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(width: 30, height: 25 * fillLevel)
                        .offset(y: -8)
                        .mask(
                            Image(systemName: "cup.and.saucer.fill")
                                .font(.system(size: 50))
                        )
                    
                    // Steam particles
                    ForEach(0..<3, id: \.self) { index in
                        SteamParticle(offset: $steamOffset[index])
                            .offset(x: CGFloat(index - 1) * 8, y: -35)
                    }
                }
            }
            .frame(height: 120)
            
            // Loading text with animated dots
            HStack(spacing: 4) {
                Text("Brewing your coffee")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.coffeeBrown)
                
                AnimatedDots()
            }
            
            // Coffee facts
            Text(coffeeFacts[currentFactIndex])
                .font(.caption)
                .foregroundColor(.coffeeBrown.opacity(0.7))
                .multilineTextAlignment(.center)
                .frame(height: 30)
                .transition(.opacity.combined(with: .scale(scale: 0.9)))
                .id(currentFactIndex)
        }
        .padding(32)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.coffeeLight)
                .shadow(color: .black.opacity(0.1), radius: 20, y: 10)
        )
        .onAppear {
            startAnimations()
        }
    }
    
    private func startAnimations() {
        // Fill animation
        withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
            fillLevel = 1.0
        }
        
        // Steam animations
        for i in 0..<3 {
            withAnimation(
                .easeOut(duration: 2)
                .repeatForever(autoreverses: false)
                .delay(Double(i) * 0.3)
            ) {
                steamOffset[i] = -30
            }
        }
        
        // Rotate coffee facts
        Timer.scheduledTimer(withTimeInterval: 3, repeats: true) { _ in
            withAnimation(.easeInOut(duration: 0.5)) {
                currentFactIndex = (currentFactIndex + 1) % coffeeFacts.count
            }
        }
    }
}

struct SteamParticle: View {
    @Binding var offset: CGFloat
    @State private var opacity: Double = 0
    
    var body: some View {
        Circle()
            .fill(Color.gray.opacity(opacity))
            .frame(width: 6, height: 6)
            .blur(radius: 2)
            .offset(y: offset)
            .onAppear {
                withAnimation(.easeOut(duration: 2).repeatForever(autoreverses: false)) {
                    opacity = 0.5
                }
                
                // Reset steam particle
                Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { _ in
                    offset = 0
                    opacity = 0
                    
                    withAnimation(.easeOut(duration: 2)) {
                        opacity = 0.5
                    }
                }
            }
    }
}

struct AnimatedDots: View {
    @State private var dotCount = 0
    
    var body: some View {
        HStack(spacing: 2) {
            ForEach(0..<3) { index in
                Text(".")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.coffeeBrown)
                    .opacity(index < dotCount ? 1 : 0.3)
            }
        }
        .onAppear {
            Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
                dotCount = (dotCount + 1) % 4
            }
        }
    }
}
