//
//  Order.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 10/23/25.
//

import Foundation
import FirebaseFirestore

struct Order: Identifiable, Codable, Hashable, Equatable {
    @DocumentID var id: String?
    var orderId: Int
    var userId: String
    var items: [CartItemData]
    var totalPrice: Double
    var status: String
    var timestamp: Date
    
    // Hashable conformance
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Order, rhs: Order) -> Bool {
        lhs.id == rhs.id
    }
}

// Simpler model just for decoding item info
struct CartItemData: Identifiable, Codable, Hashable {
    var id: String { "\(name)-\(price)-\(Date().timeIntervalSince1970)" }
    var name: String
    var selections: [String: String]?
    var extras: [String]?
    var price: Double
    
    // Hashable conformance
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(price)
    }
    
    static func == (lhs: CartItemData, rhs: CartItemData) -> Bool {
        lhs.name == rhs.name && lhs.price == rhs.price
    }
}
