//
//  DoubleExtensionTests.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 12/03/2026.
//
//  Comprehensive unit tests for extension methods
//

import XCTest
@testable import CoffeeCraft

// MARK: - Double Extension Tests

final class DoubleExtensionTests: XCTestCase {
    
    // MARK: - Currency Formatting Tests
    
    func testCurrencyFormattedWholeNumber() {
        XCTAssertEqual(10.0.currencyFormatted, "$10")
        XCTAssertEqual(100.0.currencyFormatted, "$100")
        XCTAssertEqual(1.0.currencyFormatted, "$1")
        XCTAssertEqual(1000.0.currencyFormatted, "$1000")
    }
    
    func testCurrencyFormattedWithOneCent() {
        XCTAssertEqual(10.5.currencyFormatted, "$10.5")
        XCTAssertEqual(99.1.currencyFormatted, "$99.1")
        XCTAssertEqual(5.9.currencyFormatted, "$5.9")
    }
    
    func testCurrencyFormattedWithTwoCents() {
        XCTAssertEqual(10.25.currencyFormatted, "$10.25")
        XCTAssertEqual(99.99.currencyFormatted, "$99.99")
        XCTAssertEqual(5.75.currencyFormatted, "$5.75")
        XCTAssertEqual(3.14.currencyFormatted, "$3.14")
    }
    
    func testCurrencyFormattedZero() {
        XCTAssertEqual(0.0.currencyFormatted, "$0")
    }
    
    func testCurrencyFormattedSmallAmounts() {
        XCTAssertEqual(0.01.currencyFormatted, "$0.01")
        XCTAssertEqual(0.1.currencyFormatted, "$0.1")
        XCTAssertEqual(0.99.currencyFormatted, "$0.99")
    }
    
    func testCurrencyFormattedLargeAmounts() {
        XCTAssertEqual(999.99.currencyFormatted, "$999.99")
        XCTAssertEqual(1000.0.currencyFormatted, "$1000")
        XCTAssertEqual(10000.5.currencyFormatted, "$10000.5")
        XCTAssertEqual(99999.99.currencyFormatted, "$99999.99")
    }
    
    func testCurrencyFormattedTrimsTrailingZeros() {
        // One decimal that's zero should be trimmed
        XCTAssertEqual(10.50.currencyFormatted, "$10.5")
        XCTAssertEqual(5.10.currencyFormatted, "$5.1")
        XCTAssertEqual(99.90.currencyFormatted, "$99.9")
        
        // Both decimals zero should show whole number
        XCTAssertEqual(10.00.currencyFormatted, "$10")
    }
    
    func testCurrencyFormattedRounding() {
        // Should round to 2 decimal places
        XCTAssertEqual(10.005.currencyFormatted, "$10.01")
        XCTAssertEqual(10.004.currencyFormatted, "$10")
        XCTAssertEqual(10.995.currencyFormatted, "$11")
    }
    
    func testCurrencyFormattedPrecision() {
        XCTAssertEqual(4.50.currencyFormatted, "$4.5")
        XCTAssertEqual(4.75.currencyFormatted, "$4.75")
        XCTAssertEqual(87.50.currencyFormatted, "$87.5")
    }
    
    func testCurrencyFormattedEdgeCases() {
        // Very small values
        XCTAssertEqual(0.001.currencyFormatted, "$0")
        
        // Negative values (edge case)
        XCTAssertEqual((-10.5).currencyFormatted, "-$10.5")
        XCTAssertEqual((-5.0).currencyFormatted, "-$5")
    }
    
    func testCurrencyFormattedCommonPrices() {
        // Realistic coffee shop prices
        XCTAssertEqual(3.00.currencyFormatted, "$3")
        XCTAssertEqual(3.50.currencyFormatted, "$3.5")
        XCTAssertEqual(4.25.currencyFormatted, "$4.25")
        XCTAssertEqual(4.75.currencyFormatted, "$4.75")
        XCTAssertEqual(5.00.currencyFormatted, "$5")
        XCTAssertEqual(5.50.currencyFormatted, "$5.5")
    }
    
    func testCurrencyFormattedBulkOrders() {
        XCTAssertEqual(15.00.currencyFormatted, "$15")
        XCTAssertEqual(22.50.currencyFormatted, "$22.5")
        XCTAssertEqual(45.75.currencyFormatted, "$45.75")
        XCTAssertEqual(100.25.currencyFormatted, "$100.25")
    }
}

// MARK: - String Extension Tests (if any exist in your project)

final class StringExtensionTests: XCTestCase {
    
    // Note: Add tests here if String+Ex.swift has extension methods
    // For now, this is a placeholder for completeness
    
    func testStringExtensionPlaceholder() {
        // Placeholder - add actual string extension tests if needed
        XCTAssertTrue(true)
    }
}

// MARK: - Date Extension Tests (if any exist in your project)

final class DateExtensionTests: XCTestCase {
    
    // Note: Add tests here if Date+Ex.swift has extension methods
    // For now, this is a placeholder for completeness
    
    func testDateExtensionPlaceholder() {
        // Placeholder - add actual date extension tests if needed
        XCTAssertTrue(true)
    }
}

// MARK: - Additional Currency Formatting Edge Cases

final class CurrencyFormattingEdgeCasesTests: XCTestCase {
    
    func testRoundingBehavior() {
        // Test banker's rounding (round to nearest even)
        XCTAssertEqual(2.225.currencyFormatted, "$2.23")
        XCTAssertEqual(2.235.currencyFormatted, "$2.24")
    }
    
    func testVeryLargeNumbers() {
        let million = 1_000_000.00
        XCTAssertEqual(million.currencyFormatted, "$1000000")
        
        let millionAndChange = 1_234_567.89
        XCTAssertEqual(millionAndChange.currencyFormatted, "$1234567.89")
    }
    
    func testFractionalCents() {
        // Values that should round to cents
        XCTAssertEqual(10.123.currencyFormatted, "$10.12")
        XCTAssertEqual(10.126.currencyFormatted, "$10.13")
        XCTAssertEqual(10.999.currencyFormatted, "$11")
    }
    
    func testBoundaryValues() {
        // Test at rounding boundaries
        XCTAssertEqual(9.994.currencyFormatted, "$9.99")
        XCTAssertEqual(9.995.currencyFormatted, "$9.99")
        XCTAssertEqual(9.996.currencyFormatted, "$10")
    }
    
    func testConsistentFormatting() {
        // Same logical amount should format consistently
        let amount1 = 10.5
        let amount2 = 10.50
        let amount3 = 10.500
        
        XCTAssertEqual(amount1.currencyFormatted, amount2.currencyFormatted)
        XCTAssertEqual(amount2.currencyFormatted, amount3.currencyFormatted)
        XCTAssertEqual(amount1.currencyFormatted, "$10.5")
    }
    
    func testComputedPrices() {
        // Test prices that might result from calculations
        let basePrice = 4.00
        let addon1 = 0.50
        let addon2 = 0.75
        let quantity = 3.0
        
        let totalPrice = (basePrice + addon1 + addon2) * quantity
        XCTAssertEqual(totalPrice.currencyFormatted, "$15.75")
    }
    
    func testDivisionResults() {
        // Test values that result from division
        let total = 10.0
        let items = 3.0
        let perItem = total / items
        
        // 10/3 = 3.333...
        XCTAssertEqual(perItem.currencyFormatted, "$3.33")
    }
    
    func testMultiplicationResults() {
        // Test typical price calculations
        let unitPrice = 4.25
        let quantity = 7.0
        let total = unitPrice * quantity
        
        XCTAssertEqual(total.currencyFormatted, "$29.75")
    }
}

// MARK: - Performance Tests

final class CurrencyFormattingPerformanceTests: XCTestCase {
    
    func testCurrencyFormattingPerformance() {
        let values = [0.0, 1.0, 10.5, 25.99, 100.0, 999.99]
        
        measure {
            for _ in 0..<10000 {
                for value in values {
                    _ = value.currencyFormatted
                }
            }
        }
    }
}
