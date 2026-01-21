//
//  FlippableCardView.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 1/21/26.
//
import SwiftUI

struct FlippableCardView: View {

    let width: CGFloat
    let aspectRatio: CGFloat = 16 / 9   // width / height

    private var cardHeight: CGFloat {
        width / aspectRatio
    }

    // MARK: - State
    @State private var rotationY: Double = 0
    @State private var liveDragRotation: Double = 0

    private let flipThreshold: CGFloat = 50

    var body: some View {
        ZStack {
            frontView
                .opacity(isFrontFaceVisible ? 1 : 0)

            backView
                .opacity(isBackFaceVisible ? 1 : 0)
                .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
        }
        .frame(width: width, height: cardHeight)
        .rotation3DEffect(
            .degrees(rotationY + liveDragRotation),
            axis: (x: 0, y: 1, z: 0),
            perspective: 0.5
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
            rotationY += 180
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

    // MARK: - Front
    private var frontView: some View {
        cardBase {
            Image(systemName: "person.crop.square.fill")
                .resizable()
                .scaledToFit()
                .padding(width * 0.15)
                .foregroundStyle(.white)
        }
        .background(.blue)
    }

    // MARK: - Back
    private var backView: some View {
        cardBase {
            Image(systemName: "person.2.square.stack.fill")
                .resizable()
                .scaledToFit()
                .padding(width * 0.15)
                .foregroundStyle(.white)
        }
        .background(.purple)
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
}
