//
//  DeliveryViewModel.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 15/03/2026.
//

import CoreLocation
import FirebaseFirestore
import Foundation
import MapKit

// MARK: - DeliveryViewModel

// @Observable
final class DeliveryViewModel: ObservableObject {

    // MARK: - Published State (drives DeliveryMapView)
    // All view-driving properties must be @Published — ObservableObject only
    // triggers a re-render when a @Published property changes.

    @Published var session: DeliverySession?

    /// Current rider position.
    @Published var riderCoordinate: CLLocationCoordinate2D?

    /// Increments every simulator tick — use onChange(of: vm.tickCount)
    /// to react to position updates without needing CLLocationCoordinate2D: Equatable.
    @Published var tickCount: Int = 0

    /// Current bearing (degrees, 0 = north) — drives RiderAnnotationView rotation.
    @Published var riderBearing: CLLocationDirection = 0

    /// Computed ETA updated each simulator tick.
    @Published var estimatedArrival: Date?

    /// True while the route is being fetched and the first tick has not fired.
    @Published var isLoading = false

    /// Non-nil when something went wrong (route fetch failure, timeout, etc.).
    @Published var errorMessage: String?

    /// True when the delivery has reached .delivered.
    @Published var isDelivered = false

    /// True when no Firestore update has arrived for > timeoutInterval seconds.
    @Published var isTimeout = false

    // MARK: - Route overlay — exposed for MapPolyline

    @Published var routePolyline: MKPolyline?

    // MARK: - Private

    private let simulator    = DeliverySimulator()
    private let db           = Firestore.firestore()
    private var firestoreListener: ListenerRegistration?
    private var timeoutTask: Task<Void, Never>?

    /// Set to true during resumeDelivery() so the Firestore listener's first
    /// immediate snapshot does not overwrite riderCoordinate before the simulator
    /// starts running. Cleared on the first simulator tick.
    private var isResumingFromRestore = false

    /// In-memory store of the rider's latest coordinate.
    /// Updated every simulator tick locally — Firestore is only written on background.
    private var latestRiderCoord: CLLocationCoordinate2D?

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

        // Write the delivery document skeleton (no riderLatitude/riderLongitude —
        // asFirestoreData intentionally omits them to prevent clobbering).
        // Then seed the rider start position separately as the branch coordinate.
        // This is the ONLY place rider position is initialised to the branch.
        // All subsequent position writes come from writeRiderPosition() each tick.
        writeToFirestore(session)
        writeRiderPosition(orderId: session.orderId, coord: session.branchCoordinate)

        // Attach real-time listener (always — powers Phase 6 real rider)
        attachFirestoreListener(orderId: session.orderId)

        if useSimulator {
            startSimulator(session: session)
        }

        AppLog.firestore.info("[DeliveryViewModel] Delivery started — order: \(session.orderId)")
    }

    // MARK: - Resume (app relaunch while delivery is in progress)

    /// Call this when restoring an active delivery after the app was killed/backgrounded.
    ///
    /// Unlike `startDelivery`, this does NOT reset the rider marker to the branch.
    /// Instead it:
    ///   1. Sets `riderCoordinate` to the last position written to Firestore.
    ///   2. Tells the simulator to rebuild the route from that position and skip
    ///      forward by the number of steps that elapsed while the app was closed.
    func resumeDelivery(session: DeliverySession, useSimulator: Bool = true) {
        // Stop any previously running simulator (e.g. the placeholder from preSeedRestoredDelivery).
        simulator.stop()

        self.session         = session
        // ✅ Immediately show rider at last-known Firestore position, not branch origin.
        self.riderCoordinate = session.riderCoordinate
        // ✅ Do NOT show the loading spinner on restore — we already have the rider
        //    position and session from Firestore. isLoading = true is only correct
        //    for startDelivery() where we genuinely have nothing to show yet.
        //    Showing the spinner here causes "Finding your rider…" every time the
        //    user reopens the app during an active delivery.
        self.isLoading       = false
        self.isDelivered     = session.status == .delivered
        self.isTimeout       = false
        self.errorMessage    = nil

        // Set guard flag BEFORE attaching the listener. The listener fires its first
        // snapshot immediately on attach. If the simulator hasn't started yet,
        // isRunning == false and the listener would overwrite riderCoordinate with
        // stale Firestore branch coords. This flag prevents that.
        isResumingFromRestore = true

        if useSimulator && !isDelivered {
            resumeSimulator(session: session)
        }

        // Attach listener AFTER setting up the simulator so the first snapshot
        // cannot race against the riderCoordinate we just set above.
        attachFirestoreListener(orderId: session.orderId)

        AppLog.firestore.info("[DeliveryViewModel] Delivery resumed — order: \(session.orderId), lastPos: (\(session.riderLatitude), \(session.riderLongitude))")
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
        guard var ses = session else { return }
        let all     = DeliveryStatus.allCases
        guard let idx = all.firstIndex(of: ses.status), idx + 1 < all.count else { return }
        ses.status = all[idx + 1]
        session  = ses
        writeToFirestore(ses)
        AppLog.firestore.info("[DeliveryViewModel] Status advanced → \(ses.status.rawValue)")
    }

    // MARK: - Simulator

    private func startSimulator(session: DeliverySession) {
        // Track whether we've recorded the simulation start time yet.
        var hasWrittenStartTime = false

        simulator.onUpdate = { [weak self] coord, bearing, eta in
            guard let self else { return }
            self.isLoading        = false
            self.riderCoordinate  = coord
            self.riderBearing     = bearing
            self.estimatedArrival = eta
            self.tickCount        += 1

            // ✅ Store position locally — NO Firestore write per tick.
            // Position is only persisted when the app goes to background (scenePhase).
            self.latestRiderCoord = coord

            // ✅ On the very first tick, stamp simulationStartedAt once.
            if !hasWrittenStartTime {
                hasWrittenStartTime = true
                let now = Date()
                self.writeSimulationStartTime(orderId: session.orderId, startedAt: now)
                AppLog.firestore.info("[DeliveryViewModel] Stamped simulationStartedAt: \(now)")
            }

            self.resetTimeoutWatchdog()
        }

        simulator.onDelivered = { [weak self] in
            guard let self else { return }
            self.isDelivered = true
            var ses = session
            ses.status = .delivered
            self.session = ses
            self.writeToFirestore(ses)
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            AppLog.firestore.info("[DeliveryViewModel] 🎉 Delivered!")
            // Release the VM from OrderEnvironment after a short delay
            // so DeliveryMapView can still show the celebration overlay.
            let completedOrderId = session.orderId
            DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                OrderEnvironment.shared.clearDelivery(for: completedOrderId)
            }
        }

        Task {
            // Polyline drawn from branch → destination so the full route
            // is visible on screen from the moment the delivery starts.
            await fetchRouteOverlay(from: session.branchCoordinate,
                                    to: session.destinationCoordinate)
            await simulator.start(from: session.branchCoordinate,
                                  to: session.destinationCoordinate)
            await MainActor.run { self.isLoading = false }
        }

        resetTimeoutWatchdog()
    }

    /// Resumes the simulator from the rider's last Firestore position,
    /// skipping forward by the time elapsed since simulationStartedAt.
    private func resumeSimulator(session: DeliverySession) {
        simulator.onUpdate = { [weak self] coord, bearing, eta in
            guard let self else { return }
            // Clear restore guard on first tick.
            self.isResumingFromRestore = false
            self.isLoading        = false
            self.riderCoordinate  = coord
            self.riderBearing     = bearing
            self.estimatedArrival = eta
            self.tickCount        += 1

            // Store locally — Firestore only written on background/terminate.
            self.latestRiderCoord = coord

            self.resetTimeoutWatchdog()
        }

        simulator.onDelivered = { [weak self] in
            guard let self else { return }
            self.isDelivered = true
            var ses = session
            ses.status = .delivered
            self.session = ses
            self.writeToFirestore(ses)
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            AppLog.firestore.info("[DeliveryViewModel] 🎉 Delivered! (resumed)")
            let completedOrderId = session.orderId
            DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                OrderEnvironment.shared.clearDelivery(for: completedOrderId)
            }
        }

        Task {
            // ✅ Always redraw the FULL original route (branch → dest) so the
            // polyline on the map matches the route the simulator drives.
            await fetchRouteOverlay(from: session.branchCoordinate,
                                    to: session.destinationCoordinate)
            // ✅ Simulator rebuilds full route then seeks to the step closest
            // to the rider's last known position — no elapsed-time guessing.
            await simulator.resume(from: session.branchCoordinate,
                                   lastKnownCoord: session.riderCoordinate,
                                   to: session.destinationCoordinate)
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

                // Update session metadata (status, ETA, rider info) from Firestore.
                self.session = updated

                // Only update riderCoordinate from Firestore when the simulator is NOT running.
                // While the simulator runs it owns riderCoordinate — letting Firestore write it
                // causes stuttering because the read-back lags 1-2 ticks behind.
                //
                // isResumingFromRestore guards against the listener's FIRST immediate snapshot
                // (which fires before simulator.isRunning becomes true) overwriting the correct
                // last-known position we restored from Firestore in resumeDelivery().
                if !self.simulator.isRunning && !self.isResumingFromRestore {
                    self.riderCoordinate = updated.riderCoordinate
                }

                if updated.status == .delivered {
                    self.isDelivered = true
                }

                self.resetTimeoutWatchdog()
            }
    }

    // MARK: - Firestore Writes

    /// Called when the app goes to background or is about to terminate.
    /// Persists the latest in-memory rider position to Firestore in one write.
    /// This is the ONLY place riderLatitude/riderLongitude is written during
    /// a live delivery — everything else is kept in memory.
    func flushPositionToFirestore() {
        guard let session,
              let coord = latestRiderCoord,
              !isDelivered else { return }
        writeRiderPosition(orderId: session.orderId, coord: coord)
        AppLog.firestore.info("[DeliveryViewModel] Flushed position to Firestore on background: (\(coord.latitude), \(coord.longitude))")
    }

    private func writeToFirestore(_ session: DeliverySession) {
        db.collection("deliveries")
            .document(session.orderId)
            .setData(session.asFirestoreData(), merge: true) { error in
                if let error {
                    AppLog.firestore.error("[DeliveryViewModel] Write failed: \(error.localizedDescription)")
                }
            }
    }

    /// Uses setData(merge: true) — NOT updateData — so the write succeeds even
    /// if the deliveries document hasn't been created yet (e.g. first tick races
    /// ahead of writeToFirestore, or a previous write silently failed).
    /// updateData fails silently on a non-existent document, which is why
    /// riderLatitude/riderLongitude were missing from Firestore.
    private func writeRiderPosition(orderId: String,
                                    coord: CLLocationCoordinate2D) {
        db.collection("deliveries")
            .document(orderId)
            .setData([
                "riderLatitude":  coord.latitude,
                "riderLongitude": coord.longitude,
                "updatedAt":      Date()
            ], merge: true) { _ in }
    }

    /// Writes the moment the simulator fires its first tick.
    /// Uses setData(merge: true) for the same reason — guarantees the field
    /// is persisted even if the parent document doesn't exist yet.
    private func writeSimulationStartTime(orderId: String, startedAt: Date) {
        db.collection("deliveries")
            .document(orderId)
            .setData(["simulationStartedAt": startedAt], merge: true) { _ in }
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
