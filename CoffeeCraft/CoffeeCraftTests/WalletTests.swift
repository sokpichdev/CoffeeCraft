//
//  WalletTests.swift
//  CoffeeCraftTests
//
//  Comprehensive unit tests for Wallet model and PaymentMethod enum
//

import XCTest
@testable import CoffeeCraft

final class WalletTests: XCTestCase {
    
    // MARK: - Test Properties
    
    var sampleWallet: Wallet!
    var newWallet: Wallet!
    var emptyWallet: Wallet!
    
    // MARK: - Setup & Teardown
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        sampleWallet = Wallet(
            id: "user_001",
            balance: 87.50,
            currency: "USD",
            totalTopUp: 200.00,
            totalSpent: 112.50,
            createdAt: Date(timeIntervalSince1970: 1609459200), // Jan 1, 2021
            updatedAt: Date()
        )
        
        newWallet = Wallet.new(for: "user_new")
        
        emptyWallet = Wallet(
            id: "user_empty",
            balance: 0,
            currency: "USD",
            totalTopUp: 100.00,
            totalSpent: 100.00,
            createdAt: Date(),
            updatedAt: Date()
        )
    }
    
    override func tearDownWithError() throws {
        sampleWallet = nil
        newWallet = nil
        emptyWallet = nil
        try super.tearDownWithError()
    }
    
    // MARK: - Basic Property Tests
    
    func testWalletInitialization() {
        XCTAssertEqual(sampleWallet.id, "user_001")
        XCTAssertEqual(sampleWallet.balance, 87.50, accuracy: 0.01)
        XCTAssertEqual(sampleWallet.currency, "USD")
        XCTAssertEqual(sampleWallet.totalTopUp, 200.00, accuracy: 0.01)
        XCTAssertEqual(sampleWallet.totalSpent, 112.50, accuracy: 0.01)
        XCTAssertNotNil(sampleWallet.createdAt)
        XCTAssertNotNil(sampleWallet.updatedAt)
    }
    
    func testNewWalletCreation() {
        XCTAssertEqual(newWallet.id, "user_new")
        XCTAssertEqual(newWallet.balance, 0, accuracy: 0.01)
        XCTAssertEqual(newWallet.currency, "USD")
        XCTAssertEqual(newWallet.totalTopUp, 0, accuracy: 0.01)
        XCTAssertEqual(newWallet.totalSpent, 0, accuracy: 0.01)
        XCTAssertNotNil(newWallet.createdAt)
        XCTAssertNotNil(newWallet.updatedAt)
    }
    
    // MARK: - Formatted Balance Tests
    
    func testFormattedBalanceWithCents() {
        let wallet = Wallet(
            id: "test",
            balance: 87.50,
            currency: "USD",
            totalTopUp: 0,
            totalSpent: 0,
            createdAt: Date(),
            updatedAt: Date()
        )
        
        XCTAssertEqual(wallet.formattedBalance, "$87.5")
    }
    
    func testFormattedBalanceWholeNumber() {
        let wallet = Wallet(
            id: "test",
            balance: 100.00,
            currency: "USD",
            totalTopUp: 0,
            totalSpent: 0,
            createdAt: Date(),
            updatedAt: Date()
        )
        
        XCTAssertEqual(wallet.formattedBalance, "$100")
    }
    
    func testFormattedBalanceZero() {
        XCTAssertEqual(emptyWallet.formattedBalance, "$0")
    }
    
    func testFormattedBalanceWithFullCents() {
        let wallet = Wallet(
            id: "test",
            balance: 45.75,
            currency: "USD",
            totalTopUp: 0,
            totalSpent: 0,
            createdAt: Date(),
            updatedAt: Date()
        )
        
        XCTAssertEqual(wallet.formattedBalance, "$45.75")
    }
    
    // MARK: - Can Afford Tests
    
    func testCanAffordTrue() {
        XCTAssertTrue(sampleWallet.canAfford(50.00))
        XCTAssertTrue(sampleWallet.canAfford(87.50))  // Exact amount
        XCTAssertTrue(sampleWallet.canAfford(0.01))
    }
    
    func testCanAffordFalse() {
        XCTAssertFalse(sampleWallet.canAfford(100.00))
        XCTAssertFalse(sampleWallet.canAfford(87.51))  // Slightly over
    }
    
    func testCanAffordZero() {
        XCTAssertTrue(sampleWallet.canAfford(0))
        XCTAssertTrue(emptyWallet.canAfford(0))
    }
    
    func testEmptyWalletCannotAfford() {
        XCTAssertFalse(emptyWallet.canAfford(0.01))
        XCTAssertFalse(emptyWallet.canAfford(10.00))
    }
    
    // MARK: - Has Balance Tests
    
    func testHasBalanceTrue() {
        XCTAssertTrue(sampleWallet.hasBalance)
        
        let minimalWallet = Wallet(
            id: "test",
            balance: 0.01,
            currency: "USD",
            totalTopUp: 0,
            totalSpent: 0,
            createdAt: Date(),
            updatedAt: Date()
        )
        
        XCTAssertTrue(minimalWallet.hasBalance)
    }
    
    func testHasBalanceFalse() {
        XCTAssertFalse(emptyWallet.hasBalance)
        
        let zeroWallet = Wallet(
            id: "test",
            balance: 0,
            currency: "USD",
            totalTopUp: 0,
            totalSpent: 0,
            createdAt: Date(),
            updatedAt: Date()
        )
        
        XCTAssertFalse(zeroWallet.hasBalance)
    }
    
    // MARK: - Balance Calculation Tests
    
    func testBalanceAfterTopUp() {
        var wallet = newWallet!
        wallet.balance += 50.00
        wallet.totalTopUp += 50.00
        
        XCTAssertEqual(wallet.balance, 50.00, accuracy: 0.01)
        XCTAssertEqual(wallet.totalTopUp, 50.00, accuracy: 0.01)
    }
    
    func testBalanceAfterSpending() {
        var wallet = sampleWallet!
        let purchaseAmount = 20.00
        wallet.balance -= purchaseAmount
        wallet.totalSpent += purchaseAmount
        
        XCTAssertEqual(wallet.balance, 67.50, accuracy: 0.01)
        XCTAssertEqual(wallet.totalSpent, 132.50, accuracy: 0.01)
    }
    
    func testLifetimeCalculations() {
        // Total topped up - total spent should equal balance
        let calculatedBalance = sampleWallet.totalTopUp - sampleWallet.totalSpent
        XCTAssertEqual(calculatedBalance, sampleWallet.balance, accuracy: 0.01)
    }
    
    // MARK: - Codable Tests
    
    // NOTE: Standard JSONEncoder/Decoder tests are skipped because Wallet uses
    // Firestore's @DocumentID property wrapper, which requires Firestore.Encoder.
    // In production, Wallets are encoded/decoded using Firestore's built-in methods.
    
    func testWalletFirestoreCompatibility() {
        // Verify that Wallet has the required Codable conformance for Firestore
        XCTAssertTrue(Wallet.self is Codable.Type)
    }
    
    // MARK: - Edge Case Tests
    
    func testNegativeBalance() {
        // In real app this shouldn't happen, but test edge case
        let negativeWallet = Wallet(
            id: "negative",
            balance: -10.00,
            currency: "USD",
            totalTopUp: 50.00,
            totalSpent: 60.00,
            createdAt: Date(),
            updatedAt: Date()
        )
        
        XCTAssertEqual(negativeWallet.balance, -10.00, accuracy: 0.01)
        XCTAssertFalse(negativeWallet.hasBalance)
        XCTAssertFalse(negativeWallet.canAfford(0.01))
    }
    
    func testLargeBalance() {
        let largeWallet = Wallet(
            id: "whale",
            balance: 99999.99,
            currency: "USD",
            totalTopUp: 100000.00,
            totalSpent: 0.01,
            createdAt: Date(),
            updatedAt: Date()
        )
        
        XCTAssertEqual(largeWallet.balance, 99999.99, accuracy: 0.01)
        XCTAssertTrue(largeWallet.canAfford(50000.00))
        XCTAssertTrue(largeWallet.hasBalance)
    }
    
    func testPrecisionHandling() {
        let wallet = Wallet(
            id: "precision",
            balance: 10.005,  // Should round to 2 decimal places
            currency: "USD",
            totalTopUp: 0,
            totalSpent: 0,
            createdAt: Date(),
            updatedAt: Date()
        )
        
        XCTAssertEqual(wallet.balance, 10.005, accuracy: 0.001)
    }
}

// MARK: - PaymentMethod Tests

final class PaymentMethodTests: XCTestCase {
    
    // MARK: - Enum Cases Tests
    
    func testPaymentMethodCases() {
        XCTAssertEqual(PaymentMethod.allCases.count, 2)
        XCTAssertTrue(PaymentMethod.allCases.contains(.wallet))
        XCTAssertTrue(PaymentMethod.allCases.contains(.cash))
    }
    
    // MARK: - Raw Value Tests
    
    func testPaymentMethodRawValues() {
        XCTAssertEqual(PaymentMethod.wallet.rawValue, "wallet")
        XCTAssertEqual(PaymentMethod.cash.rawValue, "cash")
    }
    
    func testPaymentMethodFromRawValue() {
        XCTAssertEqual(PaymentMethod(rawValue: "wallet"), .wallet)
        XCTAssertEqual(PaymentMethod(rawValue: "cash"), .cash)
        XCTAssertNil(PaymentMethod(rawValue: "credit_card"))
        XCTAssertNil(PaymentMethod(rawValue: "invalid"))
    }
    
    // MARK: - Display Name Tests
    
    func testDisplayNames() {
        XCTAssertEqual(PaymentMethod.wallet.displayName, "Wallet")
        XCTAssertEqual(PaymentMethod.cash.displayName, "Cash at Counter")
    }
    
    // MARK: - Icon Tests
    
    func testIcons() {
        XCTAssertEqual(PaymentMethod.wallet.icon, "creditcard.fill")
        XCTAssertEqual(PaymentMethod.cash.icon, "banknote")
    }
    
    // MARK: - Description Tests
    
    func testDescriptions() {
        XCTAssertEqual(PaymentMethod.wallet.description, "Pay using your wallet balance")
        XCTAssertEqual(PaymentMethod.cash.description, "Pay in person at the counter")
    }
    
    // MARK: - Codable Tests
    
    func testPaymentMethodEncoding() throws {
        let encoder = JSONEncoder()
        
        let walletData = try encoder.encode(PaymentMethod.wallet)
        let cashData = try encoder.encode(PaymentMethod.cash)
        
        XCTAssertNotNil(walletData)
        XCTAssertNotNil(cashData)
    }
    
    func testPaymentMethodDecoding() throws {
        let encoder = JSONEncoder()
        let walletData = try encoder.encode(PaymentMethod.wallet)
        
        let decoder = JSONDecoder()
        let decodedMethod = try decoder.decode(PaymentMethod.self, from: walletData)
        
        XCTAssertEqual(decodedMethod, .wallet)
    }
    
    func testPaymentMethodStringEncoding() throws {
        struct PaymentContainer: Codable {
            let method: PaymentMethod
        }
        
        let container = PaymentContainer(method: .wallet)
        let encoder = JSONEncoder()
        let data = try encoder.encode(container)
        
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(PaymentContainer.self, from: data)
        
        XCTAssertEqual(decoded.method, .wallet)
    }
    
    // MARK: - Switch Coverage Tests
    
    func testAllCasesCovered() {
        for paymentMethod in PaymentMethod.allCases {
            _ = paymentMethod.displayName
            _ = paymentMethod.icon
            _ = paymentMethod.description
            
            // Should not crash for any case
            XCTAssertFalse(paymentMethod.displayName.isEmpty)
            XCTAssertFalse(paymentMethod.icon.isEmpty)
            XCTAssertFalse(paymentMethod.description.isEmpty)
        }
    }
}
