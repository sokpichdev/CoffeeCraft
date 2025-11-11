//
//  Product.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 10/20/25.
//
import Foundation

struct Product: Identifiable, Hashable, Codable, Equatable {
    var uID = UUID()
    var id: String
    var name: String
    var description: String
    var price: Double
    var imageURL: String
    var category: String
    var available: Bool = true
    var customizations: [String: [String: Double]]?

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    static func == (lhs: Product, rhs: Product) -> Bool { lhs.id == rhs.id }

    static func empty(in category: String) -> Product {
        Product(
            id: UUID().uuidString,
            name: "",
            description: "",
            price: 0.0,
            imageURL: "",
            category: category,
            available: true,
            customizations: [:],
        )
    }
}

struct SectionData: Identifiable {
    var id: String { name }
    var name: String
    var items: [Product]
}

struct MenuItem: Identifiable {
    let id = UUID()
    let name: String
    let price: Double
    let image: String
}
