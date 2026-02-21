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

    /// Tracks the last key we actually fired a Firestore request for.
    /// Format: "<productId>|<customizationHash>"
    /// Any call arriving with the same key is a duplicate and is dropped.
    private var lastLoadedKey: String? = nil

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
        guard let userId = Auth.auth().currentUser?.uid else {
            AppLog.menu.warning("⚠️ loadFavoriteState — no authenticated user, skipping")
            return
        }

        let customizations = currentCustomizationForFavorite(selections: selections, selectedExtras: selectedExtras)
        let hash = buildCustomizationHash(customizations)
        let key = "\(product.id)|\(hash)"

        /// SwiftUI can render a view multiple times in a single pass (sheet
        /// presentation, layout measurement, etc.), causing .task(id:) to fire
        /// several times with the identical id. Skip the Firestore round-trip
        /// if nothing has actually changed since the last completed fetch.
        guard key != lastLoadedKey else {
//            AppLog.menu.debug("⏭️ loadFavoriteState — duplicate key skipped: \(key)")
            return
        }
        lastLoadedKey = key

//        AppLog.menu.debug("🔍 loadFavoriteState — productId: \(product.id), hash: \(hash)")

        let snapshot = try? await db
            .collection("users")
            .document(userId)
            .collection("favorites")
            .whereField("productId", isEqualTo: product.id)
            .whereField("customizationHash", isEqualTo: hash)
            .getDocuments()

        isFavorite = !(snapshot?.documents.isEmpty ?? true)
        AppLog.menu.debug("❤️ loadFavoriteState — isFavorite: \(self.isFavorite) for productId: \(product.id)")
    }

    /// Call this in ProductDetailView's `.onDisappear` so the guard
    /// doesn't block a legitimate reload the next time the same product opens.
    func resetFavoriteState() {
        lastLoadedKey = nil
        isFavorite = false
    }
    
    // MARK: - Toggle favorite for a product
    func toggleFavorite(product: Product, selections: [String: String], selectedExtras: [String]) async {
        guard let userId = Auth.auth().currentUser?.uid else {
            AppLog.menu.warning("⚠️ toggleFavorite — no authenticated user, skipping")
            return
        }

        AppLog.menu.debug("🔀 toggleFavorite — productId: \(product.id), productName: \(product.name)")

        do {
            let customizations = currentCustomizationForFavorite(
                selections: selections,
                selectedExtras: selectedExtras
            )
            let hash = buildCustomizationHash(customizations)
            AppLog.menu.debug("🔀 toggleFavorite — customizationHash: \(hash)")

            let ref = db
                .collection("users")
                .document(userId)
                .collection("favorites")

            let snapshot = try await ref
                .whereField("productId", isEqualTo: product.id)
                .whereField("customizationHash", isEqualTo: hash)
                .getDocuments()

            if let doc = snapshot.documents.first {
                try await doc.reference.delete()
                isFavorite = false
                // Allow re-fetch after a toggle so the state stays in sync.
                lastLoadedKey = nil
                AppLog.menu.debug("🗑️ toggleFavorite — removed favorite, docId: \(doc.documentID), productId: \(product.id)")
            } else {
                let docRef = try await ref.addDocument(data: [
                    "productId": product.id,
                    "productName": product.name,
                    "imageURL": product.imageURL,
                    "basePrice": product.price,
                    "customizations": customizations,
                    "customizationHash": hash,
                    "createdAt": Date()
                ])
                isFavorite = true
                // Allow re-fetch after a toggle so the state stays in sync.
                lastLoadedKey = nil
                AppLog.menu.debug("✅ toggleFavorite — added favorite, docId: \(docRef.documentID), productId: \(product.id)")
            }
        } catch {
            AppLog.menu.error("❌ toggleFavorite — failed for productId: \(product.id): \(error.localizedDescription)")
            AlertManager.shared.showError(title: "Toggle Favorite Failed", message: error.localizedDescription)
        }
    }

    // MARK: - Load all favorites for current user
    func loadAllFavorites() async {
        guard let userId = Auth.auth().currentUser?.uid else {
            AppLog.menu.warning("⚠️ loadAllFavorites — no authenticated user, skipping")
            return
        }
        AppLog.menu.debug("📋 loadAllFavorites — fetching favorites for uid: \(userId)")

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
                else {
                    AppLog.menu.warning("⚠️ loadAllFavorites — skipped malformed doc: \(doc.documentID)")
                    return nil
                }

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
            AppLog.printList(favorites, label: "Favorites", logger: AppLog.menu)
        } catch {
            AppLog.menu.error("❌ loadAllFavorites — failed for uid: \(userId): \(error.localizedDescription)")
            AlertManager.shared.showError(title: "Failed to load favorites", message: error.localizedDescription)
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
