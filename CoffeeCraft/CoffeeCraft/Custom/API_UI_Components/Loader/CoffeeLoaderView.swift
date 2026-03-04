//
//  CoffeeLoaderView.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 1/29/26.
//
import SwiftUI

struct CoffeeLoaderView: View {
    
    var progress: CGFloat? = nil
    
    @State private var fillLevel: CGFloat = 0
    @State private var waveOffset1: CGFloat = 0
    @State private var waveOffset2: CGFloat = 0
    @State private var waveOffset3: CGFloat = 0
    @State private var waveIntensity: CGFloat = 1.0

    var imageSize: CGFloat = 60
    
    var body: some View {
        ZStack {
            // Filled coffee cup (clipped to show fill level with wave)
            Image("custom.cofee.fill")
                .foregroundColor(.coffeeOliveGreen)
            Image("custom.saucer.fill")
                .foregroundColor(.coffeeBrown)
            Image("custom.cup.fill")
                .foregroundColor(.coffeeDarkBrown)
        }
        .font(.system(size: imageSize))
        .mask(
            VStack {
                Spacer()
                ZStack {
                    // Layer 1 - Bottom wave (slowest, largest)
                    WaveShape(offset: waveOffset1, percent: progress ?? fillLevel, amplitude: 6 * waveIntensity)
                    .fill(Color.accentPrimary.opacity(0.3))
                    
                    // Layer 2 - Middle wave (medium speed)
                    WaveShape(offset: waveOffset2, percent: progress ?? fillLevel, amplitude: 5 * waveIntensity)
                    .fill(Color.accentPrimary.opacity(0.7))
                    
                    // Layer 3 - Top wave (fastest, smallest)
                    WaveShape(offset: waveOffset3, percent: progress ?? fillLevel, amplitude: 4 * waveIntensity)
                    .fill(Color.accentPrimary)
                }
                .frame(height: imageSize * (progress ?? fillLevel))
            }
            .frame(height: imageSize)
        )
        .padding(8)
        .background(
            ZStack {
                // Cup outline (always visible)
                Image("custom.cup")
                Image("custom.saucer.fill")
            }
            .foregroundColor(.coffeeDarkBrown.opacity(0.5))
            .font(.system(size: imageSize))
        )
        .onChange(of: progress) { oldValue, newValue in
            if let newValue = newValue {
                // Control wave intensity based on progress
                // More progress = calmer waves, less progress = more intense waves, 0.5 so it's not too calm
                let targetIntensity = max(0.5, 1.0 - (newValue * 0.5))
                withAnimation(.easeInOut(duration: 0.3)) {
                    waveIntensity = targetIntensity
                }
            } else {
                // Reset to normal intensity when no progress
                withAnimation(.easeInOut(duration: 0.3)) {
                    waveIntensity = 1.0
                }
            }
        }
        .onAppear {
            if progress == nil {
                withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                    fillLevel = 1.2
                }
            }
            
            // Three different wave animations
            withAnimation(.linear(duration: 2).repeatForever(autoreverses: false)) {
                waveOffset1 = 1
            }
            withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                waveOffset2 = 1
            }
            withAnimation(.linear(duration: 1).repeatForever(autoreverses: false)) {
                waveOffset3 = 1
            }
        }
    }
}

struct WaveShape: Shape {
    var offset: CGFloat
    var percent: CGFloat
    var amplitude: CGFloat = 4
    
    var animatableData: AnimatablePair<CGFloat, CGFloat> {
        get { AnimatablePair(offset, percent) }
        set {
            offset = newValue.first
            percent = newValue.second
        }
    }
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let waveHeight: CGFloat = amplitude
        let wavelength = rect.width
        
        path.move(to: CGPoint(x: 0, y: rect.height))
        
        for x in stride(from: 0, through: rect.width, by: 1) {
            let relativeX = x / wavelength
            let sine = sin((relativeX + offset) * 2 * .pi)
            let y = waveHeight * sine
            path.addLine(to: CGPoint(x: x, y: y))
        }
        
        path.addLine(to: CGPoint(x: rect.width, y: rect.height))
        path.addLine(to: CGPoint(x: 0, y: rect.height))
        path.closeSubpath()
        
        return path
    }
}
