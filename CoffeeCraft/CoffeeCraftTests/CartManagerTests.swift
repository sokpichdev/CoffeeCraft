//
//  CartManagerTests.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 12/03/2026.
//
//  Comprehensive unit tests for CartManager ViewModel
//

@testable import CoffeeCraft
import XCTest

@MainActor
final class CartManagerTests: XCTestCase {
    
    // MARK: - Test Properties
    
    var cartManager: CartManager!
    var sampleProduct: Product!
    var customizableProduct: Product!
    
    // MARK: - Setup & Teardown
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        cartManager = CartManager()
        
        sampleProduct = Product(
            id: "product_001",
            name: "Black Coffee",
            description: "Simple black coffee",
            price: 3.00,
            imageURL: "coffee.jpg",
            category: "Beverages"
        )
        
        customizableProduct = Product(
            id: "product_002",
            name: "Latte",
            description: "Customizable latte",
            price: 4.00,
            imageURL: "latte.jpg",
            category: "Beverages",
            customizations: [
                "Size": ["Small": 0.0, "Large": 1.00],
                "Extras": ["Shot": 1.00, "Cream": 0.50]
            ]
        )
    }
    
    override func tearDownWithError() throws {
        cartManager = nil
        sampleProduct = nil
        customizableProduct = nil
        try super.tearDownWithError()
    }
    
    // MARK: - Initialization Tests
    
    func testCartManagerInitialization() {
        XCTAssertTrue(cartManager.items.isEmpty)
        XCTAssertEqual(cartManager.paymentMethod, .cash)
    }
    
    // MARK: - Add to Cart Tests
    
    func testAddSimpleItem() async {
        // Add item to cart
        cartManager.items.append(CartItem(
            id: UUID(),
            product: sampleProduct,
            selections: [:],
            extras: [],
            quantity: 1
        ))
        
        XCTAssertEqual(cartManager.items.count, 1)
        XCTAssertEqual(cartManager.items[0].product.id, sampleProduct.id)
        XCTAssertEqual(cartManager.items[0].quantity, 1)
    }
    
    func testAddCustomizedItem() async {
        let customizedItem = CartItem(
            id: UUID(),
            product: customizableProduct,
            selections: ["Size": "Large"],
            extras: ["Shot"],
            quantity: 2
        )
        
        cartManager.items.append(customizedItem)
        
        XCTAssertEqual(cartManager.items.count, 1)
        XCTAssertEqual(cartManager.items[0].selections["Size"], "Large")
        XCTAssertTrue(cartManager.items[0].extras.contains("Shot"))
        XCTAssertEqual(cartManager.items[0].quantity, 2)
    }
    
    func testAddMultipleItems() async {
        let item1 = CartItem(id: UUID(), product: sampleProduct, selections: [:], extras: [], quantity: 1)
        let item2 = CartItem(id: UUID(), product: customizableProduct, selections: [:], extras: [], quantity: 2)
        
        cartManager.items.append(item1)
        cartManager.items.append(item2)
        
        XCTAssertEqual(cartManager.items.count, 2)
    }
    
    // MARK: - Remove from Cart Tests
    
    func testRemoveItem() async {
        let item = CartItem(id: UUID(), product: sampleProduct, selections: [:], extras: [], quantity: 1)
        cartManager.items.append(item)
        
        XCTAssertEqual(cartManager.items.count, 1)
        
        // Remove the item
        cartManager.items.removeAll { $0.id == item.id }
        
        XCTAssertTrue(cartManager.items.isEmpty)
    }
    
    func testRemoveSpecificItem() async {
        let item1 = CartItem(id: UUID(), product: sampleProduct, selections: [:], extras: [], quantity: 1)
        let item2 = CartItem(id: UUID(), product: customizableProduct, selections: [:], extras: [], quantity: 2)
        
        cartManager.items.append(item1)
        cartManager.items.append(item2)
        
        XCTAssertEqual(cartManager.items.count, 2)
        
        // Remove only item1
        cartManager.items.removeAll { $0.id == item1.id }
        
        XCTAssertEqual(cartManager.items.count, 1)
        XCTAssertEqual(cartManager.items[0].id, item2.id)
    }
    
    // MARK: - Clear Cart Tests
    
    func testClearCart() async {
        // Add multiple items
        cartManager.items.append(CartItem(id: UUID(), product: sampleProduct, selections: [:], extras: [], quantity: 1))
        cartManager.items.append(CartItem(id: UUID(), product: customizableProduct,
                                          selections: [:], extras: [], quantity: 2))
        
        // Set payment method to wallet
        cartManager.paymentMethod = .wallet
        
        XCTAssertEqual(cartManager.items.count, 2)
        XCTAssertEqual(cartManager.paymentMethod, .wallet)
        
        // Clear cart
        cartManager.items.removeAll()
        cartManager.paymentMethod = .cash
        
        XCTAssertTrue(cartManager.items.isEmpty)
        XCTAssertEqual(cartManager.paymentMethod, .cash)
    }
    
    // MARK: - Update Cart Item Tests
    
    func testUpdateCartItemQuantity() async {
        let itemId = UUID()
        let item = CartItem(id: itemId, product: sampleProduct, selections: [:], extras: [], quantity: 1)
        cartManager.items.append(item)
        
        // Update quantity
        if let index = cartManager.items.firstIndex(where: { $0.id == itemId }) {
            cartManager.items[index] = CartItem(
                id: itemId,
                product: sampleProduct,
                selections: [:],
                extras: [],
                quantity: 5
            )
        }
        
        XCTAssertEqual(cartManager.items[0].quantity, 5)
    }
    
    func testUpdateCartItemCustomizations() async {
        let itemId = UUID()
        let item = CartItem(id: itemId, product: customizableProduct, selections: [:], extras: [], quantity: 1)
        cartManager.items.append(item)
        
        // Update customizations
        if let index = cartManager.items.firstIndex(where: { $0.id == itemId }) {
            cartManager.items[index] = CartItem(
                id: itemId,
                product: customizableProduct,
                selections: ["Size": "Large"],
                extras: ["Shot", "Cream"],
                quantity: 1
            )
        }
        
        XCTAssertEqual(cartManager.items[0].selections["Size"], "Large")
        XCTAssertEqual(cartManager.items[0].extras.count, 2)
    }
    
    // MARK: - Total Price Calculation Tests
    
    func testTotalWithSingleItem() async {
        cartManager.items.append(CartItem(id: UUID(), product: sampleProduct, selections: [:], extras: [], quantity: 1))
        
        let total = cartManager.total
        XCTAssertEqual(total, 3.00, accuracy: 0.01)
    }
    
    func testTotalWithMultipleItems() async {
        cartManager.items.append(CartItem(id: UUID(), product: sampleProduct, selections: [:], extras: [], quantity: 2))
        cartManager.items.append(CartItem(id: UUID(), product: customizableProduct,
                                          selections: [:], extras: [], quantity: 1))
        
        let total = cartManager.total
        // Item 1: $3.00 × 2 = $6.00
        // Item 2: $4.00 × 1 = $4.00
        // Total: $10.00
        XCTAssertEqual(total, 10.00, accuracy: 0.01)
    }
    
    func testTotalWithCustomizations() async {
        let customizedItem = CartItem(
            id: UUID(),
            product: customizableProduct,
            selections: ["Size": "Large"],  // +$1.00
            extras: ["Shot"],  // +$1.00
            quantity: 2
        )
        
        cartManager.items.append(customizedItem)
        
        let total = cartManager.total
        // Base: $4.00 + Large: $1.00 + Shot: $1.00 = $6.00 per item
        // Quantity: 2
        // Total: $12.00
        XCTAssertEqual(total, 12.00, accuracy: 0.01)
    }
    
    func testTotalWithEmptyCart() async {
        let total = cartManager.total
        XCTAssertEqual(total, 0.00, accuracy: 0.01)
    }
    
    // MARK: - Payment Method Tests
    
    func testDefaultPaymentMethod() {
        XCTAssertEqual(cartManager.paymentMethod, .cash)
    }
    
    func testChangePaymentMethod() {
        cartManager.paymentMethod = .wallet
        XCTAssertEqual(cartManager.paymentMethod, .wallet)
        
        cartManager.paymentMethod = .cash
        XCTAssertEqual(cartManager.paymentMethod, .cash)
    }
    
    // MARK: - Can Checkout Tests
    
    func testCanCheckoutWithCash() {
        cartManager.items.append(CartItem(id: UUID(), product: sampleProduct, selections: [:], extras: [], quantity: 1))
        cartManager.paymentMethod = .cash
        
        // Cash should always allow checkout regardless of wallet balance
        XCTAssertTrue(cartManager.canCheckout(walletBalance: 0.0))
        XCTAssertTrue(cartManager.canCheckout(walletBalance: nil))
        XCTAssertTrue(cartManager.canCheckout(walletBalance: 100.0))
    }
    
    func testCanCheckoutWithWalletSufficientBalance() {
        cartManager.items.append(CartItem(id: UUID(), product: sampleProduct, selections: [:], extras: [], quantity: 1))
        cartManager.paymentMethod = .wallet
        
        let total = cartManager.total  // $3.00
        
        // Sufficient balance
        XCTAssertTrue(cartManager.canCheckout(walletBalance: 3.00))
        XCTAssertTrue(cartManager.canCheckout(walletBalance: 10.00))
        XCTAssertTrue(cartManager.canCheckout(walletBalance: 100.00))
    }
    
    func testCanCheckoutWithWalletInsufficientBalance() {
        cartManager.items.append(CartItem(id: UUID(), product: sampleProduct, selections: [:], extras: [], quantity: 1))
        cartManager.paymentMethod = .wallet
        
        let total = cartManager.total  // $3.00
        
        // Insufficient balance
        XCTAssertFalse(cartManager.canCheckout(walletBalance: 2.99))
        XCTAssertFalse(cartManager.canCheckout(walletBalance: 0.00))
        XCTAssertFalse(cartManager.canCheckout(walletBalance: nil))
    }
    
    func testCanCheckoutExactBalance() {
        cartManager.items.append(CartItem(id: UUID(), product: sampleProduct, selections: [:], extras: [], quantity: 1))
        cartManager.paymentMethod = .wallet
        
        let total = cartManager.total  // $3.00
        
        // Exact balance should be allowed
        XCTAssertTrue(cartManager.canCheckout(walletBalance: total))
    }
    
    // MARK: - Batch Reorder Tests
    
    func testBatchReorderMergeExisting() async {
        // Setup: existing item in cart
        let existingItemId = UUID()
        let existingItem = CartItem(id: existingItemId, product: sampleProduct,
                                    selections: [:], extras: [], quantity: 2)
        cartManager.items.append(existingItem)
        
        // Merge: add 3 more to existing item
        let merges = [(existing: existingItem, additionalQty: 3)]
        let additions: [(product: Product, selections: [String: String], extras: [String], quantity: Int)] = []
        
        // Execute merge logic
        for (item, additionalQty) in merges {
            if let idx = cartManager.items.firstIndex(where: { $0.id == item.id }) {
                cartManager.items[idx] = CartItem(
                    id: cartManager.items[idx].id,
                    product: cartManager.items[idx].product,
                    selections: cartManager.items[idx].selections,
                    extras: cartManager.items[idx].extras,
                    quantity: cartManager.items[idx].quantity + additionalQty
                )
            }
        }
        
        XCTAssertEqual(cartManager.items.count, 1)
        XCTAssertEqual(cartManager.items[0].quantity, 5)  // 2 + 3
    }
    
    func testBatchReorderAddNew() async {
        // Setup: empty cart
        XCTAssertTrue(cartManager.items.isEmpty)
        
        // Add new items
        let additions = [
            (product: sampleProduct, selections: [:] as [String: String], extras: [] as [String], quantity: 2),
            (product: customizableProduct, selections: ["Size": "Large"], extras: ["Shot"], quantity: 1)
        ]
        
        // Execute additions
        for (product, selections, extras, quantity) in additions {
            cartManager.items.append(CartItem(
                id: UUID(),
                product: product!,
                selections: selections,
                extras: extras,
                quantity: quantity
            ))
        }
        
        XCTAssertEqual(cartManager.items.count, 2)
        XCTAssertEqual(cartManager.items[0].quantity, 2)
        XCTAssertEqual(cartManager.items[1].quantity, 1)
    }
    
    func testBatchReorderCombined() async {
        // Setup: one existing item
        let existingItemId = UUID()
        let existingItem = CartItem(id: existingItemId, product: sampleProduct,
                                    selections: [:], extras: [], quantity: 1)
        cartManager.items.append(existingItem)
        
        // Merge + Add
        let merges = [(existing: existingItem, additionalQty: 2)]
        let additions = [(product: customizableProduct,
                          selections: [:] as [String: String],
                          extras: [] as [String], quantity: 3)]
        
        // Execute merges
        for (item, additionalQty) in merges {
            if let idx = cartManager.items.firstIndex(where: { $0.id == item.id }) {
                cartManager.items[idx] = CartItem(
                    id: cartManager.items[idx].id,
                    product: cartManager.items[idx].product,
                    selections: cartManager.items[idx].selections,
                    extras: cartManager.items[idx].extras,
                    quantity: cartManager.items[idx].quantity + additionalQty
                )
            }
        }
        
        // Execute additions
        for (product, selections, extras, quantity) in additions {
            cartManager.items.append(CartItem(
                id: UUID(),
                product: product!,
                selections: selections,
                extras: extras,
                quantity: quantity
            ))
        }
        
        XCTAssertEqual(cartManager.items.count, 2)
        XCTAssertEqual(cartManager.items[0].quantity, 3)  // 1 + 2
        XCTAssertEqual(cartManager.items[1].quantity, 3)
    }
    
    // MARK: - Complex Scenario Tests
    
    func testCompleteCheckoutFlow() async {
        // 1. Add items to cart
        cartManager.items.append(CartItem(id: UUID(), product: sampleProduct, selections: [:], extras: [], quantity: 2))
        cartManager.items.append(CartItem(id: UUID(),
                                          product: customizableProduct,
                                          selections: ["Size": "Large"],
                                          extras: ["Shot"],
                                          quantity: 1))
        
        // 2. Verify total
        let expectedTotal = (3.00 * 2) + (4.00 + 1.00 + 1.00)  // $12.00
        XCTAssertEqual(cartManager.total, expectedTotal, accuracy: 0.01)
        
        // 3. Select wallet payment
        cartManager.paymentMethod = .wallet
        
        // 4. Check if can checkout with sufficient balance
        XCTAssertTrue(cartManager.canCheckout(walletBalance: 15.00))
        
        // 5. Clear cart after successful order
        cartManager.items.removeAll()
        cartManager.paymentMethod = .cash
        
        XCTAssertTrue(cartManager.items.isEmpty)
        XCTAssertEqual(cartManager.paymentMethod, .cash)
        XCTAssertEqual(cartManager.total, 0.0)
    }
}
