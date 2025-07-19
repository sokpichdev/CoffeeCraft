//
//  testApp.swift
//  test
//
//  Created by Sok Pich on 5/13/25.
//

import SwiftUI

@main
struct testApp: App {

    var body: some Scene {
        WindowGroup {
//            PlayerBankerView()
            MainShimmer()
        }
    }
}

struct ToggleButtonGameView: View {
    @Binding var isActive: Bool
    let height: CGFloat = 40
    @GestureState private var dragOffset: CGSize = .zero

    var body: some View {
        let width = height * 1.6
        let knobSize = height * 0.9
        let padding: CGFloat = 2

        ZStack {
            // Background
            RoundedRectangle(cornerRadius: height / 2)
                .fill(isActive ? Color.blue : Color.red)

            // Knob
            HStack {
                if isActive { Spacer() }

                Circle()
                    .fill(Color.white)
                    .frame(width: knobSize, height: knobSize)
                    .shadow(radius: 2)
                    .padding(padding)
                    .offset(x: clampedOffset()) // Clamp based on side
                    .animation(.easeInOut(duration: 0.25), value: isActive)

                if !isActive { Spacer() }
            }
        }
        .frame(width: width, height: height)
        .cornerRadius(height / 2)
        .gesture(
            DragGesture(minimumDistance: 0)
                .updating($dragOffset) { value, state, _ in
                    state = value.translation
                }
                .onEnded { value in
                    if abs(value.translation.width) > 10 {
                        isActive = value.translation.width > 0
                    }
                }
        )
        .simultaneousGesture(
            TapGesture()
                .onEnded {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        isActive.toggle()
                    }
                }
        )
    }

    // Clamp based on the current active side
    private func clampedOffset() -> CGFloat {
        let width = height * 1.6
        let knobSize = height * 0.9
        let padding: CGFloat = 2
        let maxSlide: CGFloat = (width - knobSize - padding * 2)

        let offset = dragOffset.width
        if isActive {
            // Knob is on the right → only allow [−maxSlide, 0]
            return max(-maxSlide, min(0, offset))
        } else {
            // Knob is on the left → only allow [0, +maxSlide]
            return min(maxSlide, max(0, offset))
        }
    }
}
