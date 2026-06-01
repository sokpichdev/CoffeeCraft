//
//  PointsTransaction.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 3/30/26.
//
//  Immutable ledger entry written to `points_transactions` whenever
//  loyalty points are awarded. One document per completed order.
//

import FirebaseFirestore
import Foundation

struct PointsTransaction: Identifiable, Codable {
    @DocumentID var id: String?
    var userId: String
    var cardNumber: String
    var orderId: String?
    var points: Double       // raw Double — e.g. 1.5 for fractional awards
    var description: String  // e.g. "Order #42"
    var timestamp: Date
}
