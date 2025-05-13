//
//  ContentView.swift
//  Animation
//
//  Created by Sok Pich on 5/13/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 32) {
                ForEach(0..<8) { index in
                    AnimatedRotatedCard(animationType: index)
                }
            }
            .padding()
        }
    }
}

struct AnimatedRotatedCard: View {
    let animationType: Int
    @State private var offset: CGSize = .zero
    @State private var rotation: Double = 45

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                
                .overlay(
                    GeometryReader { geometry in
                        let cardWidth = geometry.size.width
                        let cardHeight = geometry.size.height
                        
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color.blue)
                            .frame(width: 100, height: 60)
                            .rotationEffect(.degrees(rotation))
                            .offset(offset)
                            .onAppear {
                                animate(cardWidth: cardWidth, cardHeight: cardHeight)
                            }
                    }
                )
                .clipped()
                .frame(width: 300, height: 200)
                .shadow(radius: 5)
        }
    }

    func animate(cardWidth: CGFloat, cardHeight: CGFloat) {
        switch animationType {
        case 0:
            // Left <-> Right
            withAnimation(.linear(duration: 2).repeatForever(autoreverses: true)) {
                offset = CGSize(width: cardWidth - 60, height: 0)
            }

        case 1:
            // Top <-> Bottom
            withAnimation(.linear(duration: 2).repeatForever(autoreverses: true)) {
                offset = CGSize(width: 0, height: cardHeight - 40)
            }

        case 2:
            // Left → Top → Right → Bottom → Left (loop)
            movePath(positions: [
                CGSize(width: -cardWidth + 60, height: 0),
                CGSize(width: 0, height: -cardHeight + 40),
                CGSize(width: cardWidth/2 - 60, height: 0),
                CGSize(width: 0, height: cardHeight/2 - 40),
                CGSize(width: -cardWidth/2 + 60, height: 0)
            ])

        case 3:
            // Right → Top → Left → Bottom → Right (loop)
            movePath(positions: [
                CGSize(width: cardWidth/2 - 60, height: 0),
                CGSize(width: 0, height: -cardHeight/2 + 40),
                CGSize(width: -cardWidth/2 + 60, height: 0),
                CGSize(width: 0, height: cardHeight/2 - 40),
                CGSize(width: cardWidth/2 - 60, height: 0)
            ])

        case 4:
            // Left to Right (wrap instantly)
            DispatchQueue.main.async {
                Timer.scheduledTimer(withTimeInterval: 0.02, repeats: true) { _ in
                    offset.width += 2
                    if offset.width > cardWidth / 2 {
                        offset.width = -cardWidth / 2
                    }
                }
            }

        case 5:
            // Slow continuous spin
            withAnimation(.linear(duration: 8).repeatForever(autoreverses: false)) {
                rotation += 360
            }

        case 6:
            // Bottom-right <-> Top-left
            movePath(positions: [
                CGSize(width: cardWidth/2 - 60, height: cardHeight/2 - 40),
                CGSize(width: -cardWidth/2 + 60, height: -cardHeight/2 + 40)
            ])

        case 7:
            // Bottom-left <-> Top-right
            movePath(positions: [
                CGSize(width: -cardWidth/2 + 60, height: cardHeight/2 - 40),
                CGSize(width: cardWidth/2 - 60, height: -cardHeight/2 + 40)
            ])

        default:
            break
        }
    }

    func movePath(positions: [CGSize], index: Int = 0) {
        guard !positions.isEmpty else { return }
        withAnimation(.easeInOut(duration: 1.5)) {
            offset = positions[index]
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            let next = (index + 1) % positions.count
            movePath(positions: positions, index: next)
        }
    }
}
