//
//  OrdersView.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 10/23/25.
//
import SwiftUI

import SwiftUI

struct OrdersView: View {
    @StateObject private var orderVM = OrderViewModel()

    var body: some View {
        ZStack {
            // Full background color
            Color(.systemGroupedBackground)
                .ignoresSafeArea()
            
            if orderVM.orders.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "cup.and.saucer.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.brown.opacity(0.7))
                    Text("No Orders Yet")
                        .font(.title3)
                        .fontWeight(.semibold)
                    Text("Your recent coffee orders will appear here.")
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(orderVM.orders) { order in
                            OrderCardView(order: order)
                                .padding(.horizontal)
                        }
                    }
                    .padding(.vertical)
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .navigationTitle("My Orders")
        .task {
            await orderVM.fetchUserOrders()
        }
    }
}

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
                    Text("Order #\(order.id?.prefix(6) ?? "x")")
                        .font(.footnote)
                        .foregroundColor(.gray)
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
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(item.name)
                                .font(.subheadline)
                                .fontWeight(.medium)
                            if let size = item.size, let milk = item.milk {
                                Text("\(size) • \(milk)")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                        Spacer()
                        Text("$\(item.price, specifier: "%.2f")")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                    }
                }
            }

            Divider()

            // Footer
            HStack {
                Text("Total:")
                    .fontWeight(.medium)
                Spacer()
                Text("$\(order.totalPrice, specifier: "%.2f")")
                    .fontWeight(.bold)
            }
            .padding(.top, 4)

            // Admin actions (if provided)
            if let adminActions = adminActions {
                Divider()
                adminActions()
            }
        }
        .padding()
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 3)
    }

    func statusColor(_ status: String) -> Color {
        switch status {
        case "Pending": return .orange
        case "In Progress", "InProgress": return .blue
        case "Ready": return .green
        case "Done", "Completed": return .gray
        default: return .gray
        }
    }
}
