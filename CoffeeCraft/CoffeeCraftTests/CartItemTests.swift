//
//  CartItemTests.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 12/03/2026.
//
//  Comprehensive unit tests for the CartItem model and price calculations
//

import XCTest
@testable import CoffeeCraft

final class CartItemTests: XCTestCase {
    
    // MARK: - Test Properties
    
    var baseProduct: Product!
    var productWithCustomizations: Product!
    var simpleCartItem: CartItem!
    var customizedCartItem: CartItem!
    
    // MARK: - Setup & Teardown
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        // Simple product without customizations
        baseProduct = Product(
            id: "product_001",
            name: "Black Coffee",
            description: "Simple black coffee",
            price: 3.00,
            imageURL: "coffee.jpg",
            category: "Beverages"
        )
        
        // Product with customizations
        productWithCustomizations = Product(
            id: "product_002",
            name: "Customizable Latte",
            description: "Latte with options",
            price: 4.00,
            imageURL: "latte.jpg",
            category: "Beverages",
            customizations: [
                "Size": ["Small": 0.0, "Medium": 0.50, "Large": 1.00],
                "Milk": ["Whole": 0.0, "Almond": 0.50, "Oat": 0.75],
                "Sweetness": ["None": 0.0, "Light": 0.0, "Regular": 0.25],
                "Extras": ["Extra Shot": 1.00, "Whipped Cream": 0.50, "Caramel Drizzle": 0.75]
            ]
        )
        
        // Simple cart item without customizations
        simpleCartItem = CartItem(
            id: UUID(),
            product: baseProduct,
            selections: [:],
            extras: [],
            quantity: 1
        )
        
        // Customized cart item
        customizedCartItem = CartItem(
            id: UUID(),
            product: productWithCustomizations,
            selections: ["Size": "Large", "Milk": "Oat", "Sweetness": "Regular"],
            extras: ["Extra Shot", "Whipped Cream"],
            quantity: 2
        )
    }
    
    override func tearDownWithError() throws {
        baseProduct = nil
        productWithCustomizations = nil
        simpleCartItem = nil
        customizedCartItem = nil
        try super.tearDownWithError()
    }
    
    // MARK: - Basic Property Tests
    
    func testCartItemInitialization() {
        XCTAssertNotNil(simpleCartItem.id)
        XCTAssertEqual(simpleCartItem.product.id, baseProduct.id)
        XCTAssertEqual(simpleCartItem.quantity, 1)
        XCTAssertTrue(simpleCartItem.selections.isEmpty)
        XCTAssertTrue(simpleCartItem.extras.isEmpty)
    }
    
    func testCustomizedCartItemInitialization() {
        XCTAssertEqual(customizedCartItem.quantity, 2)
        XCTAssertEqual(customizedCartItem.selections.count, 3)
        XCTAssertEqual(customizedCartItem.extras.count, 2)
        XCTAssertEqual(customizedCartItem.selections["Size"], "Large")
        XCTAssertEqual(customizedCartItem.selections["Milk"], "Oat")
        XCTAssertTrue(customizedCartItem.extras.contains("Extra Shot"))
    }
    
    // MARK: - Total Price Calculation Tests
    
    func testBasePriceWithoutCustomizations() {
        let totalPrice = simpleCartItem.totalPrice
        
        // Base price: $3.00 × quantity 1 = $3.00
        XCTAssertEqual(totalPrice, 3.00, accuracy: 0.01)
    }
    
    func testPriceWithQuantity() {
        let multiQuantityItem = CartItem(
            id: UUID(),
            product: baseProduct,
            selections: [:],
            extras: [],
            quantity: 5
        )
        
        let totalPrice = multiQuantityItem.totalPrice
        
        // Base price: $3.00 × quantity 5 = $15.00
        XCTAssertEqual(totalPrice, 15.00, accuracy: 0.01)
    }
    
    func testPriceWithSingleSelection() {
        let item = CartItem(
            id: UUID(),
            product: productWithCustomizations,
            selections: ["Size": "Large"],  // +$1.00
            extras: [],
            quantity: 1
        )
        
        let totalPrice = item.totalPrice
        
        // Base: $4.00 + Large: $1.00 = $5.00 × 1 = $5.00
        XCTAssertEqual(totalPrice, 5.00, accuracy: 0.01)
    }
    
    func testPriceWithMultipleSelections() {
        let item = CartItem(
            id: UUID(),
            product: productWithCustomizations,
            selections: [
                "Size": "Large",      // +$1.00
                "Milk": "Oat",        // +$0.75
                "Sweetness": "Regular" // +$0.25
            ],
            extras: [],
            quantity: 1
        )
        
        let totalPrice = item.totalPrice
        
        // Base: $4.00 + $1.00 + $0.75 + $0.25 = $6.00 × 1 = $6.00
        XCTAssertEqual(totalPrice, 6.00, accuracy: 0.01)
    }
    
    func testPriceWithExtras() {
        let item = CartItem(
            id: UUID(),
            product: productWithCustomizations,
            selections: [:],
            extras: ["Extra Shot", "Whipped Cream"],  // +$1.00 + $0.50
            quantity: 1
        )
        
        let totalPrice = item.totalPrice
        
        // Base: $4.00 + $1.00 + $0.50 = $5.50 × 1 = $5.50
        XCTAssertEqual(totalPrice, 5.50, accuracy: 0.01)
    }
    
    func testPriceWithSelectionsAndExtras() {
        let totalPrice = customizedCartItem.totalPrice
        
        // Base: $4.00
        // Size Large: +$1.00
        // Milk Oat: +$0.75
        // Sweetness Regular: +$0.25
        // Extra Shot: +$1.00
        // Whipped Cream: +$0.50
        // Total per item: $7.50
        // Quantity: 2
        // Final: $15.00
        XCTAssertEqual(totalPrice, 15.00, accuracy: 0.01)
    }
    
    func testPriceWithFreeOptions() {
        let item = CartItem(
            id: UUID(),
            product: productWithCustomizations,
            selections: [
                "Size": "Small",       // $0.00
                "Milk": "Whole",       // $0.00
                "Sweetness": "None"    // $0.00
            ],
            extras: [],
            quantity: 1
        )
        
        let totalPrice = item.totalPrice
        
        // Base: $4.00 + $0.00 + $0.00 + $0.00 = $4.00
        XCTAssertEqual(totalPrice, 4.00, accuracy: 0.01)
    }
    
    func testPriceIgnoresExtrasCategory() {
        // The logic skips the "Extras" category in selections
        let productWithExtrasInBoth = Product(
            id: "test_001",
            name: "Test Product",
            description: "Test",
            price: 5.00,
            imageURL: "test.jpg",
            category: "Test",
            customizations: [
                "Extras": ["Option A": 1.00, "Option B": 2.00]
            ]
        )
        
        // This should be ignored in selections (only processed via extras array)
        let item = CartItem(
            id: UUID(),
            product: productWithExtrasInBoth,
            selections: ["Extras": "Option A"],  // This is ignored
            extras: ["Option B"],  // This is counted: +$2.00
            quantity: 1
        )
        
        let totalPrice = item.totalPrice
        
        // Base: $5.00 + Extra B from extras array: $2.00 = $7.00
        XCTAssertEqual(totalPrice, 7.00, accuracy: 0.01)
    }
    
    // MARK: - Edge Cases
    
    func testZeroQuantity() {
        let item = CartItem(
            id: UUID(),
            product: baseProduct,
            selections: [:],
            extras: [],
            quantity: 0
        )
        
        let totalPrice = item.totalPrice
        XCTAssertEqual(totalPrice, 0.0, accuracy: 0.01)
    }
    
    func testNonExistentSelection() {
        let item = CartItem(
            id: UUID(),
            product: productWithCustomizations,
            selections: ["NonExistent": "Value"],
            extras: [],
            quantity: 1
        )
        
        let totalPrice = item.totalPrice
        
        // Should fall back to base price since selection doesn't exist
        XCTAssertEqual(totalPrice, 4.00, accuracy: 0.01)
    }
    
    func testNonExistentExtra() {
        let item = CartItem(
            id: UUID(),
            product: productWithCustomizations,
            selections: [:],
            extras: ["NonExistent Extra"],
            quantity: 1
        )
        
        let totalPrice = item.totalPrice
        
        // Should fall back to base price since extra doesn't exist
        XCTAssertEqual(totalPrice, 4.00, accuracy: 0.01)
    }
    
    func testProductWithoutCustomizations() {
        let item = CartItem(
            id: UUID(),
            product: baseProduct,  // No customizations
            selections: ["Size": "Large"],
            extras: ["Extra Shot"],
            quantity: 2
        )
        
        let totalPrice = item.totalPrice
        
        // Should only count base price since no customizations exist
        // Base: $3.00 × 2 = $6.00
        XCTAssertEqual(totalPrice, 6.00, accuracy: 0.01)
    }
    
    func testLargeQuantity() {
        let item = CartItem(
            id: UUID(),
            product: productWithCustomizations,
            selections: ["Size": "Large"],
            extras: ["Extra Shot"],
            quantity: 100
        )
        
        let totalPrice = item.totalPrice
        
        // Base: $4.00 + Large: $1.00 + Extra Shot: $1.00 = $6.00 × 100 = $600.00
        XCTAssertEqual(totalPrice, 600.00, accuracy: 0.01)
    }
    
    func testAllExtras() {
        let item = CartItem(
            id: UUID(),
            product: productWithCustomizations,
            selections: [:],
            extras: ["Extra Shot", "Whipped Cream", "Caramel Drizzle"],
            quantity: 1
        )
        
        let totalPrice = item.totalPrice
        
        // Base: $4.00 + $1.00 + $0.50 + $0.75 = $6.25
        XCTAssertEqual(totalPrice, 6.25, accuracy: 0.01)
    }
    
    // MARK: - Codable Tests
    
    func testCartItemEncoding() throws {
        let encoder = JSONEncoder()
        let data = try encoder.encode(simpleCartItem)
        
        XCTAssertNotNil(data)
        XCTAssertGreaterThan(data.count, 0)
    }
    
    func testCartItemDecoding() throws {
        let encoder = JSONEncoder()
        let data = try encoder.encode(customizedCartItem)
        
        let decoder = JSONDecoder()
        let decodedItem = try decoder.decode(CartItem.self, from: data)
        
        XCTAssertEqual(decodedItem.id, customizedCartItem.id)
        XCTAssertEqual(decodedItem.product.id, customizedCartItem.product.id)
        XCTAssertEqual(decodedItem.quantity, customizedCartItem.quantity)
        XCTAssertEqual(decodedItem.selections, customizedCartItem.selections)
        XCTAssertEqual(decodedItem.extras, customizedCartItem.extras)
    }
    
    // MARK: - Complex Scenario Tests
    
    func testComplexCoffeeOrder() {
        // Realistic complex order
        let complexItem = CartItem(
            id: UUID(),
            product: productWithCustomizations,
            selections: [
                "Size": "Large",
                "Milk": "Oat",
                "Sweetness": "Light"
            ],
            extras: ["Extra Shot", "Caramel Drizzle"],
            quantity: 3
        )
        
        let totalPrice = complexItem.totalPrice
        
        // Base: $4.00
        // Size Large: +$1.00
        // Milk Oat: +$0.75
        // Sweetness Light: $0.00
        // Extra Shot: +$1.00
        // Caramel Drizzle: +$0.75
        // Per item: $7.50
        // Quantity 3: $22.50
        XCTAssertEqual(totalPrice, 22.50, accuracy: 0.01)
    }
    
    func testBulkOrderCalculation() {
        let products = [
            CartItem(id: UUID(), product: baseProduct, selections: [:], extras: [], quantity: 5),
            CartItem(id: UUID(), product: productWithCustomizations, selections: ["Size": "Large"], extras: ["Extra Shot"], quantity: 3),
            CartItem(id: UUID(), product: baseProduct, selections: [:], extras: [], quantity: 2)
        ]
        
        let total = products.reduce(0.0) { $0 + $1.totalPrice }
        
        // Item 1: $3.00 × 5 = $15.00
        // Item 2: ($4.00 + $1.00 + $1.00) × 3 = $18.00
        // Item 3: $3.00 × 2 = $6.00
        // Total: $39.00
        XCTAssertEqual(total, 39.00, accuracy: 0.01)
    }
}
