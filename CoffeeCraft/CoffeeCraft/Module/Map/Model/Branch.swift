//
//  Branch.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 06/03/2026.
//  Map Module — Phase 2: Branches on Map
//

import CoreLocation

// MARK: - Branch

struct Branch: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let address: String
    let latitude: Double
    let longitude: Double
    let phone: String
    let openingHours: String       // e.g. "Mon–Sun  7:00 – 22:00"
    let isOpen: Bool
    let amenities: [String]        // e.g. ["wifi", "parking", "dine-in"]
    let imageURL: String?

    // MARK: - Computed

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    // MARK: - Amenity display helpers

    var amenityIcons: [(icon: String, label: String)] {
        amenities.compactMap { key in
            switch key {
            case "wifi":      return ("wifi",              "WiFi")
            case "parking":   return ("parkingsign.circle","Parking")
            case "dine-in":   return ("fork.knife",        "Dine-in")
            case "takeaway":  return ("bag",               "Takeaway")
            case "drive-thru":return ("car",               "Drive-Thru")
            default:          return nil
            }
        }
    }
}
