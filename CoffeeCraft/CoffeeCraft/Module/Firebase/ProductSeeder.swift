//
//  ProductSeeder.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 10/20/25.
//
import Foundation
import FirebaseFirestore

struct ProductSeeder {
    static func seedSampleProducts() async {
        let db = Firestore.firestore()
        let productsRef = db.collection("products")

        // Sample coffee list
        let sampleProducts: [[String: Any]] = [
            [
                "name": "Cappuccino",
                "description": "A classic Italian coffee with steamed milk foam.",
                "price": 3.5,
                "imageURL": "https://images.unsplash.com/photo-1511920170033-f8396924c348",
                "customizations": [
                    "Size": ["Small", "Medium", "Large"],
                    "Milk": ["Whole", "Oat", "Soy"],
                    "Extras": ["Caramel", "Vanilla", "Chocolate"]
                ]
            ],
            [
                "name": "Latte",
                "description": "Smooth espresso with steamed milk and a light layer of foam.",
                "price": 4.0,
                "imageURL": "https://images.unsplash.com/photo-1509042239860-f550ce710b93",
                "customizations": [
                    "Size": ["Small", "Medium", "Large"],
                    "Milk": ["Whole", "Oat", "Soy", "Almond"],
                    "Extras": ["Caramel", "Vanilla", "Hazelnut"]
                ]
            ],
            [
                "name": "Iced Americano",
                "description": "Strong espresso poured over cold water and ice cubes.",
                "price": 2.8,
                "imageURL": "https://images.unsplash.com/photo-1527168027773-0cc890c0f29f",
                "customizations": [
                    "Size": ["Small", "Medium", "Large"],
                    "Extras": ["Lemon", "Sugar Syrup"]
                ]
            ],
            [
                "name": "Mocha",
                "description": "Espresso with rich chocolate and steamed milk.",
                "price": 4.2,
                "imageURL": "https://images.unsplash.com/photo-1509042239860-f550ce710b93",
                "customizations": [
                    "Size": ["Small", "Medium", "Large"],
                    "Milk": ["Whole", "Soy", "Oat"],
                    "Extras": ["Whipped Cream", "Chocolate Drizzle"]
                ]
            ]
        ]

        for product in sampleProducts {
            do {
                _ = try await productsRef.addDocument(data: product)
                print("✅ Added product: \(product["name"] ?? "")")
            } catch {
                print("❌ Failed to add product: \(error.localizedDescription)")
            }
        }
    }
}
