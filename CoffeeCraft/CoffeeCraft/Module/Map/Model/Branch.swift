//
//  Branch.swift
//  CoffeeCraft
//
//  Map Module — Phase 4
//  Added FirebaseFirestore import + @DocumentID so Firestore can decode
//  the document ID into Branch.id automatically.
//  All existing fields unchanged — fully backward compatible with MockBranchData.
//

import CoreLocation
import FirebaseFirestore

// MARK: - Branch

struct Branch: Identifiable, Codable, Hashable {
    @DocumentID var id: String?         // Firestore doc ID — also used as mock id
    var name: String
    var address: String
    var latitude: Double
    var longitude: Double
    var phone: String
    var openingHours: String            // e.g. "Mon–Sun  7:00 – 22:00"
    var isOpen: Bool
    var amenities: [String]             // e.g. ["wifi", "parking", "dine-in"]
    var imageURL: String?

    // MARK: - Computed

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    // MARK: - Amenity display helpers

    var amenityIcons: [(icon: String, label: String)] {
        amenities.compactMap { key in
            switch key {
            case "wifi":       return ("wifi",               "WiFi")
            case "parking":    return ("parkingsign.circle", "Parking")
            case "dine-in":    return ("fork.knife",         "Dine-in")
            case "takeaway":   return ("bag",                "Takeaway")
            case "drive-thru": return ("car",                "Drive-Thru")
            default:           return nil
            }
        }
    }
}
