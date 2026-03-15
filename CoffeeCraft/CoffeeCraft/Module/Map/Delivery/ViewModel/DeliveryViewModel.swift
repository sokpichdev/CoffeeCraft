//
//  DeliveryViewModel.swift
//  CoffeeCraft
//
//  Map Module — Phase 4 (Delivery)
//
//  Owns the active DeliverySession and drives DeliveryMapView.
//  Connects the DeliverySimulator (dev/sim) to Firestore real-time listener
//  so Phase 6 can swap the simulator for a real rider GPS feed with a
//  single flag toggle.
//

import CoreLocation
import FirebaseFirestore
import Foundation
import MapKit

// MARK: - DeliveryViewModel

@Observable
final class DeliveryViewModel {

    // MARK: - Published State (drives DeliveryMapView)

    var session: DeliverySession?

    /// Current rider position — published separately so the map annotation
    /// can update without re-rendering the whole view.
    var riderCoordinate: CLLocationCoordinate2D?

    /// Increments every simulator tick — use onChange(of: vm.tickCount)
    /// to react to position updates without needing CLLocationCoordinate2D: Equatable.
    var tickCount: Int = 0

    /// Current bearing (degrees, 0 = north) — drives RiderAnnotationView rotation.
    var riderBearing: CLLocationDirection = 0

    /// Computed ETA updated each simulator tick.
    var estimatedArrival: Date?

    /// True while the route is being fetched and the first tick has not fired.
    var isLoading = false

    /// Non-nil when something went wrong (route fetch failure, timeout, etc.).
    var errorMessage: String?

    /// True when the delivery has reached .delivered.
    var isDelivered = false

    /// True when no Firestore update has arrived for > timeoutInterval seconds.
    var isTimeout = false

    // MARK: - Route overlay — exposed for MapPolyline

    var routePolyline: MKPolyline?

    // MARK: - Private

    private let simulator    = DeliverySimulator()
    private let db           = Firestore.firestore()
    private var firestoreListener: ListenerRegistration?
    private var timeoutTask:       Task<Void, Never>?

    /// Interval (seconds) with no Firestore update before showing "lost track" UI.
    private let timeoutInterval: TimeInterval = 90

    // MARK: - Start

    /// Call this immediately after an order is placed.
    /// - Parameters:
    ///   - session:           freshly-created DeliverySession
    ///   - useSimulator:      `true` in dev; `false` in production (Phase 6)
    func startDelivery(session: DeliverySession, useSimulator: Bool = true) {
        self.session        = session
        self.riderCoordinate = session.branchCoordinate
        self.isLoading       = true
        self.isDelivered     = false
        self.isTimeout       = false
        self.errorMessage    = nil

        // Write initial document to Firestore so the listener fires immediately
        writeToFirestore(session)

        // Attach real-time listener (always — powers Phase 6 real rider)
        attachFirestoreListener(orderId: session.orderId)

        if useSimulator {
            startSimulator(session: session)
        }

        AppLog.firestore.info("[DeliveryViewModel] Delivery started — order: \(session.orderId)")
    }

    // MARK: - Stop

    func stopDelivery() {
        simulator.stop()
        firestoreListener?.remove()
        firestoreListener = nil
        timeoutTask?.cancel()
        timeoutTask  = nil
        AppLog.firestore.debug("[DeliveryViewModel] Delivery stopped")
    }

    // MARK: - Retry (after timeout)

    func retry() {
        guard let session else { return }
        isTimeout = false
        startSimulator(session: session)
        resetTimeoutWatchdog()
    }

    // MARK: - Status Advance (for preview / testing)

    /// Manually advances status by one step.
    /// In production this is driven by Firestore writes from the rider app.
    func advanceStatus() {
        guard var s = session else { return }
        let all     = DeliveryStatus.allCases
        guard let idx = all.firstIndex(of: s.status), idx + 1 < all.count else { return }
        s.status = all[idx + 1]
        session  = s
        writeToFirestore(s)
        AppLog.firestore.info("[DeliveryViewModel] Status advanced → \(s.status.rawValue)")
    }

    // MARK: - Simulator

    private func startSimulator(session: DeliverySession) {
        simulator.onUpdate = { [weak self] coord, bearing, eta in
            guard let self else { return }
            self.isLoading        = false
            self.riderCoordinate  = coord
            self.riderBearing     = bearing
            self.estimatedArrival = eta
            self.tickCount        += 1

            // Keep Firestore in sync with the simulator position
            var updated          = session
            updated.riderCoordinate = coord
            self.writeRiderPosition(orderId: session.orderId, coord: coord)
            self.resetTimeoutWatchdog()
        }

        simulator.onDelivered = { [weak self] in
            guard let self else { return }
            self.isDelivered = true
            var s = session
            s.status = .delivered
            self.session = s
            self.writeToFirestore(s)
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            AppLog.firestore.info("[DeliveryViewModel] 🎉 Delivered!")
        }

        Task {
            // Fetch the route polyline for the map overlay at the same time
            await fetchRouteOverlay(from: session.branchCoordinate,
                                    to: session.destinationCoordinate)
            await simulator.start(from: session.branchCoordinate,
                                  to: session.destinationCoordinate)
            await MainActor.run { self.isLoading = false }
        }

        resetTimeoutWatchdog()
    }

    // MARK: - Route Overlay

    private func fetchRouteOverlay(from origin: CLLocationCoordinate2D,
                                   to destination: CLLocationCoordinate2D) async {
        let request           = MKDirections.Request()
        request.source        = MKMapItem(placemark: MKPlacemark(coordinate: origin))
        request.destination   = MKMapItem(placemark: MKPlacemark(coordinate: destination))
        request.transportType = .automobile

        if let route = try? await MKDirections(request: request).calculate().routes.first {
            await MainActor.run { self.routePolyline = route.polyline }
        }
    }

    // MARK: - Firestore Listener

    private func attachFirestoreListener(orderId: String) {
        firestoreListener?.remove()
        firestoreListener = db
            .collection("deliveries")
            .document(orderId)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self else { return }

                if let error {
                    AppLog.firestore.error("[DeliveryViewModel] Listener error: \(error.localizedDescription)")
                    return
                }

                guard let data = snapshot?.data(),
                      let updated = DeliverySession(firestoreData: data) else { return }

                // In Phase 6 (real rider), Firestore is the source of truth.
                // In Phase 4 (simulator), the simulator writes to Firestore and we
                // read it back — redundant but keeps the pipeline identical.
                self.session         = updated
                self.riderCoordinate = updated.riderCoordinate

                if updated.status == .delivered {
                    self.isDelivered = true
                }

                self.resetTimeoutWatchdog()
            }
    }

    // MARK: - Firestore Writes

    private func writeToFirestore(_ session: DeliverySession) {
        db.collection("deliveries")
            .document(session.orderId)
            .setData(session.asFirestoreData(), merge: true) { error in
                if let error {
                    AppLog.firestore.error("[DeliveryViewModel] Write failed: \(error.localizedDescription)")
                }
            }
    }

    private func writeRiderPosition(orderId: String,
                                    coord: CLLocationCoordinate2D) {
        db.collection("deliveries")
            .document(orderId)
            .updateData([
                "riderLatitude":  coord.latitude,
                "riderLongitude": coord.longitude,
                "updatedAt":      Date(),
            ]) { _ in }
    }

    // MARK: - Timeout Watchdog

    private func resetTimeoutWatchdog() {
        timeoutTask?.cancel()
        timeoutTask = Task { [weak self] in
            guard let self else { return }
            try? await Task.sleep(for: .seconds(timeoutInterval))
            guard !Task.isCancelled else { return }
            await MainActor.run {
                guard self.isDelivered == false else { return }
                self.isTimeout = true
                AppLog.firestore.warning("[DeliveryViewModel] ⏱ Timeout — no update for \(Int(self.timeoutInterval))s")
            }
        }
    }
}
