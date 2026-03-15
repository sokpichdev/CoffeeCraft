//
//  SavedLocation.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 15/03/2026.
//
//  A named delivery address stored per-user in Firestore.
//  Firestore path: users/{uid}/savedLocations/{locationId}
//

import CoreLocation
import FirebaseFirestore
import Foundation

// MARK: - SavedLocation

struct SavedLocation: Identifiable, Codable, Hashable {

    // MARK: - Stored Fields

    @DocumentID var id: String?
    var label:     String      // "Home", "Work", "Mum's Place"
    var address:   String      // Human-readable address from MKLocalSearch
    var latitude:  Double
    var longitude: Double
    var isDefault: Bool        // Pre-selected at checkout
    var createdAt: Date

    // MARK: - Computed

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    // MARK: - Hashable / Equatable

    func hash(into hasher: inout Hasher) { hasher.combine(id) }

    static func == (lhs: SavedLocation, rhs: SavedLocation) -> Bool {
        lhs.id == rhs.id &&
        lhs.label == rhs.label &&
        lhs.address == rhs.address &&
        lhs.isDefault == rhs.isDefault
    }

    // MARK: - Label Suggestions

    static let suggestedLabels = ["Home", "Work", "Gym", "School", "Partner's Place"]
}
