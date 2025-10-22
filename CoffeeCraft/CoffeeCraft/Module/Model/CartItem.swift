//
//  CartItem.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 10/20/25.
//
import SwiftUI
import FirebaseFirestore
// MARK: - Cart Item
struct CartItem: Identifiable, Codable {
    let id: UUID
    let product: Product
    let size: String
    let milk: String
    let sugar: String
    let ice: String
    let extras: [String]
    
    // Calculate dynamic price
    var totalPrice: Double {
        var price = product.price
        
        // Size adjustments
        switch size {
        case "Small": price += 0
        case "Medium": price += 0.5
        case "Large": price += 1.0
        default: break
        }
        
        // Milk adjustments
        switch milk {
        case "Whole": price += 0
        case "Oat": price += 0.5
        case "Soy": price += 0.5
        case "Almond": price += 0.5
        default: break
        }
        
        // Extras adjustments
        price += Double(extras.count) * 0.5
        
        return price
    }
}

