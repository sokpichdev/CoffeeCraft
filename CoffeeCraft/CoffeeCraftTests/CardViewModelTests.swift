//
//  CardViewModelTests.swift
//  CoffeeCraftTests
//
//  Unit tests for CardViewModel covering:
//    • isLoading is false after setActiveCard throws (guard / access-denied path).
//    • isLoading initial state.
//    • activeCard computed property logic (pure, no Firebase).
//    • accessibleCards computed property logic (pure, no Firebase).
//    • LoyaltyCard access helpers that power the guard in setActiveCard.
//
//  The success path of setActiveCard() calls db.updateData() and therefore
//  requires a live Firestore emulator — that belongs in integration tests.
//  Here we only test the early-return / error path where `defer { isLoading = false }`
//  still fires, and verify isLoading is false after the throw.
//

@testable import CoffeeCraft
import XCTest

// MARK: - LoyaltyCard test factory

private extension LoyaltyCard {
    static func make(
        cardNumber: String = "1234567890123456",
        ownerId: String = "owner-uid",
        ownerName: String = "Test Owner",
        sharedWith: [String] = [],
        points: Int = 0
    ) -> LoyaltyCard {
        LoyaltyCard(
            cardNumber: cardNumber,
            ownerId: ownerId,
            ownerName: ownerName,
            memberSince: "01/25",
            points: points,
            createdAt: Date(),
            sharedWith: sharedWith
        )
    }
}

// MARK: - CardViewModelTests

@MainActor
final class CardViewModelTests: XCTestCase {

    var sut: CardViewModel!

    override func setUp() {
        super.setUp()
        sut = CardViewModel()
        // Reset LoyaltyCard static state between tests
        LoyaltyCard.currentUserId = ""
        LoyaltyCard.currentActiveCardNumber = ""
    }

    override func tearDown() {
        sut = nil
        LoyaltyCard.currentUserId = ""
        LoyaltyCard.currentActiveCardNumber = ""
        super.tearDown()
    }

    // MARK: - Initial state

    func test_isLoading_isInitiallyFalse() {
        XCTAssertFalse(sut.isLoading)
    }

    func test_isRefreshing_isInitiallyFalse() {
        XCTAssertFalse(sut.isRefreshing)
    }

    func test_cards_isInitiallyEmpty() {
        XCTAssertTrue(sut.cards.isEmpty)
    }

    // MARK: - setActiveCard — access-denied path (no Firestore call)

    /// When the card does not grant access to the current user, setActiveCard throws
    /// CardError.noAccess immediately (before any Firestore write). The defer must
    /// still fire, leaving isLoading = false.
    func test_setActiveCard_accessDenied_isLoadingIsFalseAfterThrow() async {
        // No currentUserId set → hasAccessForCurrentUser returns false
        LoyaltyCard.currentUserId = ""
        let card = LoyaltyCard.make(ownerId: "some-other-uid")

        do {
            try await sut.setActiveCard(card)
            XCTFail("Expected setActiveCard to throw CardError.noAccess")
        } catch {
            // Expected throw
        }

        XCTAssertFalse(
            sut.isLoading,
            "isLoading must be false after setActiveCard throws (defer must fire)"
        )
    }

    /// Same check: userId set to a non-owner, non-shared user — access denied.
    func test_setActiveCard_nonOwnerNonShared_isLoadingIsFalseAfterThrow() async {
        LoyaltyCard.currentUserId = "stranger-uid"
        let card = LoyaltyCard.make(ownerId: "owner-uid", sharedWith: [])

        do {
            try await sut.setActiveCard(card)
            XCTFail("Expected setActiveCard to throw")
        } catch { }

        XCTAssertFalse(sut.isLoading)
    }

    /// Even when no currentUserId is set in CardViewModel (user never called setUser),
    /// the setActiveCard guard fires and throws, keeping isLoading = false.
    func test_setActiveCard_noCurrentUserId_isLoadingIsFalseAfterThrow() async {
        // sut.currentUserId is nil (private, not set via setUser)
        LoyaltyCard.currentUserId = "owner-uid"
        let card = LoyaltyCard.make(ownerId: "owner-uid")
        // card.hasAccessForCurrentUser is true (owner matches), but
        // sut.currentUserId (the private ivar) is nil → guard in setActiveCard fires.

        do {
            try await sut.setActiveCard(card)
            XCTFail("Expected setActiveCard to throw CardError.noAccess (no currentUserId)")
        } catch { }

        XCTAssertFalse(sut.isLoading)
    }

    // MARK: - activeCard computed property

    func test_activeCard_noCards_returnsNil() {
        LoyaltyCard.currentUserId = "uid"
        LoyaltyCard.currentActiveCardNumber = "9999"
        sut.activeCardNumber = "9999"
        sut.cards = []

        XCTAssertNil(sut.activeCard)
    }

    func test_activeCard_matchingCardNumber_andAccessGranted_returnsCard() {
        LoyaltyCard.currentUserId = "owner-uid"
        let card = LoyaltyCard.make(cardNumber: "1111222233334444", ownerId: "owner-uid")
        sut.cards = [card]
        sut.activeCardNumber = "1111222233334444"

        XCTAssertNotNil(sut.activeCard)
        XCTAssertEqual(sut.activeCard?.cardNumber, "1111222233334444")
    }

    func test_activeCard_wrongCardNumber_returnsNil() {
        LoyaltyCard.currentUserId = "owner-uid"
        let card = LoyaltyCard.make(cardNumber: "1111222233334444", ownerId: "owner-uid")
        sut.cards = [card]
        sut.activeCardNumber = "9999000011112222"   // different from card in deck

        XCTAssertNil(sut.activeCard)
    }

    // MARK: - accessibleCards computed property

    func test_accessibleCards_filtersOutInaccessibleCards() {
        LoyaltyCard.currentUserId = "user-a"

        let ownedCard  = LoyaltyCard.make(cardNumber: "1111", ownerId: "user-a")
        let sharedCard = LoyaltyCard.make(cardNumber: "2222", ownerId: "user-b", sharedWith: ["user-a"])
        let otherCard  = LoyaltyCard.make(cardNumber: "3333", ownerId: "user-b", sharedWith: [])

        sut.cards = [ownedCard, sharedCard, otherCard]

        let accessible = sut.accessibleCards
        XCTAssertEqual(accessible.count, 2)
        let numbers = accessible.map { $0.cardNumber }
        XCTAssertTrue(numbers.contains("1111"))
        XCTAssertTrue(numbers.contains("2222"))
        XCTAssertFalse(numbers.contains("3333"))
    }

    func test_accessibleCards_emptyDeck_returnsEmpty() {
        sut.cards = []
        XCTAssertTrue(sut.accessibleCards.isEmpty)
    }
}

// MARK: - LoyaltyCard Access Helper Tests

/// Tests for the pure computed properties on LoyaltyCard that drive the
/// setActiveCard guard in CardViewModel.
final class LoyaltyCardAccessTests: XCTestCase {

    override func setUp() {
        super.setUp()
        LoyaltyCard.currentUserId = ""
        LoyaltyCard.currentActiveCardNumber = ""
    }

    override func tearDown() {
        LoyaltyCard.currentUserId = ""
        LoyaltyCard.currentActiveCardNumber = ""
        super.tearDown()
    }

    func test_hasAccessForCurrentUser_asOwner_isTrue() {
        LoyaltyCard.currentUserId = "owner-uid"
        let card = LoyaltyCard.make(ownerId: "owner-uid")
        XCTAssertTrue(card.hasAccessForCurrentUser)
    }

    func test_hasAccessForCurrentUser_asSharedUser_isTrue() {
        LoyaltyCard.currentUserId = "shared-uid"
        let card = LoyaltyCard.make(ownerId: "owner-uid", sharedWith: ["shared-uid"])
        XCTAssertTrue(card.hasAccessForCurrentUser)
    }

    func test_hasAccessForCurrentUser_asStranger_isFalse() {
        LoyaltyCard.currentUserId = "stranger-uid"
        let card = LoyaltyCard.make(ownerId: "owner-uid", sharedWith: ["shared-uid"])
        XCTAssertFalse(card.hasAccessForCurrentUser)
    }

    func test_hasAccessForCurrentUser_emptyCurrentUser_isFalse() {
        LoyaltyCard.currentUserId = ""
        let card = LoyaltyCard.make(ownerId: "owner-uid")
        XCTAssertFalse(card.hasAccessForCurrentUser)
    }

    func test_isOwnedByCurrentUser_matchingOwner_isTrue() {
        LoyaltyCard.currentUserId = "owner-uid"
        let card = LoyaltyCard.make(ownerId: "owner-uid")
        XCTAssertTrue(card.isOwnedByCurrentUser)
    }

    func test_isOwnedByCurrentUser_differentOwner_isFalse() {
        LoyaltyCard.currentUserId = "other-uid"
        let card = LoyaltyCard.make(ownerId: "owner-uid")
        XCTAssertFalse(card.isOwnedByCurrentUser)
    }

    func test_isActiveForCurrentUser_activeCardAndAccess_isTrue() {
        LoyaltyCard.currentUserId = "owner-uid"
        LoyaltyCard.currentActiveCardNumber = "1234"
        let card = LoyaltyCard.make(cardNumber: "1234", ownerId: "owner-uid")
        XCTAssertTrue(card.isActiveForCurrentUser)
    }

    func test_isActiveForCurrentUser_differentActiveCard_isFalse() {
        LoyaltyCard.currentUserId = "owner-uid"
        LoyaltyCard.currentActiveCardNumber = "9999"
        let card = LoyaltyCard.make(cardNumber: "1234", ownerId: "owner-uid")
        XCTAssertFalse(card.isActiveForCurrentUser)
    }
}
