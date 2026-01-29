//
//  Color+Ex.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 12/29/25.
//
import SwiftUI

extension Color {
    init(hex: String) {
        var hexSanitized = hex
        if hexSanitized.hasPrefix("#") {
            hexSanitized.removeFirst()
        }
        let scanner = Scanner(string: hexSanitized)
        var rgbValue: UInt64 = 0
        scanner.scanHexInt64(&rgbValue)
        
        let r = (rgbValue & 0xff0000) >> 16
        let g = (rgbValue & 0xff00) >> 8
        let b = rgbValue & 0xff
        
        self.init(
            red: CGFloat(r) / 0xff,
            green: CGFloat(g) / 0xff,
            blue: CGFloat(b) / 0xff
        )
    }
    static func random(randomOpacity: Bool = false) -> Color {
        Color(
            red: .random(in: 0...1),
            green: .random(in: 0...1),
            blue: .random(in: 0...1),
            opacity: randomOpacity ? .random(in: 0...1) : 1
        )
    }
}
extension Color {
    static let primaryTextColor = Color.black
    static let placeHolderColor = Color.gray
    
    static var coffeeBrown: Color { Color(red: 0.45, green: 0.29, blue: 0.20) }
    static var coffeeLight: Color { Color(red: 0.62, green: 0.42, blue: 0.31) }
    static var coffeeCream: Color { Color(red: 0.85, green: 0.75, blue: 0.65) }
}

extension Color {
    static var coffeeDarkBrown: Color { Color(hex: "#4B2E2A") }
    static var coffeeWarmBrown: Color { Color(hex: "#6F4E37") }
    static var coffeeOliveGreen: Color { Color(hex: "#7A8F3A") }
}

extension Color {
    static let leafGreen = Color(hex: "#6B8E23") // success
    static let warningAmber = Color(hex: "#C97C5D") // warning
    static let errorRed = Color(hex: "#9E3A2F") // error
}
