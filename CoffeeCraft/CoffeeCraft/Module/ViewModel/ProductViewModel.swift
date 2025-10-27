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
    @Published var sections: [SectionData] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let db = Firestore.firestore()
    private var listener: ListenerRegistration?

    deinit {
        listener?.remove()
    }

    // MARK: - Fetch Once
    func fetchProducts() async {
        isLoading = true
        errorMessage = nil
        do {
            let snapshot = try await db.collection("products").getDocuments()
            products = snapshot.documents.map { doc in
                parseProduct(doc: doc)
            }
            computeSections()
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    // MARK: - Listen for real-time updates
    func listenProducts() {
        listener?.remove()
        listener = db.collection("products")
            .order(by: "category")
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                if let error = error {
                    self.errorMessage = error.localizedDescription
                    return
                }
                guard let docs = snapshot?.documents else { return }

                self.products = docs.compactMap { self.parseProduct(doc: $0) }
                self.computeSections()
            }
    }

    private func parseProduct(doc: QueryDocumentSnapshot) -> Product {
        let data = doc.data()
        return Product(
            id: doc.documentID,
            name: data["name"] as? String ?? "",
            description: data["description"] as? String ?? "",
            price: data["price"] as? Double ?? 0.0,
            imageURL: data["imageURL"] as? String ?? "",
            category: data["category"] as? String ?? "Others",
            available: data["available"] as? Bool ?? true,
            customizations: data["customizations"] as? [String: [String]] ?? [:],
            priceModifiers: data["priceModifiers"] as? [String: [String: Double]] ?? [:]
        )
    }

    // MARK: - Compute Sections
    func computeSections() {
        sections = Dictionary(grouping: products, by: { $0.category })
            .map { category, items in
                SectionData(name: category, items: items)
            }
            .sorted { $0.name < $1.name }
    }

    // MARK: - CRUD Operations
    func saveProduct(_ product: Product) async {
        let data: [String: Any] = [
            "name": product.name,
            "description": product.description,
            "price": product.price,
            "imageURL": product.imageURL,
            "category": product.category,
            "available": product.available,
            "customizations": product.customizations ?? [:],
            "priceModifiers": product.priceModifiers ?? [:]
        ]

        do {
            try await db.collection("products").document(product.id).setData(data)
            
            // Update local array immediately for UI
            if let index = products.firstIndex(of: product) {
                products[index] = product
            } else {
                products.append(product)
            }
            computeSections()
        } catch {
            print("❌ Save error:", error.localizedDescription)
        }
    }

    func deleteProduct(_ product: Product) async {
        do {
            try await db.collection("products").document(product.id).delete()
            if let index = products.firstIndex(of: product) {
                products.remove(at: index)
                computeSections()
            }
        } catch {
            print("❌ Delete error:", error.localizedDescription)
        }
    }

    func markUnavailable(_ product: Product) async {
        do {
            try await db.collection("products").document(product.id).updateData(["available": false])
            if let index = products.firstIndex(of: product) {
                products[index].available = false
                computeSections()
            }
        } catch {
            print("⚠️ Mark unavailable error:", error.localizedDescription)
        }
    }
}

