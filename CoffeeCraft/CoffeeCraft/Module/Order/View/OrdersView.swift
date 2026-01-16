//
//  OrdersView.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 10/23/25.
//
import SwiftUI

struct OrdersView: View {
    @StateObject private var orderVM = OrderViewModel()

    var body: some View {
        ZStack {
            // Adaptive background
            Color(uiColor: .systemGroupedBackground)
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
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView(showsIndicators: false) {
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
        .navigationBarTitle("My Orders", displayMode: .inline)
        .onAppear {
            orderVM.listenToUserOrders()
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
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(item.name)
                                .font(.subheadline)
                                .fontWeight(.medium)
                            Spacer()
                            Text("$\(item.price, specifier: "%.2f")")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                        }

                        // Selections
                        if let selections = item.selections, !selections.isEmpty {
                            VStack(alignment: .leading, spacing: 2) {
                                ForEach(selections.keys.sorted(), id: \.self) { key in
                                    if let value = selections[key] {
                                        HStack(spacing: 8) {
                                            Text("\(key):")
                                            Text(value)
                                        }
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                    }
                                }
                            }
                        }

                        // Extras
                        if let extras = item.extras, !extras.isEmpty {
                            HStack(spacing: 8) {
                                Text("Extras:")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                ForEach(extras, id: \.self) { extra in
                                    HStack(spacing: 0) {
                                        Text(extra)
                                            .font(.caption2)
                                            .foregroundColor(.secondary)
                                        if extra != extras.last {
                                            Text(",")
                                                .font(.caption2)
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                }
                            }
                        }
                        Divider()
                    }
                }
            }

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
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(uiColor: .tertiarySystemBackground))
        )
        .shadow(color: Color.primary.opacity(0.05), radius: 6, x: 0, y: 3)
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
