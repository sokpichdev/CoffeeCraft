//
//  ProductTests.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 12/03/2026.
//
//  Comprehensive unit tests for the Product model
//

import XCTest
@testable import CoffeeCraft

final class ProductTests: XCTestCase {
    
    // MARK: - Test Properties
    
    var sampleProduct: Product!
    var productWithRatings: Product!
    var productWithoutRatings: Product!
    
    // MARK: - Setup & Teardown
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        // Basic product without ratings
        sampleProduct = Product(
            id: "product_001",
            name: "Cappuccino",
            description: "Rich and creamy cappuccino",
            price: 4.50,
            imageURL: "https://example.com/cappuccino.jpg",
            category: "Hot Beverages",
            available: true,
            customizations: [
                "Size": ["Small": 0.0, "Medium": 0.50, "Large": 1.00],
                "Milk": ["Whole": 0.0, "Skim": 0.0, "Oat": 0.50],
                "Extras": ["Extra Shot": 1.00, "Whipped Cream": 0.50]
            ]
        )
        
        // Product with ratings
        productWithRatings = Product(
            id: "product_002",
            name: "Latte",
            description: "Smooth espresso with steamed milk",
            price: 4.00,
            imageURL: "https://example.com/latte.jpg",
            category: "Hot Beverages",
            available: true,
            customizations: nil,
            avgRating: 4.5,
            ratingCount: 100,
            ratingDistribution: ["5": 60, "4": 25, "3": 10, "2": 3, "1": 2]
        )
        
        // Product without ratings (legacy)
        productWithoutRatings = Product(
            id: "product_003",
            name: "Americano",
            description: "Classic black coffee",
            price: 3.50,
            imageURL: "https://example.com/americano.jpg",
            category: "Hot Beverages",
            available: false
        )
    }
    
    override func tearDownWithError() throws {
        sampleProduct = nil
        productWithRatings = nil
        productWithoutRatings = nil
        try super.tearDownWithError()
    }
    
    // MARK: - Basic Property Tests
    
    func testProductInitialization() {
        XCTAssertEqual(sampleProduct.id, "product_001")
        XCTAssertEqual(sampleProduct.name, "Cappuccino")
        XCTAssertEqual(sampleProduct.description, "Rich and creamy cappuccino")
        XCTAssertEqual(sampleProduct.price, 4.50, accuracy: 0.01)
        XCTAssertEqual(sampleProduct.category, "Hot Beverages")
        XCTAssertTrue(sampleProduct.available)
        XCTAssertNotNil(sampleProduct.customizations)
    }
    
    func testProductAvailability() {
        XCTAssertTrue(sampleProduct.available)
        XCTAssertFalse(productWithoutRatings.available)
    }
    
    func testProductCustomizations() {
        XCTAssertNotNil(sampleProduct.customizations)
        XCTAssertEqual(sampleProduct.customizations?.count, 3)
        
        let sizeOptions = sampleProduct.customizations?["Size"]
        XCTAssertNotNil(sizeOptions)
        XCTAssertEqual(sizeOptions?["Small"], 0.0)
        XCTAssertEqual(sizeOptions?["Medium"], 0.50)
        XCTAssertEqual(sizeOptions?["Large"], 1.00)
    }
    
    // MARK: - Rating Tests
    
    func testDisplayRatingWithRatings() {
        XCTAssertEqual(productWithRatings.displayRating, 4.5, accuracy: 0.01)
    }
    
    func testDisplayRatingWithoutRatings() {
        XCTAssertEqual(productWithoutRatings.displayRating, 0.0, accuracy: 0.01)
    }
    
    func testDisplayRatingCountWithRatings() {
        XCTAssertEqual(productWithRatings.displayRatingCount, 100)
    }
    
    func testDisplayRatingCountWithoutRatings() {
        XCTAssertEqual(productWithoutRatings.displayRatingCount, 0)
    }
    
    func testHasRatingsTrue() {
        XCTAssertTrue(productWithRatings.hasRatings)
    }
    
    func testHasRatingsFalse() {
        XCTAssertFalse(productWithoutRatings.hasRatings)
    }
    
    func testOrderedDistribution() {
        let distribution = productWithRatings.orderedDistribution
        
        XCTAssertEqual(distribution.count, 5)
        XCTAssertEqual(distribution[0].score, 5)
        XCTAssertEqual(distribution[0].count, 60)
        XCTAssertEqual(distribution[1].score, 4)
        XCTAssertEqual(distribution[1].count, 25)
        XCTAssertEqual(distribution[2].score, 3)
        XCTAssertEqual(distribution[2].count, 10)
        XCTAssertEqual(distribution[3].score, 2)
        XCTAssertEqual(distribution[3].count, 3)
        XCTAssertEqual(distribution[4].score, 1)
        XCTAssertEqual(distribution[4].count, 2)
    }
    
    func testOrderedDistributionWithMissingKeys() {
        let productWithPartialRatings = Product(
            id: "product_004",
            name: "Espresso",
            description: "Strong shot of coffee",
            price: 3.00,
            imageURL: "https://example.com/espresso.jpg",
            category: "Hot Beverages",
            avgRating: 4.0,
            ratingCount: 10,
            ratingDistribution: ["5": 5, "3": 3, "1": 2]  // Missing 4 and 2
        )
        
        let distribution = productWithPartialRatings.orderedDistribution
        
        XCTAssertEqual(distribution.count, 5)
        XCTAssertEqual(distribution[0].count, 5)  // Score 5
        XCTAssertEqual(distribution[1].count, 0)  // Score 4 (missing, defaults to 0)
        XCTAssertEqual(distribution[2].count, 3)  // Score 3
        XCTAssertEqual(distribution[3].count, 0)  // Score 2 (missing, defaults to 0)
        XCTAssertEqual(distribution[4].count, 2)  // Score 1
    }
    
    // MARK: - Hashable & Equatable Tests
    
    func testProductEquality() {
        let product1 = Product(
            id: "same_id",
            name: "Coffee A",
            description: "Description A",
            price: 5.00,
            imageURL: "url_a",
            category: "Hot"
        )
        
        let product2 = Product(
            id: "same_id",
            name: "Coffee B",  // Different name
            description: "Description B",  // Different description
            price: 10.00,  // Different price
            imageURL: "url_b",  // Different URL
            category: "Cold"  // Different category
        )
        
        // Products should be equal if they have the same ID
        XCTAssertEqual(product1, product2)
    }
    
    func testProductInequality() {
        let product1 = Product(
            id: "id_001",
            name: "Coffee",
            description: "Description",
            price: 5.00,
            imageURL: "url",
            category: "Hot"
        )
        
        let product2 = Product(
            id: "id_002",
            name: "Coffee",
            description: "Description",
            price: 5.00,
            imageURL: "url",
            category: "Hot"
        )
        
        XCTAssertNotEqual(product1, product2)
    }
    
    func testProductHashValue() {
        let product1 = Product(
            id: "hash_test",
            name: "Test",
            description: "Test",
            price: 1.00,
            imageURL: "test",
            category: "Test"
        )
        
        let product2 = Product(
            id: "hash_test",
            name: "Different",
            description: "Different",
            price: 99.00,
            imageURL: "different",
            category: "Different"
        )
        
        // Same ID should produce same hash
        XCTAssertEqual(product1.hashValue, product2.hashValue)
    }
    
    func testProductInSet() {
        var productSet = Set<Product>()
        productSet.insert(sampleProduct)
        
        let duplicateProduct = Product(
            id: sampleProduct.id,
            name: "Different Name",
            description: "Different Description",
            price: 99.99,
            imageURL: "different_url",
            category: "Different Category"
        )
        
        productSet.insert(duplicateProduct)
        
        // Set should only contain one product (same ID)
        XCTAssertEqual(productSet.count, 1)
    }
    
    // MARK: - Empty Product Factory Test
    
    func testEmptyProductCreation() {
        let emptyProduct = Product.empty(in: "Desserts")
        
        XCTAssertFalse(emptyProduct.id.isEmpty)
        XCTAssertEqual(emptyProduct.name, "")
        XCTAssertEqual(emptyProduct.description, "")
        XCTAssertEqual(emptyProduct.price, 0.0, accuracy: 0.01)
        XCTAssertEqual(emptyProduct.imageURL, "")
        XCTAssertEqual(emptyProduct.category, "Desserts")
        XCTAssertTrue(emptyProduct.available)
        XCTAssertNotNil(emptyProduct.customizations)
        XCTAssertTrue(emptyProduct.customizations?.isEmpty ?? false)
    }
    
    // MARK: - Codable Tests
    
    func testProductEncoding() throws {
        let encoder = JSONEncoder()
        let data = try encoder.encode(sampleProduct)
        
        XCTAssertNotNil(data)
        XCTAssertGreaterThan(data.count, 0)
    }
    
    func testProductDecoding() throws {
        let encoder = JSONEncoder()
        let data = try encoder.encode(sampleProduct)
        
        let decoder = JSONDecoder()
        let decodedProduct = try decoder.decode(Product.self, from: data)
        
        XCTAssertEqual(decodedProduct.id, sampleProduct.id)
        XCTAssertEqual(decodedProduct.name, sampleProduct.name)
        XCTAssertEqual(decodedProduct.price, sampleProduct.price, accuracy: 0.01)
        XCTAssertEqual(decodedProduct.category, sampleProduct.category)
    }
    
    func testProductWithRatingsEncoding() throws {
        let encoder = JSONEncoder()
        let data = try encoder.encode(productWithRatings)
        
        let decoder = JSONDecoder()
        let decodedProduct = try decoder.decode(Product.self, from: data)
        
        XCTAssertEqual(decodedProduct.avgRating, productWithRatings.avgRating)
        XCTAssertEqual(decodedProduct.ratingCount, productWithRatings.ratingCount)
        XCTAssertEqual(decodedProduct.ratingDistribution, productWithRatings.ratingDistribution)
    }
    
    // MARK: - Edge Case Tests
    
    func testProductWithZeroPrice() {
        let freeProduct = Product(
            id: "free_001",
            name: "Free Sample",
            description: "Complimentary sample",
            price: 0.0,
            imageURL: "sample.jpg",
            category: "Samples"
        )
        
        XCTAssertEqual(freeProduct.price, 0.0, accuracy: 0.01)
    }
    
    func testProductWithNegativeRating() {
        // This shouldn't happen in practice, but test boundary
        let invalidProduct = Product(
            id: "invalid_001",
            name: "Invalid",
            description: "Invalid",
            price: 1.00,
            imageURL: "url",
            category: "Test",
            avgRating: -1.0,
            ratingCount: 5
        )
        
        XCTAssertEqual(invalidProduct.avgRating, -1.0)
        XCTAssertEqual(invalidProduct.displayRating, -1.0)
    }
    
    func testProductWithHighRating() {
        let highRatedProduct = Product(
            id: "high_001",
            name: "Perfect Coffee",
            description: "The best",
            price: 10.00,
            imageURL: "perfect.jpg",
            category: "Premium",
            avgRating: 5.0,
            ratingCount: 1000
        )
        
        XCTAssertEqual(highRatedProduct.avgRating, 5.0)
        XCTAssertTrue(highRatedProduct.hasRatings)
    }
}

// MARK: - Section Data Tests

final class SectionDataTests: XCTestCase {
    
    func testSectionDataInitialization() {
        let products = [
            Product(id: "1", name: "Coffee 1", description: "Desc", price: 3.00, imageURL: "url", category: "Hot"),
            Product(id: "2", name: "Coffee 2", description: "Desc", price: 4.00, imageURL: "url", category: "Hot")
        ]
        
        let section = SectionData(name: "Hot Beverages", items: products)
        
        XCTAssertEqual(section.id, "Hot Beverages")
        XCTAssertEqual(section.name, "Hot Beverages")
        XCTAssertEqual(section.items.count, 2)
    }
    
    func testEmptySection() {
        let section = SectionData(name: "Empty Section", items: [])
        
        XCTAssertEqual(section.name, "Empty Section")
        XCTAssertTrue(section.items.isEmpty)
    }
}

// MARK: - Menu Item Tests

final class MenuItemTests: XCTestCase {
    
    func testMenuItemInitialization() {
        let menuItem = MenuItem(name: "Espresso", price: 3.00, image: "espresso_icon")
        
        XCTAssertNotNil(menuItem.id)
        XCTAssertEqual(menuItem.name, "Espresso")
        XCTAssertEqual(menuItem.price, 3.00, accuracy: 0.01)
        XCTAssertEqual(menuItem.image, "espresso_icon")
    }
    
    func testMenuItemUniqueIDs() {
        let item1 = MenuItem(name: "Coffee", price: 1.00, image: "icon")
        let item2 = MenuItem(name: "Coffee", price: 1.00, image: "icon")
        
        XCTAssertNotEqual(item1.id, item2.id)
    }
}
