//
//  CartManager.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 10/22/25.
//
import SwiftUI
import FirebaseFirestore

// MARK: - Cart Manager
class CartManager: ObservableObject {
    @Published var items: [CartItem] = []
    private let db = Firestore.firestore()
    private let userId: String
    
    init(userId: String) {
        self.userId = userId
        loadCartFromFirestore()
    }
    func addToCart(product: Product,
                   size: String,
                   milk: String,
                   sugar: String,
                   ice: String,
                   extras: [String]) {
        let item = CartItem(id: UUID(),
                            product: product,
                            size: size,
                            milk: milk,
                            sugar: sugar,
                            ice: ice,
                            extras: extras)
        items.append(item)
        saveCartToFirestore()
    }

    func removeFromCart(item: CartItem) {
        items.removeAll { $0.id == item.id }
        saveCartToFirestore()
    }

    func clearCart() {
        items.removeAll()
        saveCartToFirestore()
    }

    func updateCartItem(item: CartItem, size: String, milk: String, sugar: String, ice: String, extras: [String]) {
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            items[index] = CartItem(
                id: item.id,
                product: item.product,
                size: size,
                milk: milk,
                sugar: sugar,
                ice: ice,
                extras: extras
            )
            saveCartToFirestore()
        }
    }

    var total: Double {
        items.reduce(0) { $0 + $1.totalPrice }
    }
    
    func saveCartToFirestore() {
        do {
            let data = try items.map { try Firestore.Encoder().encode($0) }
            db.collection("carts").document(userId).setData(["items": data]) { error in
                if let error = error {
                    print("Error saving cart: \(error.localizedDescription)")
                } else {
                    print("Cart saved successfully")
                }
            }
        } catch {
            print("Encoding error: \(error.localizedDescription)")
        }
    }

    func loadCartFromFirestore() {
        db.collection("carts").document(userId).getDocument { [weak self] snapshot, error in
            if let error = error {
                print("Error loading cart: \(error.localizedDescription)")
                return
            }
            
            guard let data = snapshot?.data(),
                  let itemData = data["items"] as? [[String: Any]] else { return }
            
            do {
                let decoded = try itemData.map { try Firestore.Decoder().decode(CartItem.self, from: $0) }
                DispatchQueue.main.async {
                    self?.items = decoded
                }
            } catch {
                print("Decoding error: \(error.localizedDescription)")
            }
        }
    }
}
