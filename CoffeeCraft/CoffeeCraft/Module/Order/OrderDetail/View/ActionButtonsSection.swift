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
    var isUpdating: Bool = false
    var onUpdateStatus: ((String) -> Void)? = nil

    var body: some View {
        VStack(spacing: 12) {
            if isActive && order.status != "Completed" {
                // Admin action buttons for active orders
                if order.status == "Pending" {
                    CustomCoffeeButton(
                        title: isUpdating ? "Updating..." : "Start Preparing",
                        buttonImage: "flame.fill",
                        bgColors: [.orange]
                    ) {
                        onUpdateStatus?("InProgress")
                    }
                    .disabled(isUpdating)
                } else if order.status == "InProgress" {
                    CustomCoffeeButton(
                        title: isUpdating ? "Updating..." : "Mark as Ready",
                        buttonImage: "cup.and.saucer.fill",
                        bgColors: [.coffeeOliveGreen]
                    ) {
                        onUpdateStatus?("Ready")
                    }
                    .disabled(isUpdating)
                } else if order.status == "Ready" {
                    CustomCoffeeButton(
                        title: isUpdating ? "Updating..." : "Complete Order",
                        buttonImage: "checkmark.circle.fill",
                        bgColors: [.coffeeDarkBrown]
                    ) {
                        onUpdateStatus?("Completed")
                    }
                    .disabled(isUpdating)
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
