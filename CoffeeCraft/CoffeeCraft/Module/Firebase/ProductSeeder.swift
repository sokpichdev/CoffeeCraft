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
            // ☕️ Coffee
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
            [
                "name": "Espresso",
                "description": "Strong and bold espresso shot.",
                "price": 2.5,
                "category": "Coffee",
                "imageURL": "https://i.postimg.cc/W1FcYNpw/espresso-d93cf1fb-0d4d-4da2-877f-c8226560ea4a.webp",
                "customizations": [
                    "Size": ["Single": 0.0, "Double": 0.5],
                    "Extras": ["Sugar": 0.0, "Cinnamon": 0.2]
                ]
            ],

            // 🍵 Tea
            [
                "name": "Chai Latte",
                "description": "Spiced tea with steamed milk.",
                "price": 3.8,
                "category": "Tea",
                "imageURL": "https://i.postimg.cc/yxNBj0ry/image.png",
                "customizations": [
                    "Size": ["Small": 0.0, "Medium": 0.5, "Large": 1.0],
                    "Milk": ["Whole": 0.0, "Oat": 0.5, "Soy": 0.5],
                    "Sweetness": ["Low": 0.0, "Medium": 0.0, "High": 0.0]
                ]
            ],
            [
                "name": "Green Tea",
                "description": "Refreshing hot green tea.",
                "price": 2.2,
                "category": "Tea",
                "imageURL": "https://i.postimg.cc/Z5Wn4zHf/image.png",
                "customizations": [
                    "Size": ["Small": 0.0, "Medium": 0.5, "Large": 1.0],
                    "Sweetness": ["None": 0.0, "Low": 0.0, "Medium": 0.0, "High": 0.0]
                ]
            ],
            [
                "name": "Black Tea",
                "description": "Simple hot black tea.",
                "price": 2.0,
                "category": "Tea",
                "imageURL": "https://i.postimg.cc/Y07LCD09/image.png",
                "customizations": [
                    "Size": ["Small": 0.0, "Medium": 0.5, "Large": 1.0],
                    "Sweetness": ["None": 0.0, "Low": 0.0, "Medium": 0.0, "High": 0.0]
                ]
            ],

            // 🍵 Matcha
            [
                "name": "Matcha Latte",
                "description": "Creamy green tea latte with a hint of sweetness.",
                "price": 4.2,
                "category": "Matcha",
                "imageURL": "https://i.postimg.cc/44c14j81/image.png",
                "customizations": [
                    "Size": ["Small": 0.0, "Medium": 0.5, "Large": 1.0],
                    "Milk": ["Whole": 0.0, "Oat": 0.5, "Soy": 0.5],
                    "Extras": ["Honey": 0.3, "Vanilla": 0.3]
                ]
            ],

            // 🍫 Hot Chocolate
            [
                "name": "Hot Chocolate",
                "description": "Rich and creamy hot chocolate drink.",
                "price": 3.5,
                "category": "Hot Chocolate",
                "imageURL": "https://i.postimg.cc/4xg2TXsS/image.png",
                "customizations": [
                    "Size": ["Small": 0.0, "Medium": 0.5, "Large": 1.0],
                    "Extras": ["Whipped Cream": 0.5, "Marshmallows": 0.5, "Chocolate Drizzle": 0.5]
                ]
            ],

            // 🧊 Iced Coffee
            [
                "name": "Iced Americano",
                "description": "Strong espresso poured over cold water and ice cubes.",
                "price": 2.8,
                "category": "Iced Coffee",
                "imageURL": "https://i.postimg.cc/442WnzZ5/image.png",
                "customizations": [
                    "Size": ["Small": 0.0, "Medium": 0.5, "Large": 1.0],
                    "Extras": ["Lemon": 0.2, "Sugar Syrup": 0.3]
                ]
            ],
            [
                "name": "Iced Latte",
                "description": "Chilled espresso with milk over ice.",
                "price": 3.9,
                "category": "Iced Coffee",
                "imageURL": "https://i.postimg.cc/PrF0GgNK/image.png",
                "customizations": [
                    "Size": ["Small": 0.0, "Medium": 0.5, "Large": 1.0],
                    "Milk": ["Whole": 0.0, "Oat": 0.5, "Soy": 0.5, "Almond": 0.5],
                    "Extras": ["Caramel": 0.5, "Vanilla": 0.5]
                ]
            ],
            [
                "name": "Iced Mocha",
                "description": "Chilled chocolate espresso drink.",
                "price": 4.5,
                "category": "Iced Coffee",
                "imageURL": "https://i.postimg.cc/PJHTwB1z/image.png",
                "customizations": [
                    "Size": ["Small": 0.0, "Medium": 0.5, "Large": 1.0],
                    "Milk": ["Whole": 0.0, "Oat": 0.5, "Soy": 0.5],
                    "Extras": ["Whipped Cream": 0.5, "Chocolate Drizzle": 0.5]
                ]
            ],
            [
                "name": "Caramel Iced Coffee",
                "description": "Iced coffee with caramel syrup.",
                "price": 4.0,
                "category": "Iced Coffee",
                "imageURL": "https://i.postimg.cc/Mp9H8K1n/image.png",
                "customizations": [
                    "Size": ["Small": 0.0, "Medium": 0.5, "Large": 1.0],
                    "Milk": ["Whole": 0.0, "Oat": 0.5, "Soy": 0.5],
                    "Extras": ["Caramel": 0.5, "Vanilla": 0.5]
                ]
            ],

            // ☕️ Flavored Latte
            [
                "name": "Caramel Macchiato",
                "description": "Espresso with steamed milk and caramel drizzle.",
                "price": 4.5,
                "category": "Flavored Latte",
                "imageURL": "https://i.postimg.cc/G903q40J/image.png",
                "customizations": [
                    "Size": ["Small": 0.0, "Medium": 0.5, "Large": 1.0],
                    "Milk": ["Whole": 0.0, "Oat": 0.5, "Soy": 0.5],
                    "Extras": ["Vanilla": 0.5, "Caramel": 0.5]
                ]
            ],
            [
                "name": "Vanilla Latte",
                "description": "Classic latte with vanilla syrup.",
                "price": 4.2,
                "category": "Flavored Latte",
                "imageURL": "https://i.postimg.cc/wjmLqNT8/image.png",
                "customizations": [
                    "Size": ["Small": 0.0, "Medium": 0.5, "Large": 1.0],
                    "Milk": ["Whole": 0.0, "Oat": 0.5, "Soy": 0.5],
                    "Extras": ["Vanilla": 0.5, "Caramel": 0.5]
                ]
            ],
            [
                "name": "Hazelnut Latte",
                "description": "Latte with hazelnut syrup.",
                "price": 4.3,
                "category": "Flavored Latte",
                "imageURL": "https://i.postimg.cc/02H02xYK/image.png",
                "customizations": [
                    "Size": ["Small": 0.0, "Medium": 0.5, "Large": 1.0],
                    "Milk": ["Whole": 0.0, "Oat": 0.5, "Soy": 0.5],
                    "Extras": ["Hazelnut": 0.5, "Caramel": 0.5]
                ]
            ],
            [
                "name": "Honey Latte",
                "description": "Sweet latte with a touch of honey.",
                "price": 4.0,
                "category": "Flavored Latte",
                "imageURL": "https://i.postimg.cc/7hwm7VhT/image.png",
                "customizations": [
                    "Size": ["Small": 0.0, "Medium": 0.5, "Large": 1.0],
                    "Milk": ["Whole": 0.0, "Oat": 0.5, "Soy": 0.5]
                ]
            ],
            [
                "name": "Turmeric Latte",
                "description": "Warm milk with turmeric and spices.",
                "price": 4.3,
                "category": "Flavored Latte",
                "imageURL": "https://i.postimg.cc/1XQYBSCf/image.png",
                "customizations": [
                    "Size": ["Small": 0.0, "Medium": 0.5, "Large": 1.0],
                    "Milk": ["Whole": 0.0, "Oat": 0.5, "Soy": 0.5],
                    "Sweetness": ["Low": 0.0, "Medium": 0.0, "High": 0.0]
                ]
            ],

            // 🍨 Dessert
            [
                "name": "Affogato",
                "description": "Espresso poured over vanilla ice cream.",
                "price": 5.0,
                "category": "Dessert",
                "imageURL": "https://i.postimg.cc/8z4DrKCv/Affogato-0.jpg",
                "customizations": [
                    "Ice Cream": ["Vanilla": 0.0, "Chocolate": 0.5],
                    "Espresso Shots": ["Single": 0.0, "Double": 0.5]
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
