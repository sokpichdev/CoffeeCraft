//
//  ActionButtonsSection.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 2/24/26.
//
import SwiftUI

struct ActionButtonsSection: View {
    let order: Order
    let isActive: Bool
    
    var body: some View {
        VStack(spacing: 12) {
            if isActive && order.status != "Completed" {
                // Admin action buttons for active orders
                if order.status == "Pending" {
                    CustomCoffeeButton(title: "Start Preparing", buttonImage: "flame.fill", bgColors: [.orange]) {}
                } else if order.status == "InProgress" {
                    CustomCoffeeButton(title: "Mark as Ready", buttonImage: "cup.and.saucer.fill", bgColors: [.coffeeOliveGreen]) {}
                } else if order.status == "Ready" {
                    CustomCoffeeButton(title: "Complete Order", buttonImage: "checkmark.circle.fill", bgColors: [.coffeeDarkBrown]) {}
                }
            }
            
            CustomCoffeeButton(
                title: "Share Order Details",
                buttonImage: "square.and.arrow.up",
                foregroundColor: .coffeeCream,
                bgColors: [Color(.secondarySystemGroupedBackground)]
            ) {}
        }
    }
}
