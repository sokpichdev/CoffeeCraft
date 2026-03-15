//
//  MockBranchData.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 06/03/2026.
//  Map Module — Phase 2: Branches on Map
//
//  ⚠️ Development only — removed in Phase 6 when Firestore is live.
//

import Foundation

// MARK: - MockBranchData

enum MockBranchData {
    static let all: [Branch] = [
        // ★ Placed on Norodom Blvd — well-routed in Apple Maps / MKDirections
        Branch(
            id: "branch_norodom",
            name: "CoffeeCraft – Norodom",
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
            name: "CoffeeCraft – Riverside",
            address: "Sisowath Quay, Daun Penh, Phnom Penh",
            latitude: 11.5696,
            longitude: 104.9307,
            phone: "+855 23 456 002",
            openingHours: "Mon–Sun  7:00 – 23:00",
            isOpen: true,
            amenities: ["wifi", "dine-in", "takeaway", "parking"],
            imageURL: nil
        ),
        Branch(
            id: "branch_toul_tom_poung",
            name: "CoffeeCraft – TTP Market",
            address: "Russian Market Area, Toul Tom Poung, Phnom Penh",
            latitude: 11.5435,
            longitude: 104.9218,
            phone: "+855 23 456 003",
            openingHours: "Mon–Fri  7:00 – 21:00  |  Sat–Sun  8:00 – 22:00",
            isOpen: false,
            amenities: ["wifi", "takeaway"],
            imageURL: nil
        ),
        Branch(
            id: "branch_olympia",
            name: "CoffeeCraft – Olympia",
            address: "Olympia City Mall, Phnom Penh",
            latitude: 11.5612,
            longitude: 104.9108,
            phone: "+855 23 456 004",
            openingHours: "Mon–Sun  9:00 – 21:30",
            isOpen: true,
            amenities: ["wifi", "dine-in", "takeaway", "parking"],
            imageURL: nil
        ),
        Branch(
            id: "branch_sen_sok",
            name: "CoffeeCraft – Sen Sok",
            address: "AEON Mall Sen Sok, Phnom Penh",
            latitude: 11.5892,
            longitude: 104.9019,
            phone: "+855 23 456 005",
            openingHours: "Mon–Sun  9:00 – 22:00",
            isOpen: true,
            amenities: ["wifi", "dine-in", "takeaway", "parking", "drive-thru"],
            imageURL: nil
        )
    ]
}
