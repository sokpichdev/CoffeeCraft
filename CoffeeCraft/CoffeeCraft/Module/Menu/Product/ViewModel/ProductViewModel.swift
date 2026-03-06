import FirebaseFirestore
//
//  ProductViewModel.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 10/20/25.
//
import Foundation

@MainActor
class ProductViewModel: ObservableObject {
    @Published var products: [Product] = []
    @Published var sections: [SectionData] = []
    @Published var isLoading = false

    private let db = Firestore.firestore()
    private var listener: ListenerRegistration?

    deinit {
        listener?.remove()
    }

    // MARK: - Fetch Once
    func fetchProducts() async {
        isLoading = true
        
        AppLog.menu.debug("📡 Fetching all products...")
        
        do {
            let snapshot = try await db.collection("products").getDocuments()
            products = snapshot.documents.map { doc in
                parseProduct(doc: doc)
            }
            
            AppLog.printList(products, label: "Products", logger: AppLog.menu)
            
            computeSections()
            try await MinimumLoadingTime(0.2).waitIfNeeded()
        } catch {
            AppLog.menu.error("❌ Failed to fetch products: \(error.localizedDescription)")
            AlertManager.shared.showError(message: error.localizedDescription)
        }
        isLoading = false
    }

    // MARK: - Listen for real-time updates
    func listenProducts() {
        guard listener == nil else {
            AppLog.menu.debug("👂 listenProducts — already active, skipping")
            return
        }
        
        AppLog.menu.debug("👂 Starting real-time listener for products...")
        isLoading = true
        
        listener = db.collection("products")
            .order(by: "category")
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                
                if let error = error {
                    AppLog.menu.error("❌ Listener error: \(error.localizedDescription)")
                    LoaderManager.shared.hideLoading()
                    AlertManager.shared.showError(message: error.localizedDescription)
                    return
                }
                
                guard let docs = snapshot?.documents else {
                    AppLog.menu.warning("⚠️ Snapshot is nil or has no documents")
                    return
                }

                self.products = docs.compactMap { self.parseProduct(doc: $0) }
                
                AppLog.menu.debug("✅ Listener received \(docs.count) product(s), decoded \(self.products.count)")
                AppLog.printList(self.products, label: "Products (Live)", logger: AppLog.menu)
                
                self.computeSections()
                isLoading  = false
            }
    }

    // MARK: - Refresh
    func refreshProducts() async {
        AppLog.menu.debug("🔄 Refreshing products...")
        listener?.remove()
        listener = nil
        
        await fetchProducts()
        listenProducts()
        
        AppLog.menu.debug("✅ Products refreshed and listener re-attached")
    }

    // MARK: - Parse Product
    private func parseProduct(doc: QueryDocumentSnapshot) -> Product {
        let data = doc.data()
        let product = Product(
            id: doc.documentID,
            name: data["name"] as? String ?? "",
            description: data["description"] as? String ?? "",
            price: data["price"] as? Double ?? 0.0,
            imageURL: data["imageURL"] as? String ?? "",
            category: data["category"] as? String ?? "Others",
            available: data["available"] as? Bool ?? true,
            customizations: data["customizations"] as? [String: [String: Double]] ?? [:]
        )
        return product
    }

    // MARK: - Compute Sections
    func computeSections() {
        sections = Dictionary(grouping: products, by: { $0.category })
            .map { category, items in
                SectionData(name: category, items: items)
            }
            .sorted { $0.name < $1.name }
        
        AppLog.menu.debug("📂 Computed \(self.sections.count) section(s): \(self.sections.map { $0.name }.joined(separator: ", "))")
    }

    // MARK: - Save Product (Create / Update)
    func saveProduct(_ product: Product) async {
        let isNewProduct = product.id.isEmpty
        var productToSave = product

        if isNewProduct {
            productToSave.id = productToSave.name.generateProductID()
            AppLog.menu.debug("📡 Creating new product: \(productToSave.name) with id: \(productToSave.id)")
        } else {
            AppLog.menu.debug("📡 Updating product: \(productToSave.name) with id: \(productToSave.id)")
        }

        let data: [String: Any] = [
            "name": productToSave.name,
            "description": productToSave.description,
            "price": productToSave.price,
            "imageURL": productToSave.imageURL,
            "category": productToSave.category,
            "available": productToSave.available,
            "customizations": productToSave.customizations ?? [:]
        ]

        do {
            try await db.collection("products")
                .document(productToSave.id)
                .setData(data)

            if let index = products.firstIndex(where: { $0.id == productToSave.id }) {
                products[index] = productToSave
                AppLog.menu.debug("✅ Product updated locally: \(productToSave.name)")
            } else {
                products.append(productToSave)
                AppLog.menu.debug("✅ Product added locally: \(productToSave.name)")
            }
            computeSections()
        } catch {
            AppLog.menu.error("❌ Failed to save product \(productToSave.name): \(error.localizedDescription)")
        }
    }

    // MARK: - Delete Product
    func deleteProduct(_ product: Product) async {
        AppLog.menu.debug("📡 Deleting product: \(product.name) id: \(product.id)")
        do {
            try await db.collection("products").document(product.id).delete()
            if let index = products.firstIndex(of: product) {
                products.remove(at: index)
                computeSections()
            }
            AppLog.menu.debug("✅ Product deleted: \(product.name)")
        } catch {
            AppLog.menu.error("❌ Failed to delete product \(product.name): \(error.localizedDescription)")
        }
    }

    // MARK: - Mark Unavailable
    func markUnavailable(_ product: Product) async {
        AppLog.menu.debug("📡 Marking product unavailable: \(product.name)")
        do {
            try await db.collection("products").document(product.id).updateData(["available": false])
            if let index = products.firstIndex(of: product) {
                products[index].available = false
                computeSections()
            }
            AppLog.menu.debug("✅ Product marked unavailable: \(product.name)")
        } catch {
            AppLog.menu.error("❌ Failed to mark unavailable \(product.name): \(error.localizedDescription)")
        }
    }
}
