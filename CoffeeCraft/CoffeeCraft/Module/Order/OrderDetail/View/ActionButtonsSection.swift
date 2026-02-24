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
                    ActionButton(
                        title: "Start Preparing",
                        icon: "flame.fill",
                        color: .orange,
                        action: { /* Admin action */ }
                    )
                } else if order.status == "InProgress" {
                    ActionButton(
                        title: "Mark as Ready",
                        icon: "cup.and.saucer.fill",
                        color: .green,
                        action: { /* Admin action */ }
                    )
                } else if order.status == "Ready" {
                    ActionButton(
                        title: "Complete Order",
                        icon: "checkmark.circle.fill",
                        color: .coffeeDarkBrown,
                        action: { /* Admin action */ }
                    )
                }
            }
            
            // Share/Receipt button for all users
            Button {
                // Share order details
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "square.and.arrow.up")
                    Text("Share Order Details")
                }
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
                )
            }
        }
    }
}

struct ActionButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                Text(title)
            }
            .font(.system(size: 17, weight: .bold))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(
                LinearGradient(
                    colors: [color, color.opacity(0.8)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(16)
            .shadow(color: color.opacity(0.3), radius: 8, x: 0, y: 4)
        }
    }
}

