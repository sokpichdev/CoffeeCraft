//
//  GradientColor.swift
//  OneNews
//
//  Created by Sok Pich on 1/13/25.
//

import SwiftUI

extension LinearGradient {
    static let orangeGradient = LinearGradient(
        gradient: Gradient(colors: [Color(hex: "#FFC238"), Color(hex: "#FF8F22"), Color(hex: "#E87200")]),
        startPoint: .top,
        endPoint: .bottom
    )
    
    static let greenGradient = LinearGradient(
        gradient: Gradient(colors: [Color(hex: "#44EEB9"), Color(hex: "#1BD1A5"), Color(hex: "#079C78")]),
        startPoint: .top,
        endPoint: .bottom
    )
    
    static let blueGradient = LinearGradient(
        gradient: Gradient(colors: [Color(hex: "#4DBFFE"), Color(hex: "#1189CD"), Color(hex: "#0C6FA7")]),
        startPoint: .top,
        endPoint: .bottom
    )
}
