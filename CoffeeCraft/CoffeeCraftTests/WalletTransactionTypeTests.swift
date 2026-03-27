//
//  WalletTransactionTypeTests.swift
//  CoffeeCraftTests
//
//  Unit tests for WalletTransactionType enum raw values, display properties,
//  and the constant used by OrderDetailViewModel's cancel-order transaction.
//

@testable import CoffeeCraft
import XCTest

final class WalletTransactionTypeTests: XCTestCase {

    // MARK: - Raw Values

    /// The Firestore field value written by cancelOrder() must be exactly "refund".
    /// OrderDetailViewModel relies on WalletTransactionType.refund.rawValue for the
    /// wallet_transactions "type" field — a mismatch would silently corrupt the ledger.
    func test_refund_rawValue_isLiteralStringRefund() {
        XCTAssertEqual(WalletTransactionType.refund.rawValue, "refund")
    }

    func test_topup_rawValue_isLiteralStringTopup() {
        XCTAssertEqual(WalletTransactionType.topup.rawValue, "topup")
    }

    func test_payment_rawValue_isLiteralStringPayment() {
        XCTAssertEqual(WalletTransactionType.payment.rawValue, "payment")
    }

    func test_reward_rawValue_isLiteralStringReward() {
        XCTAssertEqual(WalletTransactionType.reward.rawValue, "reward")
    }

    // MARK: - All cases have non-empty raw values

    func test_allCases_haveNonEmptyRawValues() {
        for type in WalletTransactionType.allCases {
            XCTAssertFalse(
                type.rawValue.isEmpty,
                "Expected non-empty rawValue for case \(type)"
            )
        }
    }

    // MARK: - Round-trip decoding

    func test_allCases_canBeDecodedFromRawValue() {
        for type in WalletTransactionType.allCases {
            let decoded = WalletTransactionType(rawValue: type.rawValue)
            XCTAssertEqual(decoded, type, "Round-trip decode failed for \(type.rawValue)")
        }
    }

    func test_unknownRawValue_decodesAsNil() {
        XCTAssertNil(WalletTransactionType(rawValue: "TopUp"))   // wrong case
        XCTAssertNil(WalletTransactionType(rawValue: "REFUND"))  // wrong case
        XCTAssertNil(WalletTransactionType(rawValue: ""))
        XCTAssertNil(WalletTransactionType(rawValue: "unknown"))
    }

    // MARK: - CaseIterable count

    func test_caseIterable_hasFourCases() {
        // Verifies no case was silently added or removed without updating callers.
        XCTAssertEqual(WalletTransactionType.allCases.count, 4)
    }

    // MARK: - Display properties

    func test_allCases_haveNonEmptyDisplayNames() {
        for type in WalletTransactionType.allCases {
            XCTAssertFalse(
                type.displayName.isEmpty,
                "Expected non-empty displayName for case \(type)"
            )
        }
    }

    func test_allCases_haveNonEmptyIcons() {
        for type in WalletTransactionType.allCases {
            XCTAssertFalse(
                type.icon.isEmpty,
                "Expected non-empty icon for case \(type)"
            )
        }
    }

    // MARK: - Codable (JSON round-trip)

    func test_refund_JSONRoundTrip_preservesValue() throws {
        let encoded = try JSONEncoder().encode(WalletTransactionType.refund)
        let decoded = try JSONDecoder().decode(WalletTransactionType.self, from: encoded)
        XCTAssertEqual(decoded, .refund)
    }

    func test_topup_JSONRoundTrip_preservesValue() throws {
        let encoded = try JSONEncoder().encode(WalletTransactionType.topup)
        let decoded = try JSONDecoder().decode(WalletTransactionType.self, from: encoded)
        XCTAssertEqual(decoded, .topup)
    }
}
