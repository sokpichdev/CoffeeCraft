//
//  DeliverySession.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 15/03/2026.
//

import CoreLocation
import Foundation

// MARK: - DeliverySession

struct DeliverySession {

    // MARK: - Identity

    let orderId: String
    let branchId: String

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
            riderLatitude  = newValue.latitude
            riderLongitude = newValue.longitude
        }
    }

    // MARK: - Firestore Document Mapping

    /// Creates a Firestore-writable dictionary for deliveries/{orderId}.
    func asFirestoreData() -> [String: Any] {
        var data: [String: Any] = [
            "orderId": orderId,
            "branchId": branchId,
            "branchLatitude": branchLatitude,
            "branchLongitude": branchLongitude,
            "destinationLatitude": destinationLatitude,
            "destinationLongitude": destinationLongitude,
            "riderLatitude": riderLatitude,
            "riderLongitude": riderLongitude,
            "status": status.rawValue,
            "updatedAt": Date()
        ]
        if let eta  = estimatedArrival { data["estimatedArrival"] = eta }
        if let name = riderName { data["riderName"]        = name }
        if let ph   = riderPhone { data["riderPhone"]       = ph   }
        return data
    }

    /// Initialises a session from a Firestore snapshot dictionary.
    /// Returns nil when required fields are missing.
    init?(firestoreData data: [String: Any]) {
        guard
            let orderId              = data["orderId"]              as? String,
            let branchId             = data["branchId"]             as? String,
            let branchLat            = data["branchLatitude"]        as? Double,
            let branchLng            = data["branchLongitude"]       as? Double,
            let destLat              = data["destinationLatitude"]   as? Double,
            let destLng              = data["destinationLongitude"]  as? Double,
            let riderLat             = data["riderLatitude"]         as? Double,
            let riderLng             = data["riderLongitude"]        as? Double,
            let statusRaw            = data["status"]                as? String,
            let status               = DeliveryStatus(rawValue: statusRaw)
        else { return nil }

        self.orderId              = orderId
        self.branchId             = branchId
        self.branchLatitude       = branchLat
        self.branchLongitude      = branchLng
        self.destinationLatitude  = destLat
        self.destinationLongitude = destLng
        self.riderLatitude        = riderLat
        self.riderLongitude       = riderLng
        self.status               = status
        self.riderName            = data["riderName"]  as? String
        self.riderPhone           = data["riderPhone"] as? String

        if let ts = data["estimatedArrival"] as? Date {
            self.estimatedArrival = ts
        } else {
            self.estimatedArrival = nil
        }
    }

    /// Convenience init used when the simulator creates a fresh session.
    init(
        orderId: String,
        branchId: String,
        branchCoordinate: CLLocationCoordinate2D,
        destinationCoordinate: CLLocationCoordinate2D,
        riderName: String?  = "Dara",
        riderPhone: String?  = "+855 12 345 678"
    ) {
        self.orderId              = orderId
        self.branchId             = branchId
        self.branchLatitude       = branchCoordinate.latitude
        self.branchLongitude      = branchCoordinate.longitude
        self.destinationLatitude  = destinationCoordinate.latitude
        self.destinationLongitude = destinationCoordinate.longitude
        // Rider starts at the branch
        self.riderLatitude        = branchCoordinate.latitude
        self.riderLongitude       = branchCoordinate.longitude
        self.status               = .orderPlaced
        self.estimatedArrival     = nil
        self.riderName            = riderName
        self.riderPhone           = riderPhone
    }
}
