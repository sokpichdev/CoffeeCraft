//
//  CartManager.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 10/22/25.
//
import SwiftUI
import FirebaseFirestore

// MARK: - Cart Manager
@MainActor
class CartManager: ObservableObject {
    @Published var items: [CartItem] = []
    private let db = Firestore.firestore()

    func addToCart(userId: String,
                   product: Product,
                   selections: [String: String],
                   extras: [String],
                   quantity: Int) {
        let item = CartItem(id: UUID(),
                            product: product,
                            selections: selections,
                            extras: extras,
                            quantity: quantity)
        items.append(item)
        saveCartToFirestore(userId: userId) {
            ToastManager.shared.show(message: "Your cart was added successfully ☕️", type: .success)
        }
    }

    func removeFromCart(userId: String, item: CartItem) {
        items.removeAll { $0.id == item.id }
        saveCartToFirestore(userId: userId) {
            ToastManager.shared.show(message: "Your cart was removed successfully ☕️", type: .success)
        }
    }

    func clearCart(userId: String) {
        items.removeAll()
        saveCartToFirestore(userId: userId) {}
    }
    func updateCartItem(userId: String, item: CartItem, selections: [String: String], extras: [String], quantity: Int) {
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            items[index] = CartItem(
                id: item.id,
                product: item.product,
                selections: selections,
                extras: extras,
                quantity: quantity)
            
            // Use completion handler
            saveCartToFirestore(userId: userId) {
                ToastManager.shared.show(message: "Your cart was updated successfully ☕️", type: .success)
            }
        }
    }

    var total: Double {
        items.reduce(0) { $0 + $1.totalPrice }
    }
    
    func saveCartToFirestore(userId: String, completion: (() -> Void)? = nil) {
        do {
            let data = try items.map { try Firestore.Encoder().encode($0) }

            db.collection("carts").document(userId)
                .setData(["items": data]) { [weak self] error in
                    guard self != nil else { return }
                    DispatchQueue.main.async {
                        if let error = error {
                            AlertManager.shared.showError(message: error.localizedDescription)
                        } else {
                            completion?()
                        }
                    }
                }
        } catch {
            DispatchQueue.main.async {
                AlertManager.shared.showError(title: "Encoding error", message: error.localizedDescription)
            }
        }
    }

    func loadCartFromFirestore(userId: String) {
        db.collection("carts").document(userId).getDocument { [weak self] snapshot, error in
            if let error = error {
                AppLog.firestore.error("Error loading cart: \(error.localizedDescription)")
                return
            }
            
            guard let data = snapshot?.data(),
                  let itemData = data["items"] as? [[String: Any]] else { return }
            
            do {
                let decoded = try itemData.map { try Firestore.Decoder().decode(CartItem.self, from: $0) }
                DispatchQueue.main.async {
                    self?.items = decoded
                    AppLog.printList(self?.items ?? [], label: "Fetched Carts")
                }
            } catch {
                AppLog.firestore.error("Decoding error: \(error.localizedDescription)")
            }
        }
    }
    
    // Async version of load
    func loadCartFromFirestoreAsync(userId: String) async throws {
        let snapshot = try await db.collection("carts").document(userId).getDocument()
        
        guard let data = snapshot.data(),
              let itemData = data["items"] as? [[String: Any]] else { return }
        
        let decoded = try itemData.map { try Firestore.Decoder().decode(CartItem.self, from: $0) }
        self.items = decoded
    }
}

// MARK: - Reorder Support
extension CartManager {

    /// Applies all reorder mutations — merges and additions — in memory, then performs
    /// a single Firestore write. Use this instead of calling updateCartItem/addToCart
    /// in a loop, which would trigger N separate writes and N individual toasts.
    func batchReorder(
        userId: String,
        merges: [(existing: CartItem, additionalQty: Int)],
        additions: [(product: Product, selections: [String: String], extras: [String], quantity: Int)],
        completion: (() -> Void)? = nil
    ) {
        // 1. Merge in memory: bump quantity on existing items
        for (existingItem, additionalQty) in merges {
            if let idx = items.firstIndex(where: { $0.id == existingItem.id }) {
                items[idx] = CartItem(
                    id: items[idx].id,
                    product: items[idx].product,
                    selections: items[idx].selections,
                    extras: items[idx].extras,
                    quantity: items[idx].quantity + additionalQty
                )
            }
        }

        // 2. Append new items in memory
        for (product, selections, extras, quantity) in additions {
            items.append(CartItem(
                id: UUID(),
                product: product,
                selections: selections,
                extras: extras,
                quantity: quantity
            ))
        }

        // 3. One write for everything
        saveCartToFirestore(userId: userId, completion: completion)
    }
}
