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
    var onReorder: (() -> Void)? = nil

    private var isCompleted: Bool {
        let s = order.status?.lowercased() ?? ""
        return s == "completed" || s == "done"
    }

    var body: some View {
        VStack(spacing: 12) {
            // Admin status action buttons (non-completed active orders only)
            if isActive && !isCompleted {
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

            // Reorder — only for completed orders, sits above Share as the primary CTA
            if isCompleted {
                CustomCoffeeButton(
                    title: "Reorder",
                    buttonImage: "arrow.clockwise",
                    bgColors: [.brown]
                ) {
                    onReorder?()
                }
            }

            // Share — always visible, secondary action
//            CustomCoffeeButton(
//                title: "Share Order Details",
//                buttonImage: "square.and.arrow.up",
//                foregroundColor: .coffeeCream,
//                bgColors: [Color(.secondarySystemGroupedBackground)]
//            ) {}
        }
    }
}
