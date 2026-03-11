//
//  FirestoreProductRepository.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 3/11/26.
//
//  The live Firestore implementation of ProductRepositoryProtocol.
//  All raw Firestore calls that previously lived in ProductViewModel
//  now live here, so the ViewModel only orchestrates state.
//

import FirebaseFirestore
import Foundation

struct FirestoreProductRepository: ProductRepositoryProtocol {

    private let db = Firestore.firestore()

    // MARK: - Fetch Once

    func fetchAll() async throws -> [Product] {
        let snapshot = try await db.collection("products").getDocuments()
        return snapshot.documents.map { parse($0) }
    }

    // MARK: - Real-time Listener

    func listen(onChange: @escaping ([Product]) -> Void) -> () -> Void {
        let registration = db.collection("products")
            .order(by: "category")
            .addSnapshotListener { snapshot, error in
                if let error {
                    AppLog.menu.error("❌ ProductRepository listener error: \(error.localizedDescription)")
                    return
                }
                guard let docs = snapshot?.documents else {
                    AppLog.menu.warning("⚠️ ProductRepository — snapshot nil or empty")
                    return
                }
                let products = docs.map { parse($0) }
                AppLog.menu.debug("📡 ProductRepository listener — \(products.count) product(s)")
                onChange(products)
            }
        return { registration.remove() }
    }

    // MARK: - Write

    func save(_ product: Product) async throws {
        let data: [String: Any] = [
            "name": product.name,
            "description": product.description,
            "price": product.price,
            "imageURL": product.imageURL,
            "category": product.category,
            "available": product.available,
            "customizations": product.customizations ?? [:]
        ]
        try await db.collection("products").document(product.id).setData(data)
    }

    func delete(_ product: Product) async throws {
        try await db.collection("products").document(product.id).delete()
    }

    func markUnavailable(_ product: Product) async throws {
        try await db.collection("products").document(product.id)
            .updateData(["available": false])
    }

    // MARK: - Parsing (private)

    private func parse(_ doc: QueryDocumentSnapshot) -> Product {
        let data = doc.data()
        return Product(
            id: doc.documentID,
            name: data["name"] as? String ?? "",
            description: data["description"] as? String ?? "",
            price: data["price"] as? Double ?? 0.0,
            imageURL: data["imageURL"] as? String ?? "",
            category: data["category"] as? String ?? "Others",
            available: data["available"] as? Bool ?? true,
            customizations: data["customizations"] as? [String: [String: Double]],
            avgRating: data["avgRating"] as? Double,
            ratingCount: data["ratingCount"] as? Int,
            ratingDistribution: data["ratingDistribution"] as? [String: Int]
        )
    }
}
