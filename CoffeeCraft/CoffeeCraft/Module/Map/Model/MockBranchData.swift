//
//  MockBranchData.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 06/03/2026.
//  Map Module — Phase 2: Branches on Map
//
//  ⚠️ Development only — removed in Phase 6 when Firestore is live.
//
//  branch_sf_union_square is on Post St, San Francisco — full Apple Maps
//  routing is available here. The #if DEBUG user location in MapViewModel
//  is set to the Moscone Center (~1.4 km away) so MKDirections returns a
//  real driving polyline for delivery simulation testing.
//

import Foundation

// MARK: - MockBranchData

enum MockBranchData {
    static let all: [Branch] = [

        // ★ USA — Post St, Union Square, San Francisco
        //   Full Apple Maps routing available. Use with DEBUG mock home below.
        Branch(
            id: "branch_sf_union_square",
            name: "CoffeeCraft – Union Square",
            address: "333 Post St, Union Square, San Francisco, CA",
            latitude: 37.7881,
            longitude: -122.4075,
            phone: "+1 415 555 0101",
            openingHours: "Mon–Sun  6:00 – 21:00",
            isOpen: true,
            amenities: ["wifi", "dine-in", "takeaway"],
            imageURL: nil
        ),

        // ★ USA — Market St, SoMa, San Francisco
        //   ~1.2 km from Union Square branch — good delivery test route.
        Branch(
            id: "branch_sf_soma",
            name: "CoffeeCraft – SoMa",
            address: "680 Mission St, SoMa, San Francisco, CA",
            latitude: 37.7872,
            longitude: -122.4004,
            phone: "+1 415 555 0102",
            openingHours: "Mon–Fri  7:00 – 20:00  |  Sat–Sun  8:00 – 20:00",
            isOpen: true,
            amenities: ["wifi", "dine-in", "takeaway", "parking"],
            imageURL: nil
        ),

        // Phnom Penh branches kept for reference (routing limited in Cambodia)
        Branch(
            id: "branch_norodom",
            name: "CoffeeCraft – Norodom (PNH)",
            address: "Norodom Blvd, near Independence Monument, Phnom Penh",
            latitude: 11.5637,
            longitude: 104.9230,
            phone: "+855 23 456 001",
            openingHours: "Mon–Sun  7:00 – 22:00",
            isOpen: true,
            amenities: ["wifi", "dine-in", "takeaway"],
            imageURL: nil
        ),
        Branch(
            id: "branch_riverside",
            name: "CoffeeCraft – Riverside (PNH)",
            address: "Sisowath Quay, Daun Penh, Phnom Penh",
            latitude: 11.5696,
            longitude: 104.9307,
            phone: "+855 23 456 002",
            openingHours: "Mon–Sun  7:00 – 23:00",
            isOpen: false,
            amenities: ["wifi", "dine-in", "takeaway", "parking"],
            imageURL: nil
        ),
        Branch(
            id: "branch_sen_sok",
            name: "CoffeeCraft – Sen Sok (PNH)",
            address: "AEON Mall Sen Sok, Phnom Penh",
            latitude: 11.5892,
            longitude: 104.9019,
            phone: "+855 23 456 005",
            openingHours: "Mon–Sun  9:00 – 22:00",
            isOpen: false,
            amenities: ["wifi", "dine-in", "takeaway", "parking", "drive-thru"],
            imageURL: nil
        )
    ]
}
