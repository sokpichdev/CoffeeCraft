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
        default:
            return .gray  // Default color if no match
        }
    }
}
