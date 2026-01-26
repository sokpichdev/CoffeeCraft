//
//  Card.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 1/26/26.
//

import Foundation
import FirebaseFirestore

// Global card (stored in cards/ collection)
struct Card: Identifiable, Codable {
    @DocumentID var id: String?
    let cardNumber: String
    let ownerId: String
    let ownerName: String
    let memberSince: String
    var points: Int
    let createdAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case cardNumber
        case ownerId
        case ownerName
        case memberSince
        case points
        case createdAt
    }
}

// User's card reference (stored in users/{userId}/cards/ subcollection)
struct UserCard: Identifiable, Codable {
    @DocumentID var id: String?
    let cardNumber: String
    let isOwner: Bool
    var isActive: Bool
    let addedAt: Date
    let memberName: String
    let memberSince: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case cardNumber
        case isOwner
        case isActive
        case addedAt
        case memberName
        case memberSince
    }
}
