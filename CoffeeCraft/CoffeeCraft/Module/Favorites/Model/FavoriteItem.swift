//
//  FavoriteItem.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 1/16/26.
//
import SwiftUI

struct FavoriteItem: Identifiable {
    let id: String
    let productId: String
    let productName: String
    let imageURL: String
    let basePrice: Double
    let customizations: [String: String]
    let customizationHash: String
}
