//
//  ReorderManager.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 3/3/26.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth
@MainActor
class ReorderManager: ObservableObject {
    static let shared = ReorderManager()
    
    private init() {}
    
    /// Analyzes order items against current cart
    /// Returns: items to merge (existing + new qty) and items to add fresh
    func analyzeItems(orderItems: [CartItemData], currentCart: [CartItem] ) -> (toMerge: [(existing: CartItem, additionalQty: Int)],
                                                                                toAdd: [CartItemData]) {
        var toMerge: [(existing: CartItem, additionalQty: Int)] = []
        var toAdd: [CartItemData] = []
        
        for orderItem in orderItems {
            if let existingItem = findExactMatch(orderItem, in: currentCart) {
                // Exact duplicate found - will merge quantities
                toMerge.append((existingItem, orderItem.quantity ?? 1))
            } else {
                // New item or different options - add as separate
                toAdd.append(orderItem)
            }
        }
        
        return (toMerge, toAdd)
    }
    
    /// Check if any items will be merged (for showing confirmation)
    func hasDuplicates(orderItems: [CartItemData], currentCart: [CartItem]) -> Bool {
        orderItems.contains { findExactMatch($0, in: currentCart) != nil }
    }
    
    /// Get names of items that will be merged
    func getDuplicateNames(orderItems: [CartItemData], currentCart: [CartItem]) -> [String] {
        orderItems.compactMap { item in
            findExactMatch(item, in: currentCart) != nil ? item.name : nil
        }
    }
    
    private func findExactMatch(_ orderItem: CartItemData, in cart: [CartItem]) -> CartItem? {
        cart.first { cartItem in
            // Exact match: same product name + same selections + same extras
            cartItem.product.name == orderItem.name &&
            cartItem.selections == orderItem.selections &&
            Set(cartItem.extras) == Set(orderItem.extras ?? [])
        }
    }
    
    /// Execute reorder - always merges exact duplicates
    func executeReorder(order: Order, cartManager: CartManager, productLookup: (String) async -> Product?) async {
        guard let userId = Auth.auth().currentUser?.uid else {
            AlertManager.shared.showError(message: "User not logged in")
            return
        }
        
        guard let items = order.items as? [CartItemData] else { return }
        
        let (toMerge, toAdd) = analyzeItems(orderItems: items, currentCart: cartManager.items)
        
        // 1. Merge exact duplicates (increase quantity)
        for (existingItem, additionalQty) in toMerge {
            let newQuantity = existingItem.quantity + additionalQty
            cartManager.updateCartItem(
                userId: userId,
                item: existingItem,
                selections: existingItem.selections,
                extras: existingItem.extras,
                quantity: newQuantity
            )
        }
        
        // 2. Add new items (or items with different options)
        for item in toAdd {
            let product = await productLookup(item.name ?? "") ?? createProduct(from: item)
            
            cartManager.addToCart(
                userId: userId,
                product: product,
                selections: item.selections ?? [:],
                extras: item.extras ?? [],
                quantity: item.quantity ?? 1
            )
        }
        
        // Show success message
        let totalItems = toMerge.count + toAdd.count
        let mergedCount = toMerge.count
        
        if mergedCount > 0 {
            ToastManager.shared.show(message: "Added \(totalItems) items. \(mergedCount) merged with existing. ☕️", type: .success)
        } else {
            ToastManager.shared.show(message: "Added \(totalItems) items to cart ☕️", type: .success)
        }
    }
    
    private func createProduct(from item: CartItemData) -> Product {
        Product(
            id: UUID().uuidString,
            name: item.name ?? "Unknown Item",
            description: "",
            price: item.price ?? 0.0,
            imageURL: item.imageURL ?? "",
            category: "Re-order",
            available: true,
            customizations: [:]
        )
    }
}
