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
            ],
            [
                "name": "Espresso",
                "description": "Strong and bold espresso shot.",
                "price": 2.5,
                "imageURL": "https://images.unsplash.com/photo-1525493376214-ff165c3c63e4",
                "customizations": [
                    "Size": ["Single", "Double"],
                    "Extras": ["Sugar", "Cinnamon"]
                ]
            ],
            [
                "name": "Flat White",
                "description": "Smooth espresso with velvety steamed milk.",
                "price": 4.0,
                "imageURL": "https://images.unsplash.com/photo-1581911774634-1d028dcf6b79",
                "customizations": [
                    "Size": ["Small", "Medium", "Large"],
                    "Milk": ["Whole", "Oat", "Soy"]
                ]
            ],
            [
                "name": "Caramel Macchiato",
                "description": "Espresso with steamed milk and caramel drizzle.",
                "price": 4.5,
                "imageURL": "https://images.unsplash.com/photo-1589302168068-964664d93dc0",
                "customizations": [
                    "Size": ["Small", "Medium", "Large"],
                    "Milk": ["Whole", "Oat", "Soy"],
                    "Extras": ["Vanilla", "Caramel"]
                ]
            ],
            [
                "name": "Chai Latte",
                "description": "Spiced tea with steamed milk.",
                "price": 3.8,
                "imageURL": "https://images.unsplash.com/photo-1600792128701-0e68b7c95a4f",
                "customizations": [
                    "Size": ["Small", "Medium", "Large"],
                    "Milk": ["Whole", "Oat", "Soy"],
                    "Sweetness": ["Low", "Medium", "High"]
                ]
            ],
            [
                "name": "Matcha Latte",
                "description": "Creamy green tea latte with a hint of sweetness.",
                "price": 4.2,
                "imageURL": "https://images.unsplash.com/photo-1562003385-48a2b8d2dc08",
                "customizations": [
                    "Size": ["Small", "Medium", "Large"],
                    "Milk": ["Whole", "Oat", "Soy"],
                    "Extras": ["Honey", "Vanilla"]
                ]
            ],
            [
                "name": "Iced Latte",
                "description": "Chilled espresso with milk over ice.",
                "price": 3.9,
                "imageURL": "https://images.unsplash.com/photo-1509042239860-f550ce710b93",
                "customizations": [
                    "Size": ["Small", "Medium", "Large"],
                    "Milk": ["Whole", "Oat", "Soy", "Almond"],
                    "Extras": ["Caramel", "Vanilla"]
                ]
            ],
            [
                "name": "Affogato",
                "description": "Espresso poured over vanilla ice cream.",
                "price": 5.0,
                "imageURL": "https://images.unsplash.com/photo-1524182576067-08b2b7f38c56",
                "customizations": [
                    "Ice Cream": ["Vanilla", "Chocolate"],
                    "Espresso Shots": ["Single", "Double"]
                ]
            ],
            [
                "name": "Honey Latte",
                "description": "Sweet latte with a touch of honey.",
                "price": 4.0,
                "imageURL": "https://images.unsplash.com/photo-1541167760496-1628856ab772",
                "customizations": [
                    "Size": ["Small", "Medium", "Large"],
                    "Milk": ["Whole", "Oat", "Soy"]
                ]
            ],
            [
                "name": "Turmeric Latte",
                "description": "Warm milk with turmeric and spices.",
                "price": 4.3,
                "imageURL": "https://images.unsplash.com/photo-1562440499-64aa7e0f91e6",
                "customizations": [
                    "Size": ["Small", "Medium", "Large"],
                    "Milk": ["Whole", "Oat", "Soy"],
                    "Sweetness": ["Low", "Medium", "High"]
                ]
            ],
            [
                "name": "Vanilla Latte",
                "description": "Classic latte with vanilla syrup.",
                "price": 4.2,
                "imageURL": "https://images.unsplash.com/photo-1511920170033-f8396924c348",
                "customizations": [
                    "Size": ["Small", "Medium", "Large"],
                    "Milk": ["Whole", "Oat", "Soy"],
                    "Extras": ["Vanilla", "Caramel"]
                ]
            ],
            [
                "name": "Iced Mocha",
                "description": "Chilled chocolate espresso drink.",
                "price": 4.5,
                "imageURL": "https://images.unsplash.com/photo-1509042239860-f550ce710b93",
                "customizations": [
                    "Size": ["Small", "Medium", "Large"],
                    "Milk": ["Whole", "Oat", "Soy"],
                    "Extras": ["Whipped Cream", "Chocolate Drizzle"]
                ]
            ],
            [
                "name": "Black Tea",
                "description": "Simple hot black tea.",
                "price": 2.0,
                "imageURL": "https://images.unsplash.com/photo-1579370318442-0d79f19c76f1",
                "customizations": [
                    "Size": ["Small", "Medium", "Large"],
                    "Sweetness": ["None", "Low", "Medium", "High"]
                ]
            ],
            [
                "name": "Green Tea",
                "description": "Refreshing hot green tea.",
                "price": 2.2,
                "imageURL": "https://images.unsplash.com/photo-1562440499-64aa7e0f91e6",
                "customizations": [
                    "Size": ["Small", "Medium", "Large"],
                    "Sweetness": ["None", "Low", "Medium", "High"]
                ]
            ],
            [
                "name": "Hot Chocolate",
                "description": "Rich and creamy hot chocolate drink.",
                "price": 3.5,
                "imageURL": "https://images.unsplash.com/photo-1541167760496-1628856ab772",
                "customizations": [
                    "Size": ["Small", "Medium", "Large"],
                    "Extras": ["Whipped Cream", "Marshmallows", "Chocolate Drizzle"]
                ]
            ],
            [
                "name": "Caramel Iced Coffee",
                "description": "Iced coffee with caramel syrup.",
                "price": 4.0,
                "imageURL": "https://images.unsplash.com/photo-1509042239860-f550ce710b93",
                "customizations": [
                    "Size": ["Small", "Medium", "Large"],
                    "Milk": ["Whole", "Oat", "Soy"],
                    "Extras": ["Caramel", "Vanilla"]
                ]
            ],
            [
                "name": "Hazelnut Latte",
                "description": "Latte with hazelnut syrup.",
                "price": 4.3,
                "imageURL": "https://images.unsplash.com/photo-1511920170033-f8396924c348",
                "customizations": [
                    "Size": ["Small", "Medium", "Large"],
                    "Milk": ["Whole", "Oat", "Soy"],
                    "Extras": ["Hazelnut", "Caramel"]
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
