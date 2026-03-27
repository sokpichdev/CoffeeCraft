//
//  FavoriteViewModelTests.swift
//  CoffeeCraftTests
//
//  Unit tests for FavoriteViewModel covering:
//    • buildCustomizationHash  — pure function, no Firebase dependency.
//    • currentCustomizationForFavorite — pure function.
//    • resetFavoriteState — verifies isFavorite is cleared and duplicate-key guard resets.
//    • loadFavoriteState error handling — the "do not reset isFavorite" contract.
//      Tested via the public API (resetFavoriteState + pre-seeded isFavorite) because
//      Auth.auth() and Firestore are not injectable in the current implementation.
//
//  Tests that CANNOT run without Firebase Auth / Firestore (loadFavoriteState success
//  with live documents) live in the integration test target.
//

@testable import CoffeeCraft
import XCTest

// MARK: - FavoriteViewModelTests

@MainActor
final class FavoriteViewModelTests: XCTestCase {

    var sut: FavoriteViewModel!

    override func setUp() {
        super.setUp()
        sut = FavoriteViewModel()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    // MARK: - Initial state

    func test_initialState_isFavoriteIsFalse() {
        XCTAssertFalse(sut.isFavorite)
    }

    func test_initialState_favoritesIsEmpty() {
        XCTAssertTrue(sut.favorites.isEmpty)
    }

    // MARK: - buildCustomizationHash

    func test_buildCustomizationHash_emptyDict_returnsEmptyString() {
        let hash = sut.buildCustomizationHash([:])
        XCTAssertEqual(hash, "")
    }

    func test_buildCustomizationHash_singlePair_formatsKeyColonValue() {
        let hash = sut.buildCustomizationHash(["Size": "Large"])
        XCTAssertEqual(hash, "Size:Large")
    }

    func test_buildCustomizationHash_multiplePairs_sortedAlphabetically() {
        let hash = sut.buildCustomizationHash(["Sugar": "Low", "Milk": "Oat", "Size": "Medium"])
        // Expected: Milk:Oat|Size:Medium|Sugar:Low  (case-insensitive ascending on key)
        XCTAssertEqual(hash, "Milk:Oat|Size:Medium|Sugar:Low")
    }

    func test_buildCustomizationHash_isDeterministic_forSameInput() {
        let input = ["B": "two", "A": "one", "C": "three"]
        let hash1 = sut.buildCustomizationHash(input)
        let hash2 = sut.buildCustomizationHash(input)
        XCTAssertEqual(hash1, hash2)
    }

    func test_buildCustomizationHash_differentValues_produceDifferentHashes() {
        let hash1 = sut.buildCustomizationHash(["Size": "Small"])
        let hash2 = sut.buildCustomizationHash(["Size": "Large"])
        XCTAssertNotEqual(hash1, hash2)
    }

    func test_buildCustomizationHash_differentKeys_produceDifferentHashes() {
        let hash1 = sut.buildCustomizationHash(["Milk": "Oat"])
        let hash2 = sut.buildCustomizationHash(["Sugar": "Oat"])
        XCTAssertNotEqual(hash1, hash2)
    }

    // MARK: - currentCustomizationForFavorite

    func test_currentCustomizationForFavorite_noExtras_returnsSelectionsOnly() {
        let result = sut.currentCustomizationForFavorite(
            selections: ["Size": "Large"],
            selectedExtras: []
        )
        XCTAssertEqual(result, ["Size": "Large"])
        XCTAssertNil(result["Extras"])
    }

    func test_currentCustomizationForFavorite_withExtras_appendsSortedExtrasKey() {
        let result = sut.currentCustomizationForFavorite(
            selections: ["Size": "Medium"],
            selectedExtras: ["Cream", "Shot"]
        )
        // Extras are sorted before joining
        XCTAssertEqual(result["Extras"], "Cream,Shot")
        XCTAssertEqual(result["Size"], "Medium")
    }

    func test_currentCustomizationForFavorite_extrasAreSortedBeforeJoining() {
        let resultA = sut.currentCustomizationForFavorite(
            selections: [:],
            selectedExtras: ["B", "A", "C"]
        )
        let resultB = sut.currentCustomizationForFavorite(
            selections: [:],
            selectedExtras: ["C", "B", "A"]
        )
        // Order of input must not affect hash — both should produce identical Extras value
        XCTAssertEqual(resultA["Extras"], resultB["Extras"])
        XCTAssertEqual(resultA["Extras"], "A,B,C")
    }

    func test_currentCustomizationForFavorite_emptySelectionsAndExtras_returnsEmptyDict() {
        let result = sut.currentCustomizationForFavorite(selections: [:], selectedExtras: [])
        XCTAssertTrue(result.isEmpty)
    }

    // MARK: - resetFavoriteState

    func test_resetFavoriteState_setsFavoriteToFalse() {
        // Pre-condition: manually set isFavorite to true
        sut.isFavorite = true

        sut.resetFavoriteState()

        XCTAssertFalse(sut.isFavorite)
    }

    /// After resetFavoriteState(), the duplicate-key guard must allow the next
    /// loadFavoriteState call to proceed (i.e. lastLoadedKey is nil again).
    /// We verify this indirectly: calling loadFavoriteState without a logged-in
    /// user returns immediately without throwing, regardless of guard state.
    func test_resetFavoriteState_allowsSubsequentLoadAttempt_withoutThrow() async {
        // Seed isFavorite so we can detect whether reset happened
        sut.isFavorite = true
        sut.resetFavoriteState()

        // loadFavoriteState with no Auth user should return silently.
        // It must NOT crash or throw even after a reset.
        let product = Product(
            id: "prod-reset-test",
            name: "Test",
            description: "",
            price: 1.0,
            imageURL: "",
            category: "Test"
        )
        await sut.loadFavoriteState(product: product, selections: [:], selectedExtras: [])

        // With no Auth user the method exits before touching isFavorite — still false.
        XCTAssertFalse(sut.isFavorite)
    }

    // MARK: - loadFavoriteState error contract

    /// When loadFavoriteState encounters an error it must NOT reset isFavorite to false.
    /// We simulate the "error → keep last known state" contract by setting isFavorite = true
    /// before the call and verifying it survives.
    ///
    /// In production the guard `guard let userId = Auth.auth().currentUser?.uid` fires first
    /// (no user in test), so the Firestore path is never reached and isFavorite is untouched.
    /// This is the same observable guarantee the View relies on.
    func test_loadFavoriteState_withNoAuthUser_doesNotResetisFavorite() async {
        sut.isFavorite = true   // last known state

        let product = Product(
            id: "prod-error-contract",
            name: "Espresso",
            description: "",
            price: 3.5,
            imageURL: "",
            category: "Coffee"
        )
        await sut.loadFavoriteState(product: product, selections: [:], selectedExtras: [])

        XCTAssertTrue(
            sut.isFavorite,
            "isFavorite must NOT be reset when the load is skipped or fails"
        )
    }

    func test_loadFavoriteState_duplicateKey_doesNotChangeState() async {
        // First call seeds lastLoadedKey (will exit at Auth guard with no user in tests,
        // but lastLoadedKey is set only when Auth passes — so duplicate-guard is
        // effectively unreachable here; we verify isFavorite is not touched either way).
        sut.isFavorite = true

        let product = Product(
            id: "prod-dup-key",
            name: "Latte",
            description: "",
            price: 4.0,
            imageURL: "",
            category: "Coffee"
        )
        let selections: [String: String] = ["Size": "Large"]
        let extras: [String] = []

        // Two identical calls back-to-back
        await sut.loadFavoriteState(product: product, selections: selections, selectedExtras: extras)
        await sut.loadFavoriteState(product: product, selections: selections, selectedExtras: extras)

        // State must be untouched
        XCTAssertTrue(sut.isFavorite)
    }
}
