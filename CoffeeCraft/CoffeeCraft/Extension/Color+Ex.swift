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
}
/*
 coffeeDarkBrown = #4B2E2A
 coffeeWarmBrown = #6F4E37
 coffeeOliveGreen = #7A8F3A
 
 leafGreen = #6B8E23
 warningAmber = #C97C5D
 errorRed = #9E3A2F"
 
 coffeeBrown = #734A33
 coffeeLight = #9E6B4F
 coffeeCream = #D9BFA6
 
 */
