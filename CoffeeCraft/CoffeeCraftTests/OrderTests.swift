//
//  OrderTests.swift
//  CoffeeCraftTests
//
//  Comprehensive unit tests for the Order and CartItemData models
//

import XCTest
@testable import CoffeeCraft

final class OrderTests: XCTestCase {
    
    // MARK: - Test Properties
    
    var sampleOrder: Order!
    var walletPaidOrder: Order!
    var cashOrder: Order!
    var legacyOrder: Order!
    
    // MARK: - Setup & Teardown
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        let sampleItems: [CartItemData] = [
            CartItemData(
                productId: "product_001",
                name: "Latte",
                imageURL: "latte.jpg",
                selections: ["Size": "Medium"],
                extras: ["Extra Shot"],
                price: 5.50,
                quantity: 2
            ),
            CartItemData(
                productId: "product_002",
                name: "Cappuccino",
                imageURL: "cappuccino.jpg",
                selections: ["Size": "Large"],
                extras: [],
                price: 4.75,
                quantity: 1
            )
        ]
        
        // Modern order with wallet payment
        walletPaidOrder = Order(
            id: "order_001",
            orderId: 12345,
            userId: "user_001",
            items: sampleItems,
            totalPrice: 15.75,
            status: "completed",
            timestamp: Date(),
            paymentMethod: PaymentMethod.wallet.rawValue,
            walletAmountPaid: 15.75,
            branchId: "branch_001",
            branchName: "Downtown Branch",
            productIds: ["product_001", "product_002"]
        )
        
        // Cash order
        cashOrder = Order(
            id: "order_002",
            orderId: 12346,
            userId: "user_001",
            items: sampleItems,
            totalPrice: 15.75,
            status: "pending",
            timestamp: Date(),
            paymentMethod: PaymentMethod.cash.rawValue,
            walletAmountPaid: nil,
            branchId: "branch_002",
            branchName: "Uptown Branch",
            productIds: ["product_001", "product_002"]
        )
        
        // Legacy order (pre-Phase 4)
        legacyOrder = Order(
            id: "order_003",
            orderId: 12000,
            userId: "user_002",
            items: sampleItems,
            totalPrice: 15.75,
            status: "completed",
            timestamp: Date()
        )
        
        // Sample standard order
        sampleOrder = walletPaidOrder
    }
    
    override func tearDownWithError() throws {
        sampleOrder = nil
        walletPaidOrder = nil
        cashOrder = nil
        legacyOrder = nil
        try super.tearDownWithError()
    }
    
    // MARK: - Basic Property Tests
    
    func testOrderInitialization() {
        XCTAssertEqual(walletPaidOrder.id, "order_001")
        XCTAssertEqual(walletPaidOrder.orderId, 12345)
        XCTAssertEqual(walletPaidOrder.userId, "user_001")
        XCTAssertEqual(walletPaidOrder.totalPrice ?? 0.0, 15.75, accuracy: 0.01)
        XCTAssertEqual(walletPaidOrder.status, "completed")
        XCTAssertNotNil(walletPaidOrder.timestamp)
    }
    
    func testOrderItems() {
        XCTAssertEqual(walletPaidOrder.items?.count, 2)
        XCTAssertEqual(walletPaidOrder.items?[0]?.name, "Latte")
        XCTAssertEqual(walletPaidOrder.items?[1]?.name, "Cappuccino")
    }
    
    // MARK: - Payment Method Tests
    
    func testWasWalletPaymentTrue() {
        XCTAssertTrue(walletPaidOrder.wasWalletPayment)
    }
    
    func testWasWalletPaymentFalse() {
        XCTAssertFalse(cashOrder.wasWalletPayment)
    }
    
    func testLegacyOrderWasWalletPayment() {
        // Legacy orders without paymentMethod should return false
        XCTAssertFalse(legacyOrder.wasWalletPayment)
    }
    
    func testWalletAmountPaid() {
        XCTAssertEqual(walletPaidOrder.walletAmountPaid ?? 0.0, 15.75, accuracy: 0.01)
        XCTAssertNil(cashOrder.walletAmountPaid)
        XCTAssertNil(legacyOrder.walletAmountPaid)
    }
    
    // MARK: - Branch Information Tests
    
    func testBranchInformation() {
        XCTAssertEqual(walletPaidOrder.branchId, "branch_001")
        XCTAssertEqual(walletPaidOrder.branchName, "Downtown Branch")
        
        XCTAssertEqual(cashOrder.branchId, "branch_002")
        XCTAssertEqual(cashOrder.branchName, "Uptown Branch")
    }
    
    func testLegacyOrderWithoutBranch() {
        XCTAssertNil(legacyOrder.branchId)
        XCTAssertNil(legacyOrder.branchName)
    }
    
    // MARK: - Product IDs Tests
    
    func testProductIds() {
        XCTAssertNotNil(walletPaidOrder.productIds)
        XCTAssertEqual(walletPaidOrder.productIds?.count, 2)
        XCTAssertTrue(walletPaidOrder.productIds?.contains("product_001") ?? false)
        XCTAssertTrue(walletPaidOrder.productIds?.contains("product_002") ?? false)
    }
    
    func testLegacyOrderWithoutProductIds() {
        XCTAssertNil(legacyOrder.productIds)
    }
    
    // MARK: - Hashable & Equatable Tests
    
    func testOrderEquality() {
        let order1 = Order(
            id: "same_id",
            orderId: 100,
            userId: "user_a",
            items: [],
            totalPrice: 10.00,
            status: "pending"
        )
        
        let order2 = Order(
            id: "same_id",
            orderId: 100,
            userId: "user_a",
            items: [],
            totalPrice: 10.00,
            status: "pending"
        )
        
        XCTAssertEqual(order1, order2)
    }
    
    func testOrderInequalityDifferentId() {
        let order1 = Order(
            id: "id_001",
            orderId: 100,
            userId: "user",
            items: [],
            totalPrice: 10.00,
            status: "pending"
        )
        
        let order2 = Order(
            id: "id_002",
            orderId: 100,
            userId: "user",
            items: [],
            totalPrice: 10.00,
            status: "pending"
        )
        
        XCTAssertNotEqual(order1, order2)
    }
    
    func testOrderInequalityDifferentStatus() {
        let order1 = Order(
            id: "same_id",
            orderId: 100,
            userId: "user",
            items: [],
            totalPrice: 10.00,
            status: "pending"
        )
        
        let order2 = Order(
            id: "same_id",
            orderId: 100,
            userId: "user",
            items: [],
            totalPrice: 10.00,
            status: "completed"
        )
        
        XCTAssertNotEqual(order1, order2)
    }
    
    func testOrderHashValue() {
        let order = Order(
            id: "hash_test",
            orderId: 999,
            userId: "user",
            items: [],
            totalPrice: 50.00,
            status: "test"
        )
        
        let duplicateOrder = Order(
            id: "hash_test",
            orderId: 999,
            userId: "user",
            items: [],
            totalPrice: 50.00,
            status: "test"
        )
        
        XCTAssertEqual(order.hashValue, duplicateOrder.hashValue)
    }
    
    func testOrderInSet() {
        var orderSet = Set<Order>()
        orderSet.insert(walletPaidOrder)
        
        let duplicateOrder = Order(
            id: walletPaidOrder.id,
            orderId: walletPaidOrder.orderId,
            userId: walletPaidOrder.userId,
            items: walletPaidOrder.items,
            totalPrice: walletPaidOrder.totalPrice,
            status: walletPaidOrder.status
        )
        
        orderSet.insert(duplicateOrder)
        
        XCTAssertEqual(orderSet.count, 1)
    }
    
    // MARK: - Status Tests
    
    func testOrderStatus() {
        let pendingOrder = Order(
            id: "order_pending",
            orderId: 1,
            userId: "user",
            items: [],
            totalPrice: 5.00,
            status: "pending"
        )
        
        let completedOrder = Order(
            id: "order_completed",
            orderId: 2,
            userId: "user",
            items: [],
            totalPrice: 5.00,
            status: "completed"
        )
        
        let cancelledOrder = Order(
            id: "order_cancelled",
            orderId: 3,
            userId: "user",
            items: [],
            totalPrice: 5.00,
            status: "cancelled"
        )
        
        XCTAssertEqual(pendingOrder.status, "pending")
        XCTAssertEqual(completedOrder.status, "completed")
        XCTAssertEqual(cancelledOrder.status, "cancelled")
    }
    
    // MARK: - Codable Tests
    
    // NOTE: Standard JSONEncoder/Decoder tests are skipped because Order uses
    // Firestore's @DocumentID property wrapper, which requires Firestore.Encoder.
    // In production, Orders are encoded/decoded using Firestore's built-in methods.
    
    func testOrderFirestoreCompatibility() {
        // Verify that Order has the required Codable conformance for Firestore
        XCTAssertTrue(Order.self is Codable.Type)
    }
}

// MARK: - CartItemData Tests

final class CartItemDataTests: XCTestCase {
    
    var sampleCartItemData: CartItemData!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        sampleCartItemData = CartItemData(
            productId: "product_123",
            name: "Espresso",
            imageURL: "espresso.jpg",
            selections: ["Size": "Small", "Strength": "Strong"],
            extras: ["Sugar", "Milk"],
            price: 3.50,
            quantity: 2
        )
    }
    
    override func tearDownWithError() throws {
        sampleCartItemData = nil
        try super.tearDownWithError()
    }
    
    // MARK: - Basic Property Tests
    
    func testCartItemDataInitialization() {
        XCTAssertEqual(sampleCartItemData.productId, "product_123")
        XCTAssertEqual(sampleCartItemData.name, "Espresso")
        XCTAssertEqual(sampleCartItemData.imageURL, "espresso.jpg")
        XCTAssertEqual(sampleCartItemData.price ?? 0.0, 3.50, accuracy: 0.01)
        XCTAssertEqual(sampleCartItemData.quantity, 2)
        XCTAssertEqual(sampleCartItemData.selections?.count, 2)
        XCTAssertEqual(sampleCartItemData.extras?.count, 2)
    }
    
    func testCartItemDataId() {
        let id = sampleCartItemData.id
        XCTAssertTrue(id.contains("Espresso"))
        XCTAssertTrue(id.contains("3.5"))
    }
    
    func testCartItemDataWithNilValues() {
        let minimalItem = CartItemData(
            productId: nil,
            name: nil,
            imageURL: nil,
            selections: nil,
            extras: nil,
            price: nil,
            quantity: nil
        )
        
        XCTAssertNil(minimalItem.productId)
        XCTAssertNil(minimalItem.name)
        XCTAssertNil(minimalItem.selections)
    }
    
    // MARK: - Hashable & Equatable Tests
    
    func testCartItemDataEquality() {
        let item1 = CartItemData(
            productId: "prod_001",
            name: "Coffee",
            imageURL: "coffee.jpg",
            selections: ["Size": "Medium"],
            extras: ["Sugar"],
            price: 5.00,
            quantity: 1
        )
        
        let item2 = CartItemData(
            productId: "prod_001",
            name: "Coffee",
            imageURL: "coffee.jpg",
            selections: ["Size": "Medium"],
            extras: ["Sugar"],
            price: 5.00,
            quantity: 1
        )
        
        XCTAssertEqual(item1, item2)
    }
    
    func testCartItemDataInequality() {
        let item1 = CartItemData(
            productId: "prod_001",
            name: "Coffee",
            imageURL: "coffee.jpg",
            selections: ["Size": "Medium"],
            extras: [],
            price: 5.00,
            quantity: 1
        )
        
        let item2 = CartItemData(
            productId: "prod_001",
            name: "Coffee",
            imageURL: "coffee.jpg",
            selections: ["Size": "Large"],  // Different selection
            extras: [],
            price: 5.00,
            quantity: 1
        )
        
        XCTAssertNotEqual(item1, item2)
    }
    
    func testCartItemDataHashValue() {
        let item1 = CartItemData(
            productId: "test",
            name: "Test",
            imageURL: "test.jpg",
            selections: [:],
            extras: [],
            price: 1.00,
            quantity: 1
        )
        
        let item2 = CartItemData(
            productId: "test",
            name: "Test",
            imageURL: "test.jpg",
            selections: [:],
            extras: [],
            price: 1.00,
            quantity: 1
        )
        
        XCTAssertEqual(item1.hashValue, item2.hashValue)
    }
    
    // MARK: - Codable Tests
    
    // NOTE: CartItemData is used within Order documents in Firestore.
    // Standard JSON encoding works for CartItemData since it doesn't use @DocumentID.
    
    func testCartItemDataEncoding() throws {
        let encoder = JSONEncoder()
        let data = try encoder.encode(sampleCartItemData)
        
        XCTAssertNotNil(data)
        XCTAssertGreaterThan(data.count, 0)
    }
    
    func testCartItemDataDecoding() throws {
        let encoder = JSONEncoder()
        let data = try encoder.encode(sampleCartItemData)
        
        let decoder = JSONDecoder()
        let decodedItem = try decoder.decode(CartItemData.self, from: data)
        
        XCTAssertEqual(decodedItem.productId, sampleCartItemData.productId)
        XCTAssertEqual(decodedItem.name, sampleCartItemData.name)
        XCTAssertEqual(decodedItem.price, sampleCartItemData.price)
        XCTAssertEqual(decodedItem.quantity, sampleCartItemData.quantity)
    }
}
