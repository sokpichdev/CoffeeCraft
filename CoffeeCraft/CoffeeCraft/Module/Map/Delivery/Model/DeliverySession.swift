//
//  DeliverySession.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 15/03/2026.
//

import CoreLocation
import FirebaseFirestore
import Foundation

// MARK: - DeliverySession

struct DeliverySession {

    // MARK: - Identity

    let orderId: String
    let branchId: String

    let userId: String

    // MARK: - Coordinates (flat storage, Codable-friendly)

    let branchLatitude: Double
    let branchLongitude: Double

    /// The delivery destination — from SavedLocation or live GPS at order time.
    /// Stored once at order placement so simulation is stable even if the
    /// user's device moves.
    let destinationLatitude: Double
    let destinationLongitude: Double

    /// Current rider position — updated every ~2 s by the simulator and by
    /// Firestore when a real rider GPS feed is available (Phase 6).
    var riderLatitude: Double
    var riderLongitude: Double

    // MARK: - Status & Timing

    var status: DeliveryStatus
    var estimatedArrival: Date?

    /// Timestamp written to Firestore the moment the simulator fires its first tick.
    /// Used on restore to compute how many steps the rider has already travelled
    /// so the simulation resumes mid-route instead of restarting from the branch.
    /// Nil until the simulator actually starts moving.
    var simulationStartedAt: Date?

    // MARK: - Rider Info (optional — nil until riderAssigned)

    var riderName: String?
    var riderPhone: String?

    // MARK: - Computed Coordinates

    var branchCoordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: branchLatitude, longitude: branchLongitude)
    }

    var destinationCoordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: destinationLatitude, longitude: destinationLongitude)
    }

    var riderCoordinate: CLLocationCoordinate2D {
        get { CLLocationCoordinate2D(latitude: riderLatitude, longitude: riderLongitude) }
        set {
            riderLatitude = newValue.latitude
            riderLongitude = newValue.longitude
        }
    }

    // MARK: - Firestore Document Mapping

    /// Creates a Firestore-writable dictionary for deliveries/{orderId}.
    ///
    /// ⚠️ Does NOT include riderLatitude/riderLongitude — those are written
    /// exclusively by DeliveryViewModel.writeRiderPosition() every simulator tick.
    /// Keeping them out of this dict prevents the initial writeToFirestore() call
    /// from clobbering the last saved rider position with the branch coordinates
    /// when the app restarts and startDelivery() is called on a fresh session.
    func asFirestoreData() -> [String: Any] {
        var data: [String: Any] = [
            Firebase.Deliveries.orderId: orderId,
            Firebase.Deliveries.branchId: branchId,
            Firebase.Deliveries.userId: userId,
            Firebase.Deliveries.branchLatitude: branchLatitude,
            Firebase.Deliveries.branchLongitude: branchLongitude,
            Firebase.Deliveries.destinationLatitude: destinationLatitude,
            Firebase.Deliveries.destinationLongitude: destinationLongitude,
            Firebase.Deliveries.status: status.rawValue,
            Firebase.Deliveries.updatedAt: Date()
        ]
        if let eta = estimatedArrival { data[Firebase.Deliveries.estimatedArrival] = eta }
        if let name = riderName { data[Firebase.Deliveries.riderName] = name }
        if let ph = riderPhone { data[Firebase.Deliveries.riderPhone] = ph }
        if let sat = simulationStartedAt { data[Firebase.Deliveries.simulationStartedAt] = sat }
        return data }

    /// Initialises a session from a Firestore snapshot dictionary.
    /// Returns nil when required fields are missing.
    init?(firestoreData data: [String: Any]) {
        guard
            let orderId = data[Firebase.Deliveries.orderId] as? String,
            let branchId = data[Firebase.Deliveries.branchId] as? String,
            let userId = data[Firebase.Deliveries.userId] as? String,
            let branchLat = data[Firebase.Deliveries.branchLatitude] as? Double,
            let branchLng = data[Firebase.Deliveries.branchLongitude] as? Double,
            let destLat = data[Firebase.Deliveries.destinationLatitude] as? Double,
            let destLng = data[Firebase.Deliveries.destinationLongitude] as? Double,
            let riderLat = data[Firebase.Deliveries.riderLatitude] as? Double,
            let riderLng = data[Firebase.Deliveries.riderLongitude] as? Double,
            let statusRaw = data[Firebase.Deliveries.status] as? String,
            let status = DeliveryStatus(rawValue: statusRaw)
        else { return nil }

        self.orderId = orderId
        self.branchId = branchId
        self.userId = userId
        self.branchLatitude = branchLat
        self.branchLongitude = branchLng
        self.destinationLatitude = destLat
        self.destinationLongitude = destLng
        self.riderLatitude = riderLat
        self.riderLongitude = riderLng
        self.status = status
        self.riderName = data[Firebase.Deliveries.riderName] as? String
        self.riderPhone = data[Firebase.Deliveries.riderPhone] as? String

        // Firestore returns Timestamp objects, not Swift Dates.
        // We must call .dateValue() — casting directly with "as? Date" always fails.
        if let ts = data[Firebase.Deliveries.estimatedArrival] as? Timestamp {
            self.estimatedArrival = ts.dateValue()
        } else {
            self.estimatedArrival = nil
        }

        if let sat = data[Firebase.Deliveries.simulationStartedAt] as? Timestamp {
            self.simulationStartedAt = sat.dateValue()
        } else {
            self.simulationStartedAt = nil
        }
    }

    /// Convenience init used when the simulator creates a fresh session.
    init(
        orderId: String,
        branchId: String,
        userId: String = "",
        branchCoordinate: CLLocationCoordinate2D,
        destinationCoordinate: CLLocationCoordinate2D,
        riderName: String? = "Dara",
        riderPhone: String? = "+855 12 345 678"
    ) {
        self.orderId = orderId
        self.branchId = branchId
        self.userId = userId
        self.branchLatitude = branchCoordinate.latitude
        self.branchLongitude = branchCoordinate.longitude
        self.destinationLatitude = destinationCoordinate.latitude
        self.destinationLongitude = destinationCoordinate.longitude
        // Rider starts at the branch
        self.riderLatitude = branchCoordinate.latitude
        self.riderLongitude = branchCoordinate.longitude
        self.status = .orderPlaced
        self.estimatedArrival = nil
        self.simulationStartedAt = nil
        self.riderName = riderName
        self.riderPhone = riderPhone
    }
}
