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
        ZStack {
            Color(.systemGroupedBackground)
                .ignoresSafeArea()

            if filteredOrders.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "cup.and.saucer.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.brown.opacity(0.8))
                    Text("No Active Orders")
                        .font(.title3)
                        .fontWeight(.semibold)
                    Text("All orders have been completed. New ones will appear here.")
                        .multilineTextAlignment(.center)
                        .foregroundColor(.gray)
                        .padding(.horizontal)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(filteredOrders) { order in
                            OrderCardView(order: order) {
                                AnyView(
                                    HStack(spacing: 8) {
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
                                )
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding(.vertical)
                }
            }
        }
        .navigationTitle("Active Orders")
        .task {
            vm.fetchOrders()
        }
    }

    private var filteredOrders: [Order] {
        vm.orders
            .filter { $0.status != "Completed" }
            .sorted(by: { $0.timestamp > $1.timestamp })
    }
}
