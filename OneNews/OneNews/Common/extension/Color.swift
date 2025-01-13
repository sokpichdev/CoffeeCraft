//
//  Color.swift
//  OneNews
//
//  Created by Sok Pich on 1/9/25.
//
import SwiftUI

extension Color {
    static func from(string: String) -> Color {
        switch string.lowercased() {
        case "main":
            return .main
        case "red":
            return .red
        case "blue":
            return .blue
        case "green":
            return .green
        case "letter":
            return .letters
        case "background":
            return .background
        case "optionBtn1":
            return .optionBtn1
        case "optionBtn2":
            return .optionBtn2
        case "white":
            return .white
        default:
            return .gray  // Default color if no match
        }
    }
}

extension Color {
    init(hex: String) {
        let hexString = hex.trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: "#", with: "")
        var rgb: UInt64 = 0
        Scanner(string: hexString).scanHexInt64(&rgb)
        
        let red = Double((rgb >> 16) & 0xFF) / 255.0
        let green = Double((rgb >> 8) & 0xFF) / 255.0
        let blue = Double(rgb & 0xFF) / 255.0
        
        self.init(red: red, green: green, blue: blue)
    }
}
