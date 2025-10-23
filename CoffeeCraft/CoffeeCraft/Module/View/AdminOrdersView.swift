//
//  AdminOrdersView.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 10/23/25.
//
import SwiftUI

struct AdminOrdersView: View {
    @StateObject var vm = AdminOrdersViewModel()

    var body: some View {
            List {
                ForEach(vm.orders) { order in
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text("Order: \(order.id?.prefix(6) ?? "")")
                                .font(.headline)
                            Spacer()
                            Text(order.status.capitalized)
                                .foregroundColor(color(for: order.status))
                                .fontWeight(.semibold)
                        }

                        ForEach(order.items) { item in
                            HStack {
                                Text("\(item.name) \(item.size ?? "")")
                                Spacer()
                                Text("$\(item.price, specifier: "%.2f")")
                            }
                            .font(.subheadline)
                        }

                        Text("Total: $\(order.totalPrice, specifier: "%.2f")")
                            .fontWeight(.semibold)

                        HStack {
                            Button("Start") {
                                vm.updateOrderStatus(order: order, status: "InProgress")
                            }
                            .disabled(order.status != "Pending")

                            Button("Ready") {
                                vm.updateOrderStatus(order: order, status: "Ready")
                            }
                            .disabled(order.status != "InProgress")

                            Button("Complete") {
                                vm.updateOrderStatus(order: order, status: "Completed")
                            }
                            .disabled(order.status != "Ready")
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.brown)
                    }
                    .padding(8)
                    .background(Color(.systemBackground))
                    .cornerRadius(10)
                    .shadow(radius: 2)
                }
            }
            .navigationTitle("Orders")
    }

    func color(for status: String) -> Color {
        switch status {
        case "Pending": return .orange
        case "InProgress": return .blue
        case "Ready": return .green
        case "Completed": return .gray
        default: return .black
        }
    }
}
