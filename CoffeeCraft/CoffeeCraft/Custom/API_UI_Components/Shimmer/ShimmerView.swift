//
//  ShimmerView.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 2/3/26.
//
import SwiftUI

struct ShimmerView: View {
    var cornerRadius: CGFloat = Dimens.cornerRadius

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        if reduceMotion {
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(Color.bgSecondary)
        } else {
            TimelineView(.animation(minimumInterval: 1/60, paused: false)) { timeline in
                let date = timeline.date.timeIntervalSinceReferenceDate
                let offset = date.truncatingRemainder(dividingBy: 2) / 2

                let gradient = Gradient(colors: [
                    Color.bgSecondary,
                    Color.textMuted.opacity(0.3),
                    Color.bgSecondary
                ])

                LinearGradient(
                    gradient: gradient,
                    startPoint: .init(x: -1 + offset * 2, y: 0.5),
                    endPoint: .init(x: offset * 2, y: 0.5)
                )
                .cornerRadius(cornerRadius)
            }
        }
    }
}
