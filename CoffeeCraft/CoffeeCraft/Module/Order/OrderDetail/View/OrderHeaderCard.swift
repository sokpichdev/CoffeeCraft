//
//  OrderHeaderCard.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 2/24/26.
//
import SwiftUI

struct OrderHeaderCard: View {
    let order: Order
    let userName: String
    let isLoadingUser: Bool
    
    var body: some View {
        VStack(spacing: 20) {
            // Top Row: Order ID & Status Badge
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Order #\(order.orderId ?? 0)")
                        .font(.title2).fontWeight(.bold)
                        .foregroundColor(.textPrimary)
                    if let date = order.timestamp {
                        Text(date.formatted(date: .long, time: .shortened))
                            .font(.subheadline)
                            .foregroundColor(.textSecondary)
                    }
                }
                Spacer()
                StatusBadge(orderStatus: order.orderStatus)
            }
            
            Divider()
                .background(Color.secondary.opacity(0.2))
            
            // Branch row — Phase 4 (only shown when order has a branch tag)
            if let branchName = order.branchName, !branchName.isEmpty {
                HStack(spacing: 10) {
                    Image(systemName: "mappin.circle.fill")
                        .font(.system(size: 18))
                        .foregroundColor(.accentPrimary)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Branch")
                            .font(.caption)
                            .foregroundColor(.textSecondary)
                            .textCase(.uppercase)
                            .tracking(0.5)
                        Text(branchName)
                            .font(.callout).fontWeight(.semibold)
                            .foregroundColor(.textPrimary)
                    }
                    Spacer()
                }

                Divider()
                    .background(Color.secondary.opacity(0.2))
            }

            // User Info Section
            HStack(spacing: 12) {
                // Avatar placeholder
                ZStack {
                    Circle()
                        .fill(LinearGradient(
                            colors: [.accentPrimary.opacity(0.8), .accentPrimary],
                            startPoint: .topLeading, endPoint: .bottomTrailing
                        ))
                        .frame(width: 48, height: 48)
                    Text(String(userName.prefix(1).uppercased()))
                        .font(.title3).fontWeight(.bold)
                        .foregroundColor(.textPrimary).colorScheme(.dark)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Ordered by")
                        .font(.caption)
                        .foregroundColor(.textSecondary)
                        .textCase(.uppercase)
                        .tracking(0.5)
                    
                    if isLoadingUser {
                        HStack(spacing: 6) {
                            ProgressView()
                                .scaleEffect(0.8)
                            Text("Loading...")
                                .font(.callout).fontWeight(.semibold)
                                .foregroundColor(.textSecondary)
                        }
                    } else {
                        Text(userName)
                            .font(.callout).fontWeight(.semibold)
                            .foregroundColor(.textPrimary)
                            .lineLimit(1)
                    }
                }
                
                Spacer()
                
                // User ID badge for admin reference
                if let userId = order.userId {
                    VStack {
                        Text("#\(String(describing: userId.prefix(6)))")
                            .font(.system(size: 11, weight: .medium))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.secondary.opacity(0.1))
                            .foregroundColor(.textSecondary)
                            .cornerRadius(6)
                        Spacer()
                    }
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color(.secondarySystemGroupedBackground))
                .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 4)
        )
    }
}

// MARK: - StatusBadge
// Accepts OrderStatus directly — no local switch, no string parsing.

struct StatusBadge: View {
    let orderStatus: OrderStatus

    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(orderStatus.color.opacity(0.25))
                .frame(width: 8, height: 8)
            Text(orderStatus.displayLabel)
                .font(.footnote).fontWeight(.semibold)
                .frame(height: 15)
        }
        .padding(.horizontal, 14).padding(.vertical, 8)
        .background(orderStatus.color.opacity(0.15))
        .foregroundColor(orderStatus.color)
        .cornerRadius(20)
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(orderStatus.color.opacity(0.2), lineWidth: 1))
    }
}
