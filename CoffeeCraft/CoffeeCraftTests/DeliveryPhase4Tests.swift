//
//  DeliveryPhase4Tests.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 15/03/2026.
//


//
//  DeliveryPhase4Tests.swift
//  CoffeeCraftTests
//
//  Map Module — Phase 4 (Delivery)
//
//  HOW TO ADD TO XCODE
//  ───────────────────
//  1. File ▸ New ▸ Target ▸ Unit Testing Bundle  →  name it "CoffeeCraftTests"
//  2. Drop this file into that target.
//  3. Cmd+U to run.
//
//  What is tested (12 cases across 4 suites):
//  ┌─────────────────────────────────────────────────────────────────────┐
//  │  DeliveryStatusTests      (3) — enum values, ordering, progress     │
//  │  DeliverySessionTests     (3) — model init, Firestore round-trip,   │
//  │                                 graceful failure on bad data         │
//  │  DeliverySimulatorTests   (4) — bearing maths (E, N, reverse, stop) │
//  │  DeliveryViewModelTests   (3) — state on start, advanceStatus, stop │
//  └─────────────────────────────────────────────────────────────────────┘
//
//  Design principles
//  ─────────────────
//  • Zero network calls — MKDirections and Firestore are never hit.
//  • Zero timers running — useSimulator: false skips the async route fetch;
//    straight-line logic is verified through direct method calls.
//  • MainActor isolation — @Observable ViewModel tests run on @MainActor.
//  • No mocking framework — pure XCTest + CoreLocation.
//

import CoreLocation
import XCTest
@testable import CoffeeCraft

// MARK: - Shared test fixtures

private let branchCoord = CLLocationCoordinate2D(latitude: 11.5696, longitude: 104.9307) // Riverside
private let homeCoord   = CLLocationCoordinate2D(latitude: 11.5564, longitude: 104.9282) // BKK1

private func makeSession(
    orderId: String = "2026-03-15-001",
    status:  DeliveryStatus = .orderPlaced
) -> DeliverySession {
    var s = DeliverySession(
        orderId:               orderId,
        branchId:              "branch_riverside",
        branchCoordinate:      branchCoord,
        destinationCoordinate: homeCoord
    )
    s.status = status
    return s
}

// MARK: ─────────────────────────────────────────────────────────────────────
// MARK: Suite 1 — DeliveryStatusTests
// MARK: ─────────────────────────────────────────────────────────────────────

final class DeliveryStatusTests: XCTestCase {

    // TC-1  All 6 states exist and rawValues are stable strings
    //       Rationale: rawValues are stored in Firestore — changing them breaks
    //       existing delivery documents in production.
    func test_allCasesCount_and_rawValues() {
        let cases = DeliveryStatus.allCases
        XCTAssertEqual(cases.count, 6, "Expected exactly 6 delivery states")

        XCTAssertEqual(DeliveryStatus.orderPlaced.rawValue,   "orderPlaced")
        XCTAssertEqual(DeliveryStatus.riderAssigned.rawValue, "riderAssigned")
        XCTAssertEqual(DeliveryStatus.pickedUp.rawValue,      "pickedUp")
        XCTAssertEqual(DeliveryStatus.enRoute.rawValue,       "enRoute")
        XCTAssertEqual(DeliveryStatus.arriving.rawValue,      "arriving")
        XCTAssertEqual(DeliveryStatus.delivered.rawValue,     "delivered")
    }

    // TC-2  progressFraction runs 0.0 → 1.0 and is strictly increasing
    //       Rationale: DeliveryStatusBar fills left-to-right using this value —
    //       a non-monotonic value would draw the bar backward.
    func test_progressFraction_isMonotonicallyIncreasing() {
        let fractions = DeliveryStatus.allCases.map(\.progressFraction)

        XCTAssertEqual(fractions.first!, 0.0, accuracy: 0.001,
                       "First status must have progressFraction 0.0")
        XCTAssertEqual(fractions.last!,  1.0, accuracy: 0.001,
                       "Last status must have progressFraction 1.0")

        for i in 1 ..< fractions.count {
            XCTAssertGreaterThan(fractions[i], fractions[i - 1],
                "progressFraction must strictly increase — failed at index \(i): " +
                "\(fractions[i - 1]) -> \(fractions[i])")
        }
    }

    // TC-3  stepIndex matches CaseIterable position; isTerminal is only true for .delivered
    //       Rationale: DeliveryStatusBar uses stepIndex to fill dots — an off-by-one
    //       would highlight the wrong dot.
    func test_stepIndex_and_isTerminal() {
        for (expectedIndex, status) in DeliveryStatus.allCases.enumerated() {
            XCTAssertEqual(status.stepIndex, expectedIndex,
                           "\(status).stepIndex should be \(expectedIndex)")
        }

        let terminalStates = DeliveryStatus.allCases.filter(\.isTerminal)
        XCTAssertEqual(terminalStates, [.delivered],
                       "Exactly one state (.delivered) should be terminal")
    }
}

// MARK: ─────────────────────────────────────────────────────────────────────
// MARK: Suite 2 — DeliverySessionTests
// MARK: ─────────────────────────────────────────────────────────────────────

final class DeliverySessionTests: XCTestCase {

    // TC-4  Convenience init places rider at branch coordinate, status = .orderPlaced
    //       Rationale: the rider pin must appear at the branch on the first frame,
    //       not at (0,0) or at the destination.
    func test_convenienceInit_riderStartsAtBranch() {
        let session = makeSession()

        XCTAssertEqual(session.riderLatitude,  branchCoord.latitude,  accuracy: 0.000001,
                       "Rider latitude must match branch on init")
        XCTAssertEqual(session.riderLongitude, branchCoord.longitude, accuracy: 0.000001,
                       "Rider longitude must match branch on init")
        XCTAssertEqual(session.status, .orderPlaced,
                       "Initial status must be .orderPlaced")
        XCTAssertNil(session.estimatedArrival,
                     "estimatedArrival must be nil until the simulator starts")
        XCTAssertEqual(session.riderName,  "Dara",            "Default riderName should be Dara")
        XCTAssertEqual(session.riderPhone, "+855 12 345 678", "Default riderPhone should be set")
    }

    // TC-5  Firestore round-trip: asFirestoreData() -> init?(firestoreData:) is lossless
    //       Rationale: every field written to Firestore must survive a read-back decode.
    //       If any field is silently dropped, the live tracking screen shows stale data.
    //       Note: estimatedArrival is stored as Date in the dict and decoded as Date here
    //       because we bypass Firestore (which would return a Timestamp in production).
    func test_firestoreRoundTrip_preservesAllFields() {
        var original              = makeSession(orderId: "2026-03-15-042")
        original.status           = .enRoute
        original.riderLatitude    = 11.5600
        original.riderLongitude   = 104.9290
        original.riderName        = "Dara"
        original.riderPhone       = "+855 12 345 678"
        original.estimatedArrival = Date(timeIntervalSinceNow: 600)

        let dict    = original.asFirestoreData()
        let decoded = DeliverySession(firestoreData: dict)

        XCTAssertNotNil(decoded, "init?(firestoreData:) must succeed for a valid dictionary")
        guard let d = decoded else { return }

        XCTAssertEqual(d.orderId,  "2026-03-15-042",   "orderId must survive round-trip")
        XCTAssertEqual(d.branchId, "branch_riverside",  "branchId must survive round-trip")
        XCTAssertEqual(d.status,   .enRoute,            "status must survive round-trip")

        XCTAssertEqual(d.branchLatitude,       branchCoord.latitude,  accuracy: 0.000001)
        XCTAssertEqual(d.branchLongitude,      branchCoord.longitude, accuracy: 0.000001)
        XCTAssertEqual(d.destinationLatitude,  homeCoord.latitude,    accuracy: 0.000001)
        XCTAssertEqual(d.destinationLongitude, homeCoord.longitude,   accuracy: 0.000001)
        XCTAssertEqual(d.riderLatitude,        11.5600,               accuracy: 0.000001)
        XCTAssertEqual(d.riderLongitude,       104.9290,              accuracy: 0.000001)

        XCTAssertEqual(d.riderName,  "Dara",            "riderName must survive round-trip")
        XCTAssertEqual(d.riderPhone, "+855 12 345 678", "riderPhone must survive round-trip")
        XCTAssertNotNil(d.estimatedArrival,             "estimatedArrival must survive round-trip")
    }

    // TC-6  init?(firestoreData:) returns nil gracefully when required fields are missing
    //       Rationale: a corrupt or partial Firestore document must never crash — the
    //       guard-let chain must reject it cleanly and return nil.
    func test_firestoreInit_failsGracefullyOnMissingFields() {
        // Missing "status" — the most likely field to be absent on a corrupt document
        let missingStatus: [String: Any] = [
            "orderId":              "2026-03-15-099",
            "branchId":             "branch_riverside",
            "branchLatitude":       11.5696,
            "branchLongitude":      104.9307,
            "destinationLatitude":  11.5564,
            "destinationLongitude": 104.9282,
            "riderLatitude":        11.5696,
            "riderLongitude":       104.9307,
            // "status" intentionally omitted
        ]
        XCTAssertNil(DeliverySession(firestoreData: missingStatus),
                     "init? must return nil when 'status' is missing")

        // Completely empty dictionary
        XCTAssertNil(DeliverySession(firestoreData: [:]),
                     "init? must return nil for an empty dictionary")

        // Invalid status rawValue
        var badStatus          = missingStatus
        badStatus["status"]    = "flyingOnADragon"
        XCTAssertNil(DeliverySession(firestoreData: badStatus),
                     "init? must return nil for an unrecognised status rawValue")
    }
}

// MARK: ─────────────────────────────────────────────────────────────────────
// MARK: Suite 3 — DeliverySimulatorTests
// MARK: ─────────────────────────────────────────────────────────────────────

final class DeliverySimulatorTests: XCTestCase {

    // TC-7  bearing() — due east returns ~90°
    //       Rationale: RiderAnnotationView rotates the pin by this value.
    //       An incorrect bearing turns the moped to face the wrong direction.
    func test_bearing_dueEast_isNinety() {
        let sim   = DeliverySimulator()
        let start = CLLocationCoordinate2D(latitude: 11.5564, longitude: 104.9000)
        let east  = CLLocationCoordinate2D(latitude: 11.5564, longitude: 105.0000)

        let result = sim.bearing(from: start, to: east)

        XCTAssertEqual(result, 90.0, accuracy: 1.0,
                       "Due-east bearing should be ~90°, got \(result)°")
    }

    // TC-8  bearing() — due north returns ~0° (or ~360°)
    //       Rationale: north is the identity rotation — verifies the formula
    //       does not produce a 90° offset or negative value.
    func test_bearing_dueNorth_isZeroOrThreeSixty() {
        let sim   = DeliverySimulator()
        let start = CLLocationCoordinate2D(latitude: 11.5000, longitude: 104.9282)
        let north = CLLocationCoordinate2D(latitude: 11.6000, longitude: 104.9282)

        let result  = sim.bearing(from: start, to: north)
        let isNorth = result < 2.0 || result > 358.0

        XCTAssertTrue(isNorth,
                      "Due-north bearing should be near 0°/360°, got \(result)°")
    }

    // TC-9  bearing() — reverse of a bearing is ~180° opposite
    //       Rationale: ensures the great-circle formula is symmetric —
    //       a broken formula would compute an asymmetric result.
    func test_bearing_reverseIsOpposite() {
        let sim = DeliverySimulator()
        let a   = CLLocationCoordinate2D(latitude: 11.5696, longitude: 104.9307)
        let b   = CLLocationCoordinate2D(latitude: 11.5564, longitude: 104.9282)

        let forward = sim.bearing(from: a, to: b)
        let reverse = sim.bearing(from: b, to: a)

        let diff       = abs(forward - reverse)
        let normalised = min(diff, 360.0 - diff)

        XCTAssertEqual(normalised, 180.0, accuracy: 3.0,
                       "Reverse bearing should be ~180° from forward. " +
                       "forward=\(forward)° reverse=\(reverse)° diff=\(normalised)°")
    }

    // TC-10  stop() resets isRunning to false
    //        Rationale: if stop() leaves isRunning=true, the next start() would
    //        immediately fire deliverIfNeeded() on the first tick.
    @MainActor
    func test_stop_resetsIsRunning() {
        let sim = DeliverySimulator()
        sim.stop()
        XCTAssertFalse(sim.isRunning, "isRunning must be false after stop()")
    }
}

// MARK: ─────────────────────────────────────────────────────────────────────
// MARK: Suite 4 — DeliveryViewModelTests
// MARK: ─────────────────────────────────────────────────────────────────────

final class DeliveryViewModelTests: XCTestCase {

    // TC-11  startDelivery sets all initial state synchronously before any tick fires
    //        Rationale: DeliveryMapView reads these values on first render — they
    //        must be correct before the async route fetch completes.
    @MainActor
    func test_startDelivery_setsInitialStateSynchronously() {
        let vm      = DeliveryViewModel()
        let session = makeSession(orderId: "2026-03-15-001")

        vm.startDelivery(session: session, useSimulator: false)

        XCTAssertNotNil(vm.session,                     "session must be set after startDelivery")
        XCTAssertEqual(vm.session?.orderId, "2026-03-15-001")
        XCTAssertTrue(vm.isLoading,                     "isLoading must be true before first tick")
        XCTAssertFalse(vm.isDelivered,                  "isDelivered must start false")
        XCTAssertFalse(vm.isTimeout,                    "isTimeout must start false")
        XCTAssertNil(vm.errorMessage,                   "errorMessage must start nil")
        XCTAssertEqual(vm.tickCount, 0,                 "tickCount must be 0 before any tick")

        // Rider pinned at the branch on the very first frame
        
        if let riderCoordinate = vm.riderCoordinate {
            XCTAssertEqual(riderCoordinate.latitude,  branchCoord.latitude,  accuracy: 0.000001,
                           "riderCoordinate.latitude must equal branch on start")
            XCTAssertEqual(riderCoordinate.longitude, branchCoord.longitude, accuracy: 0.000001,
                           "riderCoordinate.longitude must equal branch on start")
        }

        vm.stopDelivery()
    }

    // TC-12  advanceStatus walks every state in order then is a no-op at .delivered
    //        Rationale: the status bar progress is driven by session.status — if
    //        advanceStatus skips a step or wraps past .delivered, a dot lights wrong.
    @MainActor
    func test_advanceStatus_cyclesAllStatesInOrderThenStops() {
        let vm        = DeliveryViewModel()
        let allStates = DeliveryStatus.allCases
        vm.startDelivery(session: makeSession(), useSimulator: false)

        // Walk from .orderPlaced (index 0) through to .delivered (index 5)
        for step in 1 ..< allStates.count {
            vm.advanceStatus()
            XCTAssertEqual(vm.session?.status, allStates[step],
                           "After \(step) advance(s) status must be \(allStates[step])")
        }

        // One extra call past .delivered must be a no-op
        vm.advanceStatus()
        XCTAssertEqual(vm.session?.status, .delivered,
                       "advanceStatus() past .delivered must leave status unchanged")

        vm.stopDelivery()
    }

    // TC-13  stopDelivery does not leave isDelivered or isTimeout true
    //        Rationale: if the user dismisses DeliveryMapView mid-delivery and
    //        re-enters from Order History, the ViewModel must not immediately
    //        show the "Delivered!" overlay for an in-progress order.
    @MainActor
    func test_stopDelivery_doesNotLeaveStaleFlags() {
        let vm = DeliveryViewModel()
        vm.startDelivery(session: makeSession(), useSimulator: false)

        vm.stopDelivery()

        XCTAssertFalse(vm.isDelivered, "isDelivered must be false after stop")
        XCTAssertFalse(vm.isTimeout,   "isTimeout must be false after stop")
        XCTAssertNil(vm.errorMessage,  "errorMessage must be nil after stop")
    }
}
