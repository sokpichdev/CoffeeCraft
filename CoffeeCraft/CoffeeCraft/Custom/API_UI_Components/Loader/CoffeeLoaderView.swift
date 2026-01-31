//
//  CoffeeLoaderView.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 1/29/26.
//
import SwiftUI

struct CoffeeLoaderView: View {
    @State private var fillLevel: CGFloat = 0
    @State private var waveOffset: CGFloat = 0

    var imageSize: CGFloat = 60
    
    var body: some View {
        ZStack {
            // Filled coffee cup (clipped to show fill level with wave)
            ZStack {
                Image("custom.cofee.fill")
                    .foregroundColor(.coffeeOliveGreen)
                Image("custom.saucer.fill")
                    .foregroundColor(.coffeeCream)
                Image("custom.cup.fill")
                    .foregroundColor(.coffeeDarkBrown)
                
            }
            .font(.system(size: imageSize))
            .mask(
                VStack {
                    Spacer()
                    WaveShape(offset: waveOffset, percent: fillLevel)
                        .fill(Color.black)
                        .frame(height: imageSize * fillLevel)
                }
                    .frame(height: imageSize)
            )
            
            // Cup outline (always visible)
            ZStack {
                Image("custom.cup")
                    .foregroundColor(.coffeeDarkBrown.opacity(0.5))
                Image("custom.saucer.fill")
                    .foregroundColor(.coffeeWarmBrown)
            }
                .font(.system(size: imageSize))
        }
        .padding(8)
        .onAppear {
            withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                fillLevel = 1.2
            }
            withAnimation(.linear(duration: 0.5).repeatForever(autoreverses: false)) {
                waveOffset = 1
            }
        }
    }
}
struct WaveShape: Shape {
    var offset: CGFloat
    var percent: CGFloat
    
    var animatableData: AnimatablePair<CGFloat, CGFloat> {
        get { AnimatablePair(offset, percent) }
        set {
            offset = newValue.first
            percent = newValue.second
        }
    }
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let waveHeight: CGFloat = 4
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
