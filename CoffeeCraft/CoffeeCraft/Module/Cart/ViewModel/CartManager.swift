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

    func addToCart(userId: String,
                   product: Product,
                   selections: [String: String],
                   extras: [String]) {
        let item = CartItem(id: UUID(),
                            product: product,
                            selections: selections,
                            extras: extras)
        items.append(item)
        saveCartToFirestore(userId: userId)
    }

    func removeFromCart(userId: String, item: CartItem) {
        items.removeAll { $0.id == item.id }
        saveCartToFirestore(userId: userId)
    }

    func clearCart(userId: String) {
        items.removeAll()
        saveCartToFirestore(userId: userId)
    }
    func updateCartItem(userId: String, item: CartItem, selections: [String: String], extras: [String]) {
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            items[index] = CartItem(
                id: item.id,
                product: item.product,
                selections: selections,
                extras: extras)
            saveCartToFirestore(userId: userId)
        }
    }

    var total: Double {
        items.reduce(0) { $0 + $1.totalPrice }
    }
    
    func saveCartToFirestore(userId: String) {
        do {
            let data = try items.map { try Firestore.Encoder().encode($0) }

            db.collection("carts").document(userId)
                .setData(["items": data]) { [weak self] error in
                    DispatchQueue.main.async {
                        if let error = error {
                            AlertManager.shared.showError(message: error.localizedDescription)
                        } else {
//                            AlertManager.shared.showSuccess(message: "Your cart was saved successfully ☕️")
                            ToastManager.shared.show(message: "Your cart was saved successfully ☕️", type: .success)
                        }
                    }
                }
        } catch {
            DispatchQueue.main.sync {
                AlertManager.shared.showError(title: "Encoding error", message: error.localizedDescription)

            }
        }
    }

    func loadCartFromFirestore(userId: String) {
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
