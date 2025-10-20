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
            self.products = snapshot.documents.compactMap { doc in
                try? doc.data(as: Product.self)
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}
