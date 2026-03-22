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
        let ref = db.collection(Firebase.Branches.collection)

        // Each dict maps exactly to the Branch Codable model.
        // Document ID = branch.id — must match the strings in MockBranchData.
        let branches: [(id: String, data: [String: Any])] = [

            // ── USA branches (full MKDirections routing available) ──────
            (
                id: "branch_sf_union_square",
                data: [
                    "name": "CoffeeCraft – Union Square",
                    "address": "333 Post St, Union Square, San Francisco, CA",
                    "latitude": 37.7881,
                    "longitude": -122.4075,
                    "phone": "+1 415 555 0101",
                    "openingHours": "Mon–Sun  6:00 – 21:00",
                    "isOpen": true,
                    "amenities": ["wifi", "dine-in", "takeaway"]
                ]
            ),
            (
                id: "branch_sf_soma",
                data: [
                    "name": "CoffeeCraft – SoMa",
                    "address": "680 Mission St, SoMa, San Francisco, CA",
                    "latitude": 37.7872,
                    "longitude": -122.4004,
                    "phone": "+1 415 555 0102",
                    "openingHours": "Mon–Fri  7:00 – 20:00  |  Sat–Sun  8:00 – 20:00",
                    "isOpen": true,
                    "amenities": ["wifi", "dine-in", "takeaway", "parking"]
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
