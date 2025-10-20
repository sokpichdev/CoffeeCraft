//
//  Product.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 10/20/25.
//
import Foundation

struct Product: Identifiable, Hashable, Codable {
    let id: String
    let name: String
    let description: String
    let price: Double
    let imageURL: String
    var category: String
    let customizations: [String: [String]]?
    let priceModifiers: [String: [String: Double]]? // ["Size": ["Small": 0, "Medium": 0.5, "Large": 1.0]]

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    static func == (lhs: Product, rhs: Product) -> Bool { lhs.id == rhs.id }
}

struct SectionData: Identifiable {
    var id: String
    var name: String
    var items: [MenuItem]
}

struct MenuItem: Identifiable {
    let id = UUID()
    let name: String
    let price: Double
    let image: String
}
