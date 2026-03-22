//
//  ReorderManager.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 3/3/26.
//

import FirebaseAuth
import FirebaseFirestore
import SwiftUI

@MainActor
class ReorderManager: ObservableObject {
    static let shared = ReorderManager()
    private let db = Firestore.firestore()

    private init() {}

    // MARK: - Product Fetching

    /// Fetches a live product by ID (preferred) then falls back to name search.
    func fetchProduct(byId id: String?, byName name: String) async -> Product? {
        if let id, !id.isEmpty, let product = await fetchProductById(id) {
            return product
        }
        return await fetchProductByName(name)
    }

    private func fetchProductById(_ id: String) async -> Product? {
        do {
            let doc = try await db.collection(Firebase.Products.collection).document(id).getDocument()
            return doc.exists ? parseProduct(doc) : nil
        } catch {
            AppLog.order.warning("⚠️ fetchProductById failed for '\(id)': \(error)")
            return nil
        }
    }

    private func fetchProductByName(_ name: String) async -> Product? {
        guard !name.isEmpty else { return nil }
        do {
            let snapshot = try await db.collection(Firebase.Products.collection)
                .whereField(Firebase.Products.name, isEqualTo: name)
                .limit(to: 1)
                .getDocuments()
            return snapshot.documents.first.map { parseProduct($0) }
        } catch {
            AppLog.order.error("❌ fetchProductByName failed for '\(name)': \(error)")
            return nil
        }
    }

    /// Unified parser — works for both QueryDocumentSnapshot and DocumentSnapshot
    /// since both conform to DocumentSnapshot in Firebase SDK.
    private func parseProduct(_ snapshot: DocumentSnapshot) -> Product {
        let data = snapshot.data() ?? [:]
        return Product(
            id: snapshot.documentID,
            name: data[Firebase.Products.name] as? String ?? "",
            description: data[Firebase.Products.description] as? String ?? "",
            price: data[Firebase.Products.price] as? Double ?? 0.0,
            imageURL: data[Firebase.Products.imageURL] as? String ?? "",
            category: data[Firebase.Products.category] as? String ?? "Others",
            available: data[Firebase.Products.available] as? Bool ?? true,
            customizations: data[Firebase.Products.customizations] as? [String: [String: Double]] ?? [:]
        )
    }

    // MARK: - Duplicate Helpers

    func hasDuplicates(orderItems: [CartItemData], currentCart: [CartItem]) -> Bool {
        orderItems.contains { findExactMatch($0, in: currentCart) != nil }
    }

    func getDuplicateNames(orderItems: [CartItemData], currentCart: [CartItem]) -> [String] {
        orderItems.compactMap { findExactMatch($0, in: currentCart) != nil ? $0.name : nil }
    }

    func analyzeItems(orderItems: [CartItemData],
                      currentCart: [CartItem]) -> (toMerge: [(existing: CartItem, additionalQty: Int)],
                                                   toAdd: [CartItemData]) {
        var toMerge: [(existing: CartItem, additionalQty: Int)] = []
        var toAdd: [CartItemData] = []

        for orderItem in orderItems {
            if let match = findExactMatch(orderItem, in: currentCart) {
                toMerge.append((match, orderItem.quantity ?? 1))
            } else {
                toAdd.append(orderItem)
            }
        }
        return (toMerge, toAdd)
    }

    private func findExactMatch(_ orderItem: CartItemData, in cart: [CartItem]) -> CartItem? {
        cart.first {
            $0.product.name == orderItem.name &&
            $0.selections == (orderItem.selections ?? [:]) &&
            Set($0.extras) == Set(orderItem.extras ?? [])
        }
    }

    // MARK: - Execute Reorder

    /// Fetches all required products concurrently, then writes the entire cart in
    /// one Firestore call via CartManager.batchReorder.
    func executeReorder(order: Order, cartManager: CartManager) async {
        guard let userId = Auth.auth().currentUser?.uid else {
            AlertManager.shared.showError(message: "User not logged in")
            return
        }

        let orderItems = (order.items ?? []).compactMap { $0 }
        guard !orderItems.isEmpty else { return }

        let (toMerge, toAdd) = analyzeItems(
            orderItems: orderItems,
            currentCart: cartManager.items
        )

        // Fetch all new products concurrently — no serial await chain
        var productsByKey: [String: Product] = [:]
        await withTaskGroup(of: (String, Product?).self) { group in
            for item in toAdd {
                let key = item.productId ?? item.name ?? UUID().uuidString
                group.addTask { [weak self] in
                    guard let self else { return (key, nil) }
                    let product = await self.fetchProduct(byId: item.productId, byName: item.name ?? "")
                    return (key, product)
                }
            }
            for await (key, product) in group {
                productsByKey[key] = product
            }
        }

        // Split results: found vs not found
        var additions: [(product: Product, selections: [String: String], extras: [String], quantity: Int)] = []
        var notFoundNames: [String] = []

        for item in toAdd {
            let key = item.productId ?? item.name ?? ""
            if let product = productsByKey[key] {
                additions.append((
                    product: product,
                    selections: item.selections ?? [:],
                    extras: item.extras ?? [],
                    quantity: item.quantity ?? 1
                ))
            } else {
                notFoundNames.append(item.name ?? "Unknown")
                AppLog.order.error("❌ Reorder: product not found — '\(item.name ?? "unknown")'")
            }
        }

        // Warn about unavailable items (non-blocking)
        if !notFoundNames.isEmpty {
            let names = notFoundNames.joined(separator: ", ")
            AlertManager.shared.showError(title: "Some items unavailable",
                                          message: "\(names) could not be found and \(notFoundNames.count == 1 ? "was" : "were") skipped.")
        }

        guard !additions.isEmpty || !toMerge.isEmpty else { return }

        // Single Firestore write for all changes
        cartManager.batchReorder(userId: userId, merges: toMerge, additions: additions) {
            let newCount = additions.count
            let mergedCount = toMerge.count

            var parts: [String] = []
            if newCount > 0 { parts.append("\(newCount) new \(newCount == 1 ? "item" : "items") added") }
            if mergedCount > 0 { parts.append("\(mergedCount) \(mergedCount == 1 ? "item" : "items") merged") }

            ToastManager.shared.show(message: parts.joined(separator: ", ") + " ☕️", type: .success)
        }
    }
}
