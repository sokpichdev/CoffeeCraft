//
//  Card.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 1/26/26.
//

import FirebaseFirestore
import Foundation
import SwiftUI

struct LoyaltyCard: Identifiable, Codable {
    @DocumentID var id: String?
    let cardNumber: String
    let ownerId: String
    let ownerName: String
    let memberSince: String
    var points: Int
    let createdAt: Date
    var sharedWith: [String] = []
    
    // Computed properties (need static vars for current context)
    static var currentUserId: String = ""
    static var currentActiveCardNumber: String = ""

    var displayName: String {
        ownerName + (isOwnedByCurrentUser ? " (Mine)" : "")
    }
    
    var isOwnedByCurrentUser: Bool {
        return ownerId == LoyaltyCard.currentUserId
    }
    
    var hasAccessForCurrentUser: Bool {
        isOwnedByCurrentUser || sharedWith.contains(LoyaltyCard.currentUserId)
    }
    // Computed: Who can use this card
    var authorizedUsers: [String] {
        var users = sharedWith
        users.append(ownerId)  // Owner always has access
        return users
    }
    
    var isActiveForCurrentUser: Bool {
        cardNumber == LoyaltyCard.currentActiveCardNumber && hasAccessForCurrentUser
    }
    
    enum CodingKeys: String, CodingKey {
        case id, cardNumber, ownerId, ownerName, memberSince, points, createdAt, sharedWith
    }
}
