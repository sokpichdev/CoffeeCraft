//
//  FirebaseKeys.swift
//  CoffeeCraft
//
//  Centralised Firestore collection names and field keys.
//
//  Usage:
//      db.collection(Firebase.orders.collection)
//        .whereField(Firebase.orders.userId, isEqualTo: uid)
//        .order(by: Firebase.orders.timestamp)
//
//  Every top-level enum represents one Firestore collection.
//  Nested enums represent subcollections of that collection.
//  `collection` is always the raw Firestore path segment for that level.
//

enum Firebase {

    // MARK: - orders

    enum Orders {
        static let collection = "orders"
        static let orderId = "orderId"
        static let userId               = "userId"
        static let timestamp            = "timestamp"
        static let totalPrice           = "totalPrice"
        static let status               = "status"
        static let paymentMethod        = "paymentMethod"
        static let productIds           = "productIds"
        static let items                = "items"
        static let walletAmountPaid     = "walletAmountPaid"
        static let branchId             = "branchId"
        static let branchName           = "branchName"
        static let deliveryType         = "deliveryType"
        static let deliveryAddress      = "deliveryAddress"
        static let deliveryDestinationLat = "deliveryDestinationLat"
        static let deliveryDestinationLng = "deliveryDestinationLng"
        static let deliveryBranchLat    = "deliveryBranchLat"
        static let deliveryBranchLng    = "deliveryBranchLng"
        static let customerName         = "customerName"
        static let completedAt          = "completedAt"

        // MARK: Sub-document — orders/{id}/items[]
        enum ItemField {
            static let productId   = "productId"
            static let name        = "name"
            static let price       = "price"
            static let imageURL    = "imageURL"
            static let quantity    = "quantity"
            static let selections  = "selections"
            static let extras      = "extras"
        }
    }

    // MARK: - users

    enum Users {
        static let collection       = "users"
        static let role             = "role"
        static let name             = "name"
        static let email            = "email"
        static let userName         = "userName"
        static let phoneNumber      = "phoneNumber"
        static let gender           = "gender"
        static let dateOfBirth      = "dateOfBirth"
        static let city             = "city"
        static let fcmTokens        = "fcmTokens"
        static let loyaltyPoints    = "loyaltyPoints"
        static let activeCard       = "activeCard"
        static let accessibleCards  = "accessibleCards"
        static let createdAt        = "createdAt"
        static let updatedAt        = "updatedAt"

        // MARK: Nested fields — users/{uid}.fcmTokens[]
        enum FcmTokenField {
            static let token     = "token"
            static let deviceId  = "deviceId"
            static let platform  = "platform"
            static let updatedAt = "updatedAt"
        }

        // MARK: Subcollection — users/{uid}/notifications
        enum Notifications {
            static let collection   = "notifications"
            static let isRead       = "isRead"
            static let createdAt    = "createdAt"
        }

        // MARK: Subcollection — users/{uid}/favorites
        enum Favorites {
            static let collection        = "favorites"
            static let productId         = "productId"
            static let productName       = "productName"
            static let imageURL          = "imageURL"
            static let basePrice         = "basePrice"
            static let customizations    = "customizations"
            static let customizationHash = "customizationHash"
            static let createdAt         = "createdAt"
        }

        // MARK: Subcollection — users/{uid}/savedLocations
        enum SavedLocations {
            static let collection = "savedLocations"
            static let isDefault  = "isDefault"
            static let createdAt  = "createdAt"
        }
    }

    // MARK: - products

    enum Products {
        static let collection         = "products"
        static let name               = "name"
        static let description        = "description"
        static let price              = "price"
        static let imageURL           = "imageURL"
        static let category           = "category"
        static let available          = "available"
        static let customizations     = "customizations"
        static let avgRating          = "avgRating"
        static let ratingCount        = "ratingCount"
        static let ratingDistribution = "ratingDistribution"

        // MARK: Subcollection — products/{id}/reviews
        enum Reviews {
            static let collection   = "reviews"
            static let rating       = "rating"
            static let body         = "body"
            static let isHidden     = "isHidden"
            static let helpfulCount = "helpfulCount"
            static let helpfulBy    = "helpfulBy"
            static let createdAt    = "createdAt"
            static let userId       = "userId"
            static let customerName = "customerName"
            static let userName     = "userName"
            static let reviewId     = "reviewId"
        }

        // MARK: Subcollection — products/{id}/ratings
        enum Ratings {
            static let collection = "ratings"
            static let score      = "score"
            static let orderId    = "orderId"
            static let reviewId   = "reviewId"
            static let updatedAt  = "updatedAt"
            static let createdAt  = "createdAt"
        }
    }

    // MARK: - wallets

    enum Wallets {
        static let collection  = "wallets"
        static let balance     = "balance"
        static let currency    = "currency"
        static let totalSpent  = "totalSpent"
        static let totalTopUp  = "totalTopUp"
        static let userId      = "userId"
        static let createdAt   = "createdAt"
        static let updatedAt   = "updatedAt"
    }

    // MARK: - wallet_transactions

    enum WalletTransactions {
        static let collection    = "wallet_transactions"
        static let userId        = "userId"
        static let type          = "type"
        static let amount        = "amount"
        static let balanceBefore = "balanceBefore"
        static let balanceAfter  = "balanceAfter"
        static let description   = "description"
        static let timestamp     = "timestamp"
        static let referenceId   = "referenceId"
        static let orderId       = "orderId"
        static let createdAt     = "createdAt"
    }

    // MARK: - loyalty_cards

    enum LoyaltyCards {
        static let collection      = "loyalty_cards"
        static let cardNumber      = "cardNumber"
        static let ownerId         = "ownerId"
        static let ownerName       = "ownerName"
        static let memberSince     = "memberSince"
        static let sharedWith      = "sharedWith"
        static let points          = "points"
        static let accessibleCards = "accessibleCards"
        static let activeCard      = "activeCard"
        static let createdDate     = "createdDate"
        static let createdAt       = "createdAt"
    }

    // MARK: - counters

    enum Counters {
        static let collection = "counters"
        static let current    = "current"
    }

    // MARK: - deliveries

    enum Deliveries {
        static let collection           = "deliveries"
        static let orderId              = "orderId"
        static let userId               = "userId"
        static let branchId             = "branchId"
        static let status               = "status"
        static let riderName            = "riderName"
        static let riderPhone           = "riderPhone"
        static let riderLatitude        = "riderLatitude"
        static let riderLongitude       = "riderLongitude"
        static let branchLatitude       = "branchLatitude"
        static let branchLongitude      = "branchLongitude"
        static let destinationLatitude  = "destinationLatitude"
        static let destinationLongitude = "destinationLongitude"
        static let estimatedArrival     = "estimatedArrival"
        static let simulationStartedAt  = "simulationStartedAt"
        static let completedAt          = "completedAt"
        static let updatedAt            = "updatedAt"
    }

    // MARK: - branches

    enum Branches {
        static let collection = "branches"
    }

    // MARK: - carts

    enum Carts {
        static let collection = "carts"
        static let items      = "items"
    }

    // MARK: - customizations

    enum Customizations {
        static let collection = "customizations"
        static let name       = "name"
        static let options    = "options"
    }

    // MARK: - announcements

    enum Announcements {
        static let collection = "announcements"
        static let createdDate = "createdDate"
    }

    // MARK: - notifications (top-level path used for the push queue)
    // Path: notifications/{userId}/queue
    // Note: the user-facing inbox lives at users/{uid}/notifications — see Firebase.users.notifications

    enum NotificationQueue {
        static let collection = "notifications"

        enum Queue {
            static let collection = "queue"
        }
    }
}
