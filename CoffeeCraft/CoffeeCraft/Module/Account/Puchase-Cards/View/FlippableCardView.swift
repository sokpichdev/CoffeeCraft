//
//  FlippableCardView.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 1/21/26.
//
import SwiftUI

struct FlippableCardView: View {
    let card: LoyaltyCard
    let width: CGFloat
    let aspectRatio: CGFloat = 16 / 9
    
    private var cardHeight: CGFloat {
        width / aspectRatio
    }
    
    // MARK: - State
    @State private var rotationY: Double = 0
    @State private var liveDragRotation: Double = 0
    @State private var tapScale: CGFloat = 1.0
    
    private let flipThreshold: CGFloat = 50
    
    private var flipScale: CGFloat {
        let totalRotation = rotationY + liveDragRotation
        let normalized = abs(totalRotation.truncatingRemainder(dividingBy: 180))
        let progress = normalized / 90     // 0 → 1
        let clamped = min(progress, 1)
        
        // 1.0 → 0.94 → 1.0
        return tapScale - (0.15 * clamped)
    }
    
    var body: some View {
        ZStack {
            frontView
                .opacity(isFrontFaceVisible ? 1 : 0)
            
            backView
                .opacity(isBackFaceVisible ? 1 : 0)
                .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
        }
        .cornerRadius(10)
        .scaleEffect(flipScale)
        .frame(width: width, height: cardHeight)
        .rotation3DEffect(
            .degrees(rotationY + liveDragRotation),
            axis: (x: 0, y: 1, z: 0),
            perspective: 0.2
        )
        .contentShape(Rectangle())
        .gesture(
            DragGesture(minimumDistance: 20)
                .onChanged { gesture in
                    if abs(gesture.translation.width) > abs(gesture.translation.height) {
                        liveDragRotation = gesture.translation.width * 0.5
                    } else {
                        liveDragRotation = 0
                    }
                }
                .onEnded { gesture in
                    let swipe = gesture.translation.width
                    if abs(swipe) > abs(gesture.translation.height),
                       abs(swipe) > flipThreshold {
                        rotationY += swipe > 0 ? 180 : -180
                    }
                    liveDragRotation = 0
                }
        )
        .onTapGesture {
            // Phase 1 — zoom out
            withAnimation(.easeOut(duration: 0.1)) {
                tapScale = 0.85
            }
            
            // Phase 2 — rotate at minimum scale
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.easeInOut(duration: 0.3)) {
                    rotationY += 180
                }
            }
            
            // Phase 3 — zoom back in after midpoint
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    tapScale = 1.0
                }
            }
        }
        .animation(.spring(response: 0.5, dampingFraction: 0.7), value: rotationY)
        .animation(.interactiveSpring(response: 0.2, dampingFraction: 0.5), value: liveDragRotation)
    }
    
    // MARK: - Visibility Helpers
    private var isFrontFaceVisible: Bool {
        let total = (rotationY + liveDragRotation)
            .truncatingRemainder(dividingBy: 360)
        let normalized = total < 0 ? total + 360 : total
        return normalized < 90 || normalized > 270
    }
    
    private var isBackFaceVisible: Bool {
        !isFrontFaceVisible
    }
    
    // MARK: - Front (uses LoyaltyCard properties directly)
    private var frontView: some View {
        cardBase {
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: [Color(red: 0.4, green: 0.25, blue: 0.15), Color(red: 0.25, green: 0.15, blue: 0.1)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                
                // Coffee bean pattern overlay
                VStack {
                    HStack(spacing: width * 0.08) {
                        ForEach(0..<5) { _ in
                            Image(systemName: "circle.fill")
                                .resizable()
                                .frame(width: width * 0.03, height: width * 0.03)
                                .foregroundStyle(.white.opacity(0.05))
                        }
                    }
                    .padding(.top, cardHeight * 0.1)
                    Spacer()
                }
                
                VStack(alignment: .leading, spacing: cardHeight * 0.08) {
                    // Logo and shop name
                    HStack {
                        Image(systemName: "cup.and.saucer.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: width * 0.12, height: width * 0.12)
                            .foregroundStyle(.white)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("CRAFT CAFÉ")
                                .font(.system(size: width * 0.055, weight: .bold, design: .rounded))
                                .foregroundStyle(.white)
                            Text("Loyalty Card")
                                .font(.system(size: width * 0.028, weight: .medium))
                                .foregroundStyle(.white.opacity(0.8))
                        }
                        
                        Spacer()
                        
                        // Chip icon
                        Image(systemName: "wave.3.right")
                            .resizable()
                            .scaledToFit()
                            .frame(width: width * 0.08)
                            .foregroundStyle(Color.yellow.opacity(0.9))
                    }
                    
                    Spacer()
                    
                    Text(formatCardNumber(card.cardNumber))
                        .font(.system(size: width * 0.045, weight: .semibold, design: .monospaced))
                        .foregroundStyle(.white)
                        .tracking(width * 0.008)
                    
                    // Member info - Dynamic from active card
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("MEMBER")
                                .font(.system(size: width * 0.022, weight: .medium))
                                .foregroundStyle(.white.opacity(0.6))
                            Text(card.ownerName)
                                .font(.system(size: width * 0.035, weight: .semibold))
                                .foregroundStyle(.white)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 2) {
                            Text("MEMBER SINCE")
                                .font(.system(size: width * 0.022, weight: .medium))
                                .foregroundStyle(.white.opacity(0.6))
                            Text(card.memberSince)
                                .font(.system(size: width * 0.035, weight: .semibold))
                                .foregroundStyle(.white)
                        }
                    }
                }
                .padding(width * 0.08)
            }
        }
    }
    
    // MARK: - Back
    private var backView: some View {
        cardBase {
            ZStack {
                // Background
                LinearGradient(
                    colors: [Color(red: 0.35, green: 0.22, blue: 0.12), Color(red: 0.25, green: 0.15, blue: 0.1)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                
                VStack(spacing: 0) {
                    // Magnetic stripe
                    Rectangle()
                        .fill(Color.black)
                        .frame(height: cardHeight * 0.12)
                        .frame(maxWidth: .infinity)
                    
                    VStack(alignment: .leading, spacing: cardHeight * 0.05) {
                        // Rewards tracker
                        VStack(alignment: .leading, spacing: cardHeight * 0.03) {
                            Text("REWARDS TRACKER")
                                .font(.system(size: width * 0.028, weight: .semibold))
                                .foregroundStyle(.white.opacity(0.8))
                            
                            // Coffee stamp grid - Uses card.points
                            VStack(spacing: cardHeight * 0.025) {
                                ForEach(0..<2) { row in
                                    HStack(spacing: width * 0.025) {
                                        ForEach(0..<5) { col in
                                            let index = row * 5 + col
                                            ZStack {
                                                Circle()
                                                    .stroke(Color.white.opacity(0.3), lineWidth: 1.5)
                                                    .frame(width: width * 0.06, height: width * 0.06)
                                                
                                                if index < card.points {
                                                    Image(systemName: "cup.and.saucer.fill")
                                                        .resizable()
                                                        .scaledToFit()
                                                        .frame(width: width * 0.035)
                                                        .foregroundStyle(Color.orange)
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                            
                            Text("\(10 - card.points) more for a FREE drink!")
                                .font(.system(size: width * 0.028, weight: .medium))
                                .foregroundStyle(Color.orange)
                        }
                        
                        // Barcode
                        VStack(spacing: cardHeight * 0.015) {
                            // Simulated barcode
                            HStack(spacing: 1) {
                                ForEach(0..<30) { i in
                                    Rectangle()
                                        .fill(Color.black)
                                        .frame(width: i % 3 == 0 ? 2 : 1.5, height: cardHeight * 0.1)
                                }
                            }
                            .background(Color.white)
                            .cornerRadius(3)
                            
                            Text("1029384756102938")
                                .font(.system(size: width * 0.023, weight: .medium, design: .monospaced))
                                .foregroundStyle(.white.opacity(0.7))
                        }
                        
                        // Customer service
                        HStack {
                            Image(systemName: "phone.fill")
                                .font(.system(size: width * 0.023))
                            Text("1-800-CRAFT-CAFE")
                                .font(.system(size: width * 0.023, weight: .medium))
                            
                            Spacer()
                            
                            Image(systemName: "globe")
                                .font(.system(size: width * 0.023))
                            Text("Craftcafe.com")
                                .font(.system(size: width * 0.023, weight: .medium))
                        }
                        .foregroundStyle(.white.opacity(0.6))
                    }
                    .padding(.horizontal, width * 0.08)
                    .padding(.vertical, cardHeight * 0.06)
                }
            }
        }
    }

    // MARK: - Card Styling
    private func cardBase<Content: View>(
        @ViewBuilder content: () -> Content
    ) -> some View {
        content()
            .frame(width: width, height: cardHeight)
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.15), radius: 6, x: 0, y: 3)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.white.opacity(0.2), lineWidth: 0.5)
            )
    }
    
    // MARK: - Helper
    private func formatCardNumber(_ number: String) -> String {
//        let masked = String(repeating: "*", count: 12) + number.suffix(4)
        var formatted = ""
//        for (index, char) in masked.enumerated() {
//            if index > 0 && index % 4 == 0 {
//                formatted += " "
//            }
//            formatted += String(char)
//        }
        /// this is for later when we use auth to show card number
        for (index, char) in number.enumerated() {
        if index > 0 && index % 4 == 0 {
            formatted += " "
        }
        formatted += String(char)
    }
        return formatted
    }
}
