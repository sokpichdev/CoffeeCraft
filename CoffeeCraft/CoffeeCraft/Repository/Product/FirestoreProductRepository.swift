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
        let snapshot = try await db.collection(Firebase.Products.collection).getDocuments()
        return snapshot.documents.map { parse($0) }
    }

    // MARK: - Real-time Listener

    func listen(onChange: @escaping ([Product]) -> Void) -> () -> Void {
        let registration = db.collection(Firebase.Products.collection)
            .order(by: Firebase.Products.category)
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
            Firebase.Products.name: product.name,
            Firebase.Products.description: product.description,
            Firebase.Products.price: product.price,
            Firebase.Products.imageURL: product.imageURL,
            Firebase.Products.category: product.category,
            Firebase.Products.available: product.available,
            Firebase.Products.customizations: product.customizations ?? [:]
        ]
        try await db.collection(Firebase.Products.collection).document(product.id).setData(data)
    }

    func delete(_ product: Product) async throws {
        try await db.collection(Firebase.Products.collection).document(product.id).delete()
    }

    func markUnavailable(_ product: Product) async throws {
        try await db.collection(Firebase.Products.collection).document(product.id)
            .updateData([Firebase.Products.available: false])
    }

    // MARK: - Parsing (private)

    private func parse(_ doc: QueryDocumentSnapshot) -> Product {
        let data = doc.data()
        return Product(
            id: doc.documentID,
            name: data[Firebase.Products.name] as? String ?? "",
            description: data[Firebase.Products.description] as? String ?? "",
            price: data[Firebase.Products.price] as? Double ?? 0.0,
            imageURL: data[Firebase.Products.imageURL] as? String ?? "",
            category: data[Firebase.Products.category] as? String ?? "Others",
            available: data[Firebase.Products.available] as? Bool ?? true,
            customizations: data[Firebase.Products.customizations] as? [String: [String: Double]],
            avgRating: data[Firebase.Products.avgRating] as? Double,
            ratingCount: data[Firebase.Products.ratingCount] as? Int,
            ratingDistribution: data[Firebase.Products.ratingDistribution] as? [String: Int]
        )
    }
}
