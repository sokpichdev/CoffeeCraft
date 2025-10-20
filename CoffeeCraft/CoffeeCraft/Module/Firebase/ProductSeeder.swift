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
            // Coffee
            [
                "name": "Cappuccino",
                "description": "A classic Italian coffee with steamed milk foam.",
                "price": 3.5,
                "category": "Coffee",
                "imageURL": "https://i.postimg.cc/VNK61H8p/capp.jpg",
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
                "category": "Coffee",
                "imageURL": "https://i.postimg.cc/WpX7CsCJ/Caffe-Latte-at-Pulse-Cafe.jpg",
                "customizations": [
                    "Size": ["Small", "Medium", "Large"],
                    "Milk": ["Whole", "Oat", "Soy", "Almond"],
                    "Extras": ["Caramel", "Vanilla", "Hazelnut"]
                ]
            ],
            [
                "name": "Mocha",
                "description": "Espresso with rich chocolate and steamed milk.",
                "price": 4.2,
                "category": "Coffee",
                "imageURL": "https://i.postimg.cc/7LJPz1Jc/Mocha-1fc71f7.png",
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
                "category": "Coffee",
                "imageURL": "https://i.postimg.cc/W1FcYNpw/espresso-d93cf1fb-0d4d-4da2-877f-c8226560ea4a.webp",
                "customizations": [
                    "Size": ["Single", "Double"],
                    "Extras": ["Sugar", "Cinnamon"]
                ]
            ],

            // Tea
            [
                "name": "Chai Latte",
                "description": "Spiced tea with steamed milk.",
                "price": 3.8,
                "category": "Tea",
                "imageURL": "https://i.postimg.cc/yxNBj0ry/image.png",
                "customizations": [
                    "Size": ["Small", "Medium", "Large"],
                    "Milk": ["Whole", "Oat", "Soy"],
                    "Sweetness": ["Low", "Medium", "High"]
                ]
            ],
            [
                "name": "Green Tea",
                "description": "Refreshing hot green tea.",
                "price": 2.2,
                "category": "Tea",
                "imageURL": "https://i.postimg.cc/Z5Wn4zHf/image.png",
                "customizations": [
                    "Size": ["Small", "Medium", "Large"],
                    "Sweetness": ["None", "Low", "Medium", "High"]
                ]
            ],
            [
                "name": "Black Tea",
                "description": "Simple hot black tea.",
                "price": 2.0,
                "category": "Tea",
                "imageURL": "https://i.postimg.cc/Y07LCD09/image.png",
                "customizations": [
                    "Size": ["Small", "Medium", "Large"],
                    "Sweetness": ["None", "Low", "Medium", "High"]
                ]
            ],

            // Matcha Series
            [
                "name": "Matcha Latte",
                "description": "Creamy green tea latte with a hint of sweetness.",
                "price": 4.2,
                "category": "Matcha",
                "imageURL": "https://i.postimg.cc/44c14j81/image.png",
                "customizations": [
                    "Size": ["Small", "Medium", "Large"],
                    "Milk": ["Whole", "Oat", "Soy"],
                    "Extras": ["Honey", "Vanilla"]
                ]
            ],

            // Hot Chocolate
            [
                "name": "Hot Chocolate",
                "description": "Rich and creamy hot chocolate drink.",
                "price": 3.5,
                "category": "Hot Chocolate",
                "imageURL": "https://i.postimg.cc/4xg2TXsS/image.png",
                "customizations": [
                    "Size": ["Small", "Medium", "Large"],
                    "Extras": ["Whipped Cream", "Marshmallows", "Chocolate Drizzle"]
                ]
            ],

            // Iced Coffee
            [
                "name": "Iced Americano",
                "description": "Strong espresso poured over cold water and ice cubes.",
                "price": 2.8,
                "category": "Iced Coffee",
                "imageURL": "https://i.postimg.cc/442WnzZ5/image.png",
                "customizations": [
                    "Size": ["Small", "Medium", "Large"],
                    "Extras": ["Lemon", "Sugar Syrup"]
                ]
            ],
            [
                "name": "Iced Latte",
                "description": "Chilled espresso with milk over ice.",
                "price": 3.9,
                "category": "Iced Coffee",
                "imageURL": "https://i.postimg.cc/PrF0GgNK/image.png",
                "customizations": [
                    "Size": ["Small", "Medium", "Large"],
                    "Milk": ["Whole", "Oat", "Soy", "Almond"],
                    "Extras": ["Caramel", "Vanilla"]
                ]
            ],
            [
                "name": "Iced Mocha",
                "description": "Chilled chocolate espresso drink.",
                "price": 4.5,
                "category": "Iced Coffee",
                "imageURL": "https://i.postimg.cc/PJHTwB1z/image.png",
                "customizations": [
                    "Size": ["Small", "Medium", "Large"],
                    "Milk": ["Whole", "Oat", "Soy"],
                    "Extras": ["Whipped Cream", "Chocolate Drizzle"]
                ]
            ],
            [
                "name": "Caramel Iced Coffee",
                "description": "Iced coffee with caramel syrup.",
                "price": 4.0,
                "category": "Iced Coffee",
                "imageURL": "https://i.postimg.cc/Mp9H8K1n/image.png",
                "customizations": [
                    "Size": ["Small", "Medium", "Large"],
                    "Milk": ["Whole", "Oat", "Soy"],
                    "Extras": ["Caramel", "Vanilla"]
                ]
            ],

            // Other flavored lattes
            [
                "name": "Caramel Macchiato",
                "description": "Espresso with steamed milk and caramel drizzle.",
                "price": 4.5,
                "category": "Flavored Latte",
                "imageURL": "https://i.postimg.cc/G903q40J/image.png",
                "customizations": [
                    "Size": ["Small", "Medium", "Large"],
                    "Milk": ["Whole", "Oat", "Soy"],
                    "Extras": ["Vanilla", "Caramel"]
                ]
            ],
            [
                "name": "Vanilla Latte",
                "description": "Classic latte with vanilla syrup.",
                "price": 4.2,
                "category": "Flavored Latte",
                "imageURL": "https://i.postimg.cc/wjmLqNT8/image.png",
                "customizations": [
                    "Size": ["Small", "Medium", "Large"],
                    "Milk": ["Whole", "Oat", "Soy"],
                    "Extras": ["Vanilla", "Caramel"]
                ]
            ],
            [
                "name": "Hazelnut Latte",
                "description": "Latte with hazelnut syrup.",
                "price": 4.3,
                "category": "Flavored Latte",
                "imageURL": "https://i.postimg.cc/02H02xYK/image.png",
                "customizations": [
                    "Size": ["Small", "Medium", "Large"],
                    "Milk": ["Whole", "Oat", "Soy"],
                    "Extras": ["Hazelnut", "Caramel"]
                ]
            ],
            [
                "name": "Honey Latte",
                "description": "Sweet latte with a touch of honey.",
                "price": 4.0,
                "category": "Flavored Latte",
                "imageURL": "https://i.postimg.cc/7hwm7VhT/image.png",
                "customizations": [
                    "Size": ["Small", "Medium", "Large"],
                    "Milk": ["Whole", "Oat", "Soy"]
                ]
            ],
            [
                "name": "Turmeric Latte",
                "description": "Warm milk with turmeric and spices.",
                "price": 4.3,
                "category": "Flavored Latte",
                "imageURL": "https://i.postimg.cc/1XQYBSCf/image.png",
                "customizations": [
                    "Size": ["Small", "Medium", "Large"],
                    "Milk": ["Whole", "Oat", "Soy"],
                    "Sweetness": ["Low", "Medium", "High"]
                ]
            ],

            // Dessert / Affogato
            [
                "name": "Affogato",
                "description": "Espresso poured over vanilla ice cream.",
                "price": 5.0,
                "category": "Dessert",
                "imageURL": "https://i.postimg.cc/8z4DrKCv/Affogato-0.jpg",
                "customizations": [
                    "Ice Cream": ["Vanilla", "Chocolate"],
                    "Espresso Shots": ["Single", "Double"]
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
