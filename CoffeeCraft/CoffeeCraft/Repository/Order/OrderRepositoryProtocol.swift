//
//  OrderRepositoryProtocol.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 3/11/26.
//
//  Defines the two Firestore operations OrderService needs.
//  buildOrderData() stays in OrderService — it's pure logic with no I/O.
//

protocol OrderRepositoryProtocol {

    /// Generates the next sequential order number for today using a
    /// Firestore transaction on the counters collection.
    func generateOrderNumber() async throws -> Int

    /// Writes the order document to Firestore.
    /// Throws on failure — callers are responsible for any compensation
    /// (e.g. wallet refund) if this step fails.
    func writeOrder(orderData: [String: Any], orderId: String) async throws
}
