//
//  Card.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 1/26/26.
//

import Foundation
import FirebaseFirestore
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
    static var activeCardNumbers: Set<String> = []
    
    var displayName: String {
        ownerName + (isOwnedByCurrentUser ? " (Mine)" : "")
    }
    
    var isOwnedByCurrentUser: Bool {
        ownerId == LoyaltyCard.currentUserId
    }
    
    var hasAccessForCurrentUser: Bool {
        isOwnedByCurrentUser || sharedWith.contains(LoyaltyCard.currentUserId)
    }
    
    var isActive: Bool {
        LoyaltyCard.activeCardNumbers.contains(cardNumber)
    }
    
    enum CodingKeys: String, CodingKey {
        case id, cardNumber, ownerId, ownerName, memberSince, points, createdAt, sharedWith
    }
}
