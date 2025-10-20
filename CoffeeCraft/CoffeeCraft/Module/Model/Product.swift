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
    let customizations: [String: [String]]?

    // ✅ Conform to Hashable
    func hash(into hasher: inout Hasher) {
        hasher.combine(id) // Use unique id for hashing
    }

    static func == (lhs: Product, rhs: Product) -> Bool {
        lhs.id == rhs.id
    }
}
