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

    // MARK: Gradient
    static let mainLinearGradient =  LinearGradient(
        stops: [
            Gradient.Stop(color: Color(hex: "30D9FE"), location: 0),
            Gradient.Stop(color: Color(hex: "2474FE"), location: 1)
        ],
        startPoint: UnitPoint(x: 0, y: 0), endPoint: UnitPoint(x: 1, y: 1))
    
    static let gameCardGradient = RadialGradient(
        gradient: Gradient(colors: [Color(hex: "0D4262"), Color(hex: "0D0B21")]),
        center: .center, startRadius: 1, endRadius: 70)
    
    static let pickerViewGradient = LinearGradient(gradient: Gradient(colors: [
        Color(hex: "FE370A").opacity(0.0),
        Color(hex: "FE370A").opacity(0.40),
        Color(hex: "FE370A").opacity(0.40),
        Color(hex: "FE370A").opacity(0.0)]), startPoint: .leading, endPoint: .trailing)
    
    static let vipLinearGradient =  LinearGradient(
        stops: [
            Gradient.Stop(color: Color(hex: "454545"), location: 0),
            Gradient.Stop(color: Color(hex: "1E1E1E"), location: 1)
        ],
        startPoint: UnitPoint(x: 0.5, y: 0), endPoint: UnitPoint(x: 0.5, y: 1))
    
    static let goldLinearGradient =  LinearGradient(
        stops: [
            Gradient.Stop(color: Color(hex: "FFE7BC"), location: 0),
            Gradient.Stop(color: Color(hex: "F7C674"), location: 0.5),
            Gradient.Stop(color: Color(hex: "FFE7BC"), location: 1)
        ],
        startPoint: UnitPoint(x: 0.5, y: 0), endPoint: UnitPoint(x: 0.5, y: 1))
    
    static let spinListLinearGradient =  LinearGradient(
        stops: [
            Gradient.Stop(color: Color(hex: "691300"), location: 0),
            Gradient.Stop(color: Color(hex: "901B00"), location: 1)
        ],
        startPoint: UnitPoint(x: 0.5, y: 0), endPoint: UnitPoint(x: 0.5, y: 1))
    
    static let agentCardItemLinearGradient =  LinearGradient(
        stops: [
            Gradient.Stop(color: Color(hex: "313A60"), location: 0),
            Gradient.Stop(color: Color(hex: "131724"), location: 1)
        ],
        startPoint: UnitPoint(x: 0.5, y: 0), endPoint: UnitPoint(x: 0.5, y: 1))
    static let mainGradient =  LinearGradient(
        stops: [
            Gradient.Stop(color: Color.main, location: 0),
            Gradient.Stop(color: Color.main, location: 1)
        ],
        startPoint: UnitPoint(x: 0.5, y: 0), endPoint: UnitPoint(x: 0.5, y: 1))
    
    static let goldSpinWalletBalance = LinearGradient(stops: [
        .init(color: Color(hex: "E9D7B3"), location: 0),
        .init(color: Color(hex: "B39364"), location: 1)
    ], startPoint: .top, endPoint: .bottom)
    
    static let paidSpinBtn = LinearGradient(stops: [
        .init(color: Color(hex: "FF9B01"), location: 0),
        .init(color: Color(hex: "FF2D00"), location: 1)
    ], startPoint: .top, endPoint: .bottom)
    
    static let winCardAmt = LinearGradient(stops: [
        .init(color: Color(hex: "F8351B"), location: 0),
        .init(color: Color(hex: "DE202B"), location: 1)
    ], startPoint: .top, endPoint: .bottom)
    
    static let bullbullTxt = LinearGradient(stops: [
        .init(color: Color(hex: "FFDD9F"), location: 0),
        .init(color: Color(hex: "FEB32B"), location: 1)
    ], startPoint: .top, endPoint: .bottom)
    
    static let bullNumberTxt = LinearGradient(stops: [
        .init(color: Color(hex: "BEE0FF"), location: 0),
        .init(color: Color(hex: "0084FF"), location: 1)
    ], startPoint: .top, endPoint: .bottom)
    
    static let nobullTxt = LinearGradient(stops: [
        .init(color: Color(hex: "FFFFFF"), location: 0),
        .init(color: Color(hex: "A7AECB"), location: 1)
    ], startPoint: .top, endPoint: .bottom)

    
    // Re Design colors as per new Figma
//    static let primaryBackgroundColor = Color("backgroundColor")
    static let secondaryBackgroundColor = Color.white
    static let backButonColor = Color.black
    static let primaryTextColor = Color.black
    static let secondaryTextColor = Color.black
    static let primaryThemeColor = Color.main
    static let secondoryThemeColor = Color.blue.opacity(0.5)
    static let placeHolderColor = Color.gray

}
