//
//  Font+Ex.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 12/2/25.
//
import SwiftUI

extension Font {
    static func customFont(
        _ font: AppFont = .nokora,
        size: CGFloat,
        weight: Font.Weight = .regular
    ) -> Font {
        Font.custom(font.rawValue, size: size).weight(weight)
    }
}


enum AppFont: String {
    case nokora = "Nokora"
    case roboto = "Roboto"
    case poppins = "Poppins"
    case montserrat = "Montserrat"
}
