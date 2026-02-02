//
//  ToastItem.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 2/2/26.
//
import SwiftUI

enum ToastPosition {
    case top
    case bottom
}

struct ToastItem: Identifiable {
    let id = UUID()
    let message: String
    let type: AlertType
    let duration: Double
    let position: ToastPosition
}
