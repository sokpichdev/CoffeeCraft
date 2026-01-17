//
//  CustomizationModels.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 1/17/26.
//
import Foundation

// Model for a single customization option with its price
struct CustomizationOption: Identifiable, Codable, Hashable {
    var id = UUID()
    var name: String
    var price: Double
    
    init(name: String, price: Double) {
        self.name = name
        self.price = price
    }
}

// Model for a customization category (e.g., "Size", "Milk", "Extras")
struct CustomizationCategory: Identifiable, Codable, Hashable {
    var id = UUID()
    var name: String
    var options: [CustomizationOption]
    
    init(name: String, options: [CustomizationOption] = []) {
        self.name = name
        self.options = options
    }
    
    // Convert to Firebase format [String: [String: Double]]
    func toFirebaseFormat() -> [String: Double] {
        var dict: [String: Double] = [:]
        for option in options {
            dict[option.name] = option.price
        }
        return dict
    }
    
    // Create from Firebase format
    static func fromFirebaseFormat(name: String, data: [String: Double]) -> CustomizationCategory {
        let options = data.map { CustomizationOption(name: $0.key, price: $0.value) }
            .sorted { $0.name < $1.name }
        return CustomizationCategory(name: name, options: options)
    }
}
