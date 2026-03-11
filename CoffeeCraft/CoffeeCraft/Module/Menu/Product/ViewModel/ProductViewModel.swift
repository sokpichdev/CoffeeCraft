import FirebaseFirestore
//
//  ProductViewModel.swift
//  CoffeeCraft
//
//  Sprint 2: Firestore removed — all data access goes through ProductRepositoryProtocol.
//  Inject FirestoreProductRepository in production; MockProductRepository in tests.
//  Performance trace added on fetchProducts() (menu_fetch).
//
import Foundation

@MainActor
class ProductViewModel: ObservableObject {
    @Published var products: [Product] = []
    @Published var sections: [SectionData] = []
    @Published var isLoading = false

    private let repository: ProductRepositoryProtocol
    private var cancelListener: (() -> Void)?

    init(repository: ProductRepositoryProtocol = FirestoreProductRepository()) {
        self.repository = repository
    }

    deinit {
        cancelListener?()
    }

    // MARK: - Fetch Once

    func fetchProducts() async {
        isLoading = true
        AppLog.menu.debug("📡 Fetching all products...")

        do {
            products = try await PerformanceService.shared.trace(.menuFetch) {
                try await repository.fetchAll()
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
        guard cancelListener == nil else {
            AppLog.menu.debug("👂 listenProducts — already active, skipping")
            return
        }

        AppLog.menu.debug("👂 Starting real-time listener for products...")
        isLoading = true

        cancelListener = repository.listen { [weak self] products in
            guard let self else { return }
            self.products = products
            AppLog.menu.debug("✅ Listener received \(products.count) product(s)")
            AppLog.printList(products, label: "Products (Live)", logger: AppLog.menu)
            self.computeSections()
            self.isLoading = false
        }
    }

    // MARK: - Refresh

    func refreshProducts() async {
        AppLog.menu.debug("🔄 Refreshing products — re-attaching listener")
        cancelListener?()
        cancelListener = nil
        products = []
        sections = []
        listenProducts()
    }

    // MARK: - Compute Sections

    func computeSections() {
        sections = Dictionary(grouping: products, by: { $0.category })
            .map { category, items in SectionData(name: category, items: items) }
            .sorted { $0.name < $1.name }
        AppLog.menu.debug("📂 Computed \(self.sections.count) section(s): \(self.sections.map { $0.name }.joined(separator: ", "))")
    }

    // MARK: - Save Product (Create / Update)

    func saveProduct(_ product: Product) async {
        let isNew = product.id.isEmpty
        var productToSave = product

        if isNew {
            productToSave.id = productToSave.name.generateProductID()
            AppLog.menu.debug("📡 Creating product: \(productToSave.name) id: \(productToSave.id)")
        } else {
            AppLog.menu.debug("📡 Updating product: \(productToSave.name) id: \(productToSave.id)")
        }

        do {
            try await repository.save(productToSave)
            if let index = products.firstIndex(where: { $0.id == productToSave.id }) {
                products[index] = productToSave
            } else {
                products.append(productToSave)
            }
            computeSections()
            AppLog.menu.debug("✅ Product saved: \(productToSave.name)")
        } catch {
            AppLog.menu.error("❌ Failed to save product \(productToSave.name): \(error.localizedDescription)")
        }
    }

    // MARK: - Delete Product

    func deleteProduct(_ product: Product) async {
        AppLog.menu.debug("📡 Deleting product: \(product.name) id: \(product.id)")
        do {
            try await repository.delete(product)
            products.removeAll { $0.id == product.id }
            computeSections()
            AppLog.menu.debug("✅ Product deleted: \(product.name)")
        } catch {
            AppLog.menu.error("❌ Failed to delete product \(product.name): \(error.localizedDescription)")
        }
    }

    // MARK: - Mark Unavailable

    func markUnavailable(_ product: Product) async {
        AppLog.menu.debug("📡 Marking unavailable: \(product.name)")
        do {
            try await repository.markUnavailable(product)
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
