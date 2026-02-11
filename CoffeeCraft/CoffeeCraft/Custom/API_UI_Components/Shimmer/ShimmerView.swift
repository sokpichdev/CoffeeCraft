//
//  ShimmerView.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 2/3/26.
//
import SwiftUI

struct ShimmerView: View {
    var cornerRadius: CGFloat = Dimens.cornerRadius
    private let gradient = Gradient(colors: [
        Color(hex: "6F4E37").opacity(0.3), // base brown
        Color(hex: "D3B8AE").opacity(0.6), // lighter shimmer
        Color(hex: "6F4E37").opacity(0.3)
    ])
    
    var body: some View {
        TimelineView(.animation(minimumInterval: 1/60, paused: false)) { timeline in
            let date = timeline.date.timeIntervalSinceReferenceDate
            let offset = date.truncatingRemainder(dividingBy: 2) / 2 // range: 0 -> 1
            
            LinearGradient(
                gradient: gradient,
                startPoint: .init(x: -1 + offset * 2, y: 0.5),
                endPoint: .init(x: offset * 2, y: 0.5)
            )
            .cornerRadius(cornerRadius)
        }
    }
}
