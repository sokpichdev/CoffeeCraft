//
//  Ex+Color.swift
//  MyWallet
//
//  Created by Sok Pich on 5/13/25.
//
import SwiftUI

extension Color {
    init(hex: String) {
        var cleanHex = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        cleanHex = cleanHex.replacingOccurrences(of: "#", with: "")
        
        var baseValue: UInt64 = 0
        Scanner(string: cleanHex).scanHexInt64(&baseValue)
        
        let red = Double((baseValue >> 16) & 0xFF) / 255.0
        let green = Double((baseValue >> 8) & 0xFF) / 255.0
        let blue = Double((baseValue) & 0xFF) / 255.0
        
        self.init(red: red, green: green, blue: blue)
    }
}
