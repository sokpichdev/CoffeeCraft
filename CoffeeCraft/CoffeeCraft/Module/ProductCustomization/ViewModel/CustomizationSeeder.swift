import FirebaseFirestore
//
//  CustomizationSeeder.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 1/17/26.
//
import Foundation

import FirebaseFirestore
import Foundation

struct CustomizationSeeder {

    static func seedCustomizations() async {
        let db = Firestore.firestore()
        let customizationsRef = db.collection("customizations")

        for customization in customizationData {
            await saveCustomization(customization, ref: customizationsRef)
        }
    }

    private static func saveCustomization(
        _ customization: [String: Any],
        ref: CollectionReference
    ) async {
        do {
            guard let name = customization["name"] as? String else { return }

            let customID = name
                .lowercased()
                .replacingOccurrences(of: " ", with: "_")

            try await ref.document(customID).setData(customization)

            AppLog.menu.info("✅ Added customization: \(name)")
        } catch {
            AppLog.menu.error("❌ Failed to add customization: \(error.localizedDescription)")
        }
    }

    // MARK: - Seed Data
    private static let customizationData: [[String: Any]] = [

        [
            "name": "Size",
            "options": [
                ["name": "Small", "price": 0.0],
                ["name": "Medium", "price": 0.5],
                ["name": "Large", "price": 1.0]
            ]
        ],

        [
            "name": "Milk",
            "options": [
                ["name": "Whole", "price": 0.0],
                ["name": "Oat", "price": 0.5],
                ["name": "Soy", "price": 0.5],
                ["name": "Almond", "price": 0.5],
                ["name": "Coconut", "price": 0.5]
            ]
        ],

        [
            "name": "Extras",
            "options": [
                ["name": "Caramel", "price": 0.5],
                ["name": "Vanilla", "price": 0.5],
                ["name": "Hazelnut", "price": 0.5],
                ["name": "Chocolate", "price": 0.5],
                ["name": "Honey", "price": 0.3],
                ["name": "Cinnamon", "price": 0.2]
            ]
        ],

        [
            "name": "Toppings",
            "options": [
                ["name": "Whipped Cream", "price": 0.5],
                ["name": "Marshmallows", "price": 0.5],
                ["name": "Chocolate Drizzle", "price": 0.5],
                ["name": "Caramel Drizzle", "price": 0.5]
            ]
        ],

        [
            "name": "Sugar Level",
            "options": [
                ["name": "0%", "price": 0.0],
                ["name": "25%", "price": 0.0],
                ["name": "50%", "price": 0.0],
                ["name": "70%", "price": 0.0],
                ["name": "100%", "price": 0.0],
                ["name": "120%", "price": 0.0]
            ]
        ],

        [
            "name": "Espresso Shots",
            "options": [
                ["name": "Single", "price": 0.0],
                ["name": "Double", "price": 0.5],
                ["name": "Triple", "price": 1.0]
            ]
        ],

        [
            "name": "Ice Cream",
            "options": [
                ["name": "Vanilla", "price": 0.0],
                ["name": "Chocolate", "price": 0.5],
                ["name": "Strawberry", "price": 0.5]
            ]
        ],

        [
            "name": "Temperature",
            "options": [
                ["name": "Hot", "price": 0.0],
                ["name": "Iced", "price": 0.0],
                ["name": "Extra Hot", "price": 0.0]
            ]
        ]
    ]
}
