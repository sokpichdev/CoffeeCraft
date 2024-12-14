//
//  DownwardEdgeShape.swift
//  OneNews
//
//  Created by Sok Pich on 12/14/24.
//

import SwiftUI

struct DownwardEdgeShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        // Move to the top-left corner
        path.move(to: CGPoint(x: rect.minX, y: rect.minY))
        
        // Left line to bottom center with curve
        path.addLine(to: CGPoint(x: rect.midX - 10, y: rect.maxY - 10))
        
        path.addQuadCurve(to: CGPoint(x: rect.midX + 10, y: rect.maxY - 10),
                          control: CGPoint(x: rect.midX, y: rect.maxY + 10))
        
        // Right line back up to top-right corner
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        
        // Close the path
        path.closeSubpath()
        
        return path
    }
}


struct testView: View {
    var body: some View {
        DownwardEdgeShape()
    }
}

#Preview {
    testView()
}
