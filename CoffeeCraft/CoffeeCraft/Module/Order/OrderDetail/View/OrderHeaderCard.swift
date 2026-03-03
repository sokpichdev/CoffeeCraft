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
                        .foregroundColor(.primary)
                    if let date = order.timestamp {
                        Text(date.formatted(date: .long, time: .shortened))
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                StatusBadge(status: order.status ?? "")
            }
            
            Divider()
                .background(Color.secondary.opacity(0.2))
            
            // User Info Section
            HStack(spacing: 12) {
                // Avatar placeholder
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.brown.opacity(0.8), .brown],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 48, height: 48)
                    
                    Text(String(userName.prefix(1).uppercased()))
                        .font(.title3).fontWeight(.bold)
                        .foregroundColor(.white)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Ordered by")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .textCase(.uppercase)
                        .tracking(0.5)
                    
                    if isLoadingUser {
                        HStack(spacing: 6) {
                            ProgressView()
                                .scaleEffect(0.8)
                            Text("Loading...")
                                .font(.callout).fontWeight(.semibold)
                                .foregroundColor(.secondary)
                        }
                    } else {
                        Text(userName)
                            .font(.callout).fontWeight(.semibold)
                            .foregroundColor(.primary)
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
                            .foregroundColor(.secondary)
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

struct StatusBadge: View {
    let status: String
    
    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(statusColor(status).opacity(0.2))
                .frame(width: 8, height: 8)
            
            Text(status == "InProgress" ? "In Progress" : status)
                .font(.footnote).fontWeight(.semibold)
                .frame(height: 15)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(statusColor(status).opacity(0.15))
        .foregroundColor(statusColor(status))
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(statusColor(status).opacity(0.2), lineWidth: 1)
        )
    }
    
    func statusColor(_ status: String) -> Color {
        switch status {
        case "Pending": return .orange
        case "In Progress", "InProgress": return .blue
        case "Ready": return .coffeeOliveGreen
        case "Done", "Completed": return .brown
        case "Cancelled": return .errorRed   // Phase 5
        default: return .brown
        }
    }
}
