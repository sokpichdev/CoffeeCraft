//
//  TornEdge.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 2/27/26.
//
import SwiftUI

// MARK: - Torn Edge
enum TornEdgePosition {
    case top, bottom
}

struct TornEdge: View {
    let position: TornEdgePosition
    
    var body: some View {
        GeometryReader { geo in
            Path { path in
                let width = geo.size.width
                let segmentCount = 28
                let segW = width / CGFloat(segmentCount)
                
                switch position {
                case .top:
                    path.move(to: CGPoint(x: 0, y: 10))
                    for i in 0..<segmentCount {
                        let x = CGFloat(i) * segW
                        let peak: CGFloat = i % 2 == 0 ? 0 : 14
                        path.addLine(to: CGPoint(x: x + segW / 2, y: peak))
                        path.addLine(to: CGPoint(x: x + segW, y: 10))
                    }
                    path.addLine(to: CGPoint(x: width, y: 40))
                    path.addLine(to: CGPoint(x: 0, y: 40))
                    
                case .bottom:
                    path.move(to: CGPoint(x: 0, y: 0))
                    path.addLine(to: CGPoint(x: width, y: 0))
                    path.addLine(to: CGPoint(x: width, y: 6))
                    for i in stride(from: segmentCount, through: 0, by: -1) {
                        let x = CGFloat(i) * segW
                        let peak: CGFloat = i % 2 == 0 ? 16 : 2
                        path.addLine(to: CGPoint(x: x - segW / 2, y: peak))
                        path.addLine(to: CGPoint(x: x - segW, y: 6))
                    }
                }
                path.closeSubpath()
            }
            .fill(Color(.systemGroupedBackground))
        }
        .frame(height: 16)
    }
}
