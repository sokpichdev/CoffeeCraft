//
//  ToastItem.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 2/2/26.
//
import SwiftUI

struct ToastItem: Identifiable {
    let id = UUID()
    let message: String
    let type: AlertType
    let duration: Double
}
