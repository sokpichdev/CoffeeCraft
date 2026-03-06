//
//  Branch.swift
//  CoffeeCraft
//
//  Map Module — Phase 6
//  Added: estimatedWaitMinutes — set by staff via admin panel.
//  nil means no wait time posted; 0 means "no wait right now".
//  All other fields unchanged — fully backward compatible.
//

import CoreLocation
import FirebaseFirestore

// MARK: - Branch

struct Branch: Identifiable, Codable, Hashable {
    @DocumentID var id: String?
    var name: String
    var address: String
    var latitude: Double
    var longitude: Double
    var phone: String
    var openingHours: String
    var isOpen: Bool
    var amenities: [String]
    var imageURL: String?

    // Phase 6 — set by staff, shown in BranchDetailSheet
    // nil = not posted, 0 = no wait, >0 = wait in minutes
    var estimatedWaitMinutes: Int?

    // MARK: - Computed

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    var waitLabel: String? {
        guard let mins = estimatedWaitMinutes else { return nil }
        return mins == 0 ? "No wait" : "~\(mins) min wait"
    }

    // MARK: - Amenity display helpers

    var amenityIcons: [(icon: String, label: String)] {
        amenities.compactMap { key in
            switch key {
            case "wifi":       return ("wifi", "WiFi")
            case "parking":    return ("parkingsign.circle", "Parking")
            case "dine-in":    return ("fork.knife", "Dine-in")
            case "takeaway":   return ("bag", "Takeaway")
            case "drive-thru": return ("car", "Drive-Thru")
            default:           return nil
            }
        }
    }
}
