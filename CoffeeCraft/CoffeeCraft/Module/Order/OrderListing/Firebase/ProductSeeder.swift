//
//  ProductSeeder.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 10/20/25.
//
// swiftlint:disable force_unwrapping
import FirebaseFirestore
import Foundation

struct ProductSeeder {

    static func seedSampleProducts() async {
        let db = Firestore.firestore()
        let productsRef = db.collection("products")

        for product in sampleProducts {
            await saveProduct(product, ref: productsRef)
        }
    }

    private static func saveProduct(
        _ product: [String: Any],
        ref: CollectionReference
    ) async {
        do {
            let productName = product["name"] as! String
            let productID = productName.generateProductID()

            try await ref.document(productID).setData(product)

            AppLog.firestore.info("✅ Added product with ID: \(productID)")
        } catch {
            AppLog.firestore.error("❌ Failed to add product: \(error.localizedDescription)")
        }
    }

    // MARK: - Seed Data
    private static let sampleProducts: [[String: Any]] = [

        [
            "name": "Cappuccino",
            "description": "A classic Italian coffee with steamed milk foam.",
            "price": 3.5,
            "category": "Coffee",
            "imageURL": "https://i.postimg.cc/VNK61H8p/capp.jpg",
            "customizations": [
                "Size": ["Small": 0.0, "Medium": 0.5, "Large": 1.0],
                "Milk": ["Whole": 0.0, "Oat": 0.5, "Soy": 0.5],
                "Extras": ["Caramel": 0.5, "Vanilla": 0.5, "Chocolate": 0.5]
            ]
        ],

        [
            "name": "Latte",
            "description": "Smooth espresso with steamed milk and a light layer of foam.",
            "price": 4.0,
            "category": "Coffee",
            "imageURL": "https://i.postimg.cc/WpX7CsCJ/Caffe-Latte-at-Pulse-Cafe.jpg",
            "customizations": [
                "Size": ["Small": 0.0, "Medium": 0.5, "Large": 1.0],
                "Milk": ["Whole": 0.0, "Oat": 0.5, "Soy": 0.5, "Almond": 0.5],
                "Extras": ["Caramel": 0.5, "Vanilla": 0.5, "Hazelnut": 0.5]
            ]
        ],

        [
            "name": "Mocha",
            "description": "Espresso with rich chocolate and steamed milk.",
            "price": 4.2,
            "category": "Coffee",
            "imageURL": "https://i.postimg.cc/7LJPz1Jc/Mocha-1fc71f7.png",
            "customizations": [
                "Size": ["Small": 0.0, "Medium": 0.5, "Large": 1.0],
                "Milk": ["Whole": 0.0, "Soy": 0.5, "Oat": 0.5],
                "Extras": ["Whipped Cream": 0.5, "Chocolate Drizzle": 0.5]
            ]
        ],

        // (All the rest of your products stay exactly here)
        // Green Tea, Black Tea, Matcha Latte, Hot Chocolate,
        // Iced Americano, Iced Latte, Iced Mocha, Caramel Iced Coffee,
        // Caramel Macchiato, Vanilla Latte, Hazelnut Latte,
        // Honey Latte, Turmeric Latte, Affogato

    ]
}

