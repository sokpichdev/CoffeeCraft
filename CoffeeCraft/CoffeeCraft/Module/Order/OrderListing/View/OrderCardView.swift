//
//  OrderCardView.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 25/02/2026.
//
import SwiftUI

struct OrderCardView: View {
    let order: Order
    var adminActions: (() -> AnyView)? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(order.timestamp.formatted(date: .abbreviated, time: .shortened))
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .frame(height: 12)
                    Text("Order #\(order.orderId)")
                        .font(.footnote)
                        .foregroundColor(.gray)
                        .frame(height: 13)
                }

                Spacer()

                Text(order.status)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .padding(.vertical, 4)
                    .padding(.horizontal, 10)
                    .background(statusColor(order.status).opacity(0.15))
                    .foregroundColor(statusColor(order.status))
                    .clipShape(Capsule())
            }

            Divider()

            // Items
            VStack(alignment: .leading, spacing: 8) {
                ForEach(order.items) { item in
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(item.name)
                                .font(.subheadline)
                                .fontWeight(.medium)
                            Spacer()
//                            Text("$\(item.price, specifier: "%.2f")")
//                                .font(.subheadline)
//                                .fontWeight(.semibold)
//                                .foregroundColor(.secondary)
                        }
                        .frame(height: 15)
                        Divider()
                    }
                }
            }

            // Footer
            HStack {
                Text("Total:")
                    .font(.subheadline)
                    .fontWeight(.medium)
                Spacer()
                Text("$\(order.totalPrice, specifier: "%.2f")")
                    .fontWeight(.bold)
            }
            .frame(height: 15)
            .padding(.top, 4)

            // Admin actions (if provided)
            if let adminActions = adminActions {
                Divider()
                adminActions()
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color(uiColor: .tertiarySystemBackground))
        )
        .shadow(color: Color.primary.opacity(0.05), radius: 6, x: 0, y: 3)
    }

    func statusColor(_ status: String) -> Color {
        switch status {
        case "Pending": return .orange
        case "In Progress", "InProgress": return .blue
        case "Ready": return .coffeeOliveGreen
        case "Done", "Completed": return .brown
        default: return .brown
        }
    }
}
