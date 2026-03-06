//
//  CardError.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 1/26/26.
//
import SwiftUI

enum CardError: LocalizedError {
    case invalidCardNumber
    case cardAlreadyAdded
    case cannotRemoveOwnCard
    case noActiveCard
    case cardNotFound
    case userNotAuthenticated
    case notOwner
    case noAccess
    
    var errorDescription: String? {
        switch self {
        case .invalidCardNumber:
            return "Card number does not exist"
        case .cardAlreadyAdded:
            return "You have already added this card"
        case .cannotRemoveOwnCard:
            return "You cannot remove your own card"
        case .noActiveCard:
            return "No active card found"
        case .cardNotFound:
            return "Card not found"
        case .userNotAuthenticated:
            return "User not authenticated"
        case .notOwner:
            return "You are not the owner"
        case .noAccess: return "No access to this card"
        }
    }
}
