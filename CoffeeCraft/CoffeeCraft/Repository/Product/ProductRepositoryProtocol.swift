//
//  ProductRepositoryProtocol.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 3/11/26.
//
//  Defines every Firestore operation ProductViewModel needs.
//  No Firebase import — implementations bring their own dependencies.
//  In tests, swap FirestoreProductRepository for MockProductRepository.
//

protocol ProductRepositoryProtocol {

    /// Fetches the full product catalogue once.
    func fetchAll() async throws -> [Product]

    /// Attaches a real-time Firestore listener.
    /// Returns a cancel closure — call it to detach the listener.
    func listen(onChange: @escaping ([Product]) -> Void) -> () -> Void

    /// Creates a new product or overwrites an existing one.
    func save(_ product: Product) async throws

    /// Permanently deletes a product document.
    func delete(_ product: Product) async throws

    /// Flips `available = false` without deleting the document.
    func markUnavailable(_ product: Product) async throws
}
