//
//  Order.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 10/23/25.
//

import SwiftUI
import FirebaseFirestore

struct Order: Identifiable, Codable {
    @DocumentID var id: String?
    var userId: String
    var items: [CartItemData]   // use a lightweight type for Firestore decoding
    var totalPrice: Double
    var status: String
    var timestamp: Date
}

// simpler model just for decoding item info
struct CartItemData: Identifiable, Codable {
    var id: String { "\(name)-\(Date().timeIntervalSince1970)" }
    var name: String
    var selections: [String: String]?
    var extras: [String]?
    var price: Double
}
