//
//  FavoriteViewModel.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 1/16/26.
//
import SwiftUI
import FirebaseFirestore
import FirebaseAuth

@MainActor
class FavoriteViewModel: ObservableObject {

    @Published var isFavorite: Bool = false
    @Published var favorites: [FavoriteItem] = []
    
    private let db = Firestore.firestore()

    // MARK: - Helpers
    func currentCustomizationForFavorite(selections: [String: String], selectedExtras: [String]) -> [String: String] {
        var result = selections
        if !selectedExtras.isEmpty {
            result["Extras"] = selectedExtras.sorted().joined(separator: ",")
        }
        return result
    }

    // MARK: - Load favorite state for a product
    func loadFavoriteState(product: Product, selections: [String: String], selectedExtras: [String]) async {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        let customizations = currentCustomizationForFavorite(selections: selections, selectedExtras: selectedExtras)
        let hash = buildCustomizationHash(customizations)

        let snapshot = try? await db
            .collection("users")
            .document(userId)
            .collection("favorites")
            .whereField("productId", isEqualTo: product.id)
            .whereField("customizationHash", isEqualTo: hash)
            .getDocuments()

        isFavorite = !(snapshot?.documents.isEmpty ?? true)
    }
    
    // MARK: - Toggle favorite for a product
    func toggleFavorite(product: Product, selections: [String: String], selectedExtras: [String]) async {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        let customizations = currentCustomizationForFavorite(selections: selections, selectedExtras: selectedExtras)
        let hash = buildCustomizationHash(customizations)

        let ref = db.collection("users").document(userId).collection("favorites")
        let snapshot = try? await ref
            .whereField("productId", isEqualTo: product.id)
            .whereField("customizationHash", isEqualTo: hash)
            .getDocuments()

        if let doc = snapshot?.documents.first {
            try? await doc.reference.delete()
            isFavorite = false
        } else {
            try? await ref.addDocument(data: [
                "productId": product.id,
                "productName": product.name,
                "imageURL": product.imageURL,
                "basePrice": product.price,
                "customizations": customizations,
                "customizationHash": hash,
                "createdAt": Date()
            ])
            isFavorite = true
        }
    }

    // MARK: - Load all favorites for current user
    func loadAllFavorites() async {
        guard let userId = Auth.auth().currentUser?.uid else { return }

        do {
            let snapshot = try await db
                .collection("users")
                .document(userId)
                .collection("favorites")
                .order(by: "createdAt", descending: true)
                .getDocuments()

            favorites = snapshot.documents.compactMap { doc in
                guard
                    let productName = doc["productName"] as? String,
                    let imageURL = doc["imageURL"] as? String,
                    let basePrice = doc["basePrice"] as? Double,
                    let customizations = doc["customizations"] as? [String: String],
                    let customizationHash = doc["customizationHash"] as? String
                else { return nil }

                return FavoriteItem(
                    id: doc.documentID,
                    productId: doc["productId"] as? String ?? "",
                    productName: productName,
                    imageURL: imageURL,
                    basePrice: basePrice,
                    customizations: customizations,
                    customizationHash: customizationHash
                )
            }
        } catch {
            print("Failed to load favorites:", error)
        }
    }

    // MARK: - Utils
    func buildCustomizationHash(_ customizations: [String: String]) -> String {
        customizations
            .sorted { $0.key.localizedCaseInsensitiveCompare($1.key) == .orderedAscending }
            .map { "\($0.key):\($0.value)" }
            .joined(separator: "|")
    }
}
