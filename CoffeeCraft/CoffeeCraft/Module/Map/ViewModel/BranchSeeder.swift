//
//  BranchSeeder.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 3/6/26.
//  Seeds the branches/ Firestore collection with the 5 Phnom Penh branches.
//
//  Usage (run once, e.g. from a hidden admin button or from AppDelegate):
//
//      Task { await BranchSeeder.seed() }
//
//  The function is idempotent — calling it again overwrites existing docs
//  with the same data (setData merges nothing, it replaces). Safe to re-run.
//
//  ⚠️  Remove the call site (but keep this file) once Firestore is seeded.
//      The seeder itself is harmless to leave in the project.
//

import FirebaseFirestore
import Foundation

// MARK: - BranchSeeder

struct BranchSeeder {

    static func seed() async {
        let db  = Firestore.firestore()
        let ref = db.collection("branches")

        // Each dict maps exactly to the Branch Codable model.
        // Document ID = branch.id — must match the strings in MockBranchData.
        let branches: [(id: String, data: [String: Any])] = [

            (
                id: "branch_norodom",
                data: [
                    "name": "CoffeeCraft – Norodom",
                    "address": "Norodom Blvd, near Independence Monument, Phnom Penh",
                    "latitude": 11.5637,
                    "longitude": 104.9230,
                    "phone": "+855 23 456 001",
                    "openingHours": "Mon–Sun  7:00 – 22:00",
                    "isOpen": true,
                    "amenities": ["wifi", "dine-in", "takeaway"]
                ]
            ),

            (
                id: "branch_riverside",
                data: [
                    "name": "CoffeeCraft – Riverside",
                    "address": "Sisowath Quay, Daun Penh, Phnom Penh",
                    "latitude": 11.5696,
                    "longitude": 104.9307,
                    "phone": "+855 23 456 002",
                    "openingHours": "Mon–Sun  7:00 – 23:00",
                    "isOpen": true,
                    "amenities": ["wifi", "dine-in", "takeaway", "parking"]
                ]
            ),

            (
                id: "branch_toul_tom_poung",
                data: [
                    "name": "CoffeeCraft – TTP Market",
                    "address": "Russian Market Area, Toul Tom Poung, Phnom Penh",
                    "latitude": 11.5435,
                    "longitude": 104.9218,
                    "phone": "+855 23 456 003",
                    "openingHours": "Mon–Fri  7:00 – 21:00  |  Sat–Sun  8:00 – 22:00",
                    "isOpen": false,
                    "amenities": ["wifi", "takeaway"]
                ]
            ),

            (
                id: "branch_olympia",
                data: [
                    "name": "CoffeeCraft – Olympia",
                    "address": "Olympia City Mall, Phnom Penh",
                    "latitude": 11.5612,
                    "longitude": 104.9108,
                    "phone": "+855 23 456 004",
                    "openingHours": "Mon–Sun  9:00 – 21:30",
                    "isOpen": true,
                    "amenities": ["wifi", "dine-in", "takeaway", "parking"]
                ]
            ),

            (
                id: "branch_sen_sok",
                data: [
                    "name": "CoffeeCraft – Sen Sok",
                    "address": "AEON Mall Sen Sok, Phnom Penh",
                    "latitude": 11.5892,
                    "longitude": 104.9019,
                    "phone": "+855 23 456 005",
                    "openingHours": "Mon–Sun  9:00 – 22:00",
                    "isOpen": true,
                    "amenities": ["wifi", "dine-in", "takeaway", "parking", "drive-thru"]
                ]
            )
        ]

        AppLog.firestore.info("🌱 BranchSeeder — starting, \(branches.count) branches")

        for branch in branches {
            do {
                try await ref.document(branch.id).setData(branch.data)
                AppLog.firestore.info("✅ Seeded branch: \(branch.id)")
            } catch {
                AppLog.firestore.error("❌ Failed to seed \(branch.id): \(error.localizedDescription)")
            }
        }

        AppLog.firestore.info("🌱 BranchSeeder — done")
    }
}
