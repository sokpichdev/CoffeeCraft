//
//  ProductViewModel.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 10/20/25.
//
import Foundation
import FirebaseFirestore

@MainActor
class ProductViewModel: ObservableObject {
    @Published var products: [Product] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let db = Firestore.firestore()

    func fetchProducts() async {
        isLoading = true
        errorMessage = nil
        do {
            let snapshot = try await db.collection("products").getDocuments()
            self.products = snapshot.documents.map { doc in
                let data = doc.data()
                return Product(
                    id: doc.documentID,
                    name: data["name"] as? String ?? "",
                    description: data["description"] as? String ?? "",
                    price: data["price"] as? Double ?? 0.0,
                    imageURL: data["imageURL"] as? String ?? "",
                    customizations: data["customizations"] as? [String: [String]] ?? [:],
                    priceModifiers: data["priceModifiers"] as? [String: [String: Double]] ?? [:]
                )
            }
            print("✅ Fetched products:", self.products)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}
