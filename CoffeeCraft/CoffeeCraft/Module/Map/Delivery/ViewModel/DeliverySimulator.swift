//
//  DeliverySimulator.swift
//  CoffeeCraft
//
//  Map Module — Phase 4 (Delivery)
//
//  Responsibilities
//  ──────────────────────────────────────────────────────────────────────────
//  1. Fetch a real driving route (branch → destination) via MKDirections.
//  2. Sample the polyline into coordinate steps every ~stepDistanceMeters.
//  3. Fire a Timer every tickInterval seconds.
//  4. Advance riderCoordinate by one step per tick.
//  5. Compute bearing so the rider pin rotates to face direction of travel.
//  6. Publish (coordinate, bearing) to DeliveryViewModel via onUpdate.
//  7. Estimate arrival time from remaining steps × tickInterval.
//
//  Usage
//  ──────────────────────────────────────────────────────────────────────────
//  let sim = DeliverySimulator()
//  sim.onUpdate = { coord, bearing, eta in ... }
//  await sim.start(from: branchCoord, to: destinationCoord)
//  // later:
//  sim.stop()
//

import CoreLocation
import Foundation
import MapKit

// MARK: - DeliverySimulator

final class DeliverySimulator {

    // MARK: - Configuration

    /// Seconds between position ticks. Lower = smoother but more Firestore writes.
    var tickInterval: TimeInterval = 2.0

    /// Approximate distance (metres) between sampled polyline steps.
    /// At 2 s per tick: 25 m/tick ≈ 12.5 m/s ≈ 45 km/h — realistic urban speed.
    var stepDistanceMeters: Double = 25.0

    // MARK: - Callbacks

    /// Called on the main thread each tick.
    /// - coordinate: new rider position
    /// - bearing:    direction of travel in degrees (0 = north, 90 = east)
    /// - eta:        estimated arrival date based on remaining steps
    var onUpdate: ((CLLocationCoordinate2D, CLLocationDirection, Date?) -> Void)?

    /// Called on the main thread when the last step is reached.
    var onDelivered: (() -> Void)?

    // MARK: - Private State

    private var routeSteps: [CLLocationCoordinate2D] = []
    private var currentStepIndex = 0
    private var timer: Timer?
    private(set) var isRunning = false

    // MARK: - Public API

    /// Fetches a real driving route then starts the tick timer.
    /// Safe to call from any context — route fetch is async, timer is started on MainActor.
    func start(from origin: CLLocationCoordinate2D,
               to destination: CLLocationCoordinate2D) async {
        stop() // cancel any previous run

        do {
            let route = try await fetchRoute(from: origin, to: destination)
            let steps = sampledCoordinates(from: route, stepDistance: stepDistanceMeters)

            await MainActor.run {
                guard !steps.isEmpty else {
                    AppLog.firestore.warning("[DeliverySimulator] Route produced 0 steps — aborting")
                    return
                }
                self.routeSteps      = steps
                self.currentStepIndex = 0
                self.isRunning        = true
                self.startTimer()
                AppLog.firestore.info("[DeliverySimulator] ▶ Started — \(steps.count) steps, \(self.tickInterval)s tick")
            }
        } catch {
            AppLog.firestore.error("[DeliverySimulator] Route fetch failed: \(error.localizedDescription)")
            // Fallback: straight-line interpolation so the UI is never stuck
            let fallback = straightLineSteps(from: origin, to: destination)
            await MainActor.run {
                self.routeSteps       = fallback
                self.currentStepIndex = 0
                self.isRunning        = true
                self.startTimer()
                AppLog.firestore.warning("[DeliverySimulator] ⚠ Using fallback straight-line route (\(fallback.count) steps)")
            }
        }
    }

    /// Stops the timer and resets all state.
    func stop() {
        timer?.invalidate()
        timer           = nil
        isRunning       = false
        routeSteps      = []
        currentStepIndex = 0
        AppLog.firestore.debug("[DeliverySimulator] ■ Stopped")
    }

    // MARK: - Timer

    @MainActor
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: tickInterval, repeats: true) { [weak self] _ in
            self?.tick()
        }
    }

    @MainActor
    private func tick() {
        guard isRunning, currentStepIndex < routeSteps.count else {
            deliverIfNeeded()
            return
        }

        let coord   = routeSteps[currentStepIndex]
        let bearing = currentBearing()
        let eta     = estimatedArrival()

        onUpdate?(coord, bearing, eta)

        currentStepIndex += 1

        if currentStepIndex >= routeSteps.count {
            deliverIfNeeded()
        }
    }

    @MainActor
    private func deliverIfNeeded() {
        guard isRunning else { return }
        stop()
        onDelivered?()
        AppLog.firestore.info("[DeliverySimulator] ✅ Delivered — simulation complete")
    }

    // MARK: - Route Fetch

    private func fetchRoute(from origin: CLLocationCoordinate2D,
                            to destination: CLLocationCoordinate2D) async throws -> MKRoute {
        let request           = MKDirections.Request()
        request.source        = MKMapItem(placemark: MKPlacemark(coordinate: origin))
        request.destination   = MKMapItem(placemark: MKPlacemark(coordinate: destination))
        request.transportType = .automobile

        let result = try await MKDirections(request: request).calculate()

        guard let route = result.routes.first else {
            throw SimulatorError.noRouteFound
        }
        return route
    }

    // MARK: - Polyline Sampling

    /// Walks the MKPolyline and inserts an interpolated coordinate every
    /// `stepDistance` metres, producing a dense, uniform step array.
    private func sampledCoordinates(from route: MKRoute, stepDistance: Double) -> [CLLocationCoordinate2D] {
        let polyline = route.polyline
        let count    = polyline.pointCount
        var coords   = [CLLocationCoordinate2D](repeating: CLLocationCoordinate2D(), count: count)
        polyline.getCoordinates(&coords, range: NSRange(location: 0, length: count))

        guard coords.count >= 2 else { return coords }

        var result:    [CLLocationCoordinate2D] = [coords[0]]
        var carryOver: Double = 0

        for i in 1 ..< coords.count {
            let prev = coords[i - 1]
            let next = coords[i]
            let segmentMeters = CLLocation(latitude: prev.latitude, longitude: prev.longitude)
                .distance(from: CLLocation(latitude: next.latitude, longitude: next.longitude))

            var walked = carryOver
            while walked < segmentMeters {
                let fraction = walked / segmentMeters
                let lat = prev.latitude  + (next.latitude  - prev.latitude)  * fraction
                let lng = prev.longitude + (next.longitude - prev.longitude) * fraction
                result.append(CLLocationCoordinate2D(latitude: lat, longitude: lng))
                walked += stepDistance
            }
            carryOver = walked - segmentMeters
        }

        result.append(coords[coords.count - 1])
        return result
    }

    // MARK: - Fallback: Straight-line steps

    private func straightLineSteps(from origin: CLLocationCoordinate2D,
                                   to destination: CLLocationCoordinate2D) -> [CLLocationCoordinate2D] {
        let totalDistance = CLLocation(latitude: origin.latitude, longitude: origin.longitude)
            .distance(from: CLLocation(latitude: destination.latitude, longitude: destination.longitude))
        let stepCount = max(Int(totalDistance / stepDistanceMeters), 20)

        return (0 ... stepCount).map { i in
            let t = Double(i) / Double(stepCount)
            return CLLocationCoordinate2D(
                latitude:  origin.latitude  + (destination.latitude  - origin.latitude)  * t,
                longitude: origin.longitude + (destination.longitude - origin.longitude) * t
            )
        }
    }

    // MARK: - Bearing

    /// Returns the compass bearing from the current step to the next step.
    private func currentBearing() -> CLLocationDirection {
        guard currentStepIndex < routeSteps.count else { return 0 }
        let nextIndex = min(currentStepIndex + 1, routeSteps.count - 1)
        return bearing(from: routeSteps[currentStepIndex], to: routeSteps[nextIndex])
    }

    /// Great-circle bearing from `from` to `to` in degrees (0–360, clockwise from north).
    func bearing(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D) -> CLLocationDirection {
        let lat1 = from.latitude  * .pi / 180
        let lat2 = to.latitude    * .pi / 180
        let dLon = (to.longitude - from.longitude) * .pi / 180

        let y = sin(dLon) * cos(lat2)
        let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon)

        let bearingRad = atan2(y, x)
        return (bearingRad * 180 / .pi + 360).truncatingRemainder(dividingBy: 360)
    }

    // MARK: - ETA

    private func estimatedArrival() -> Date? {
        let remainingSteps = routeSteps.count - currentStepIndex
        guard remainingSteps > 0 else { return Date() }
        let seconds = Double(remainingSteps) * tickInterval
        return Date().addingTimeInterval(seconds)
    }
}

// MARK: - SimulatorError

enum SimulatorError: LocalizedError {
    case noRouteFound

    var errorDescription: String? {
        switch self {
        case .noRouteFound: return "MKDirections returned no routes."
        }
    }
}
