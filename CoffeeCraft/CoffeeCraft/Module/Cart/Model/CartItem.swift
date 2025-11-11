//
//  CartItem.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 10/20/25.
//
import SwiftUI
import FirebaseFirestore

struct CartItem: Identifiable, Codable {
    let id: UUID
    let product: Product
    let selections: [String: String]
    let extras: [String]
    
    var totalPrice: Double {
        var price = product.price
        
        if let customizations = product.customizations {
            for (category, options) in customizations {
                if category.lowercased() == "extras" { continue }
                
                if let selectedOption = selections[category],
                   let optionPrice = options[selectedOption] {
                    price += optionPrice
                }
            }
            
            if let extrasDict = customizations["Extras"] {
                for extra in extras {
                    if let extraPrice = extrasDict[extra] {
                        price += extraPrice
                    }
                }
            }
        }
        return price
    }
}
