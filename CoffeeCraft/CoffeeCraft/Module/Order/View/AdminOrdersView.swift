//
//  AdminOrdersView.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 10/23/25.
//
import SwiftUI
import FirebaseAuth

struct AdminOrdersView: View {
    @StateObject var vm = AdminOrdersViewModel()
    @State private var selectedTab: AdminOrderTab = .activeOrders
    @State private var navigationPath = NavigationPath()

    var body: some View {
        NavigationStack(path: $navigationPath) {
            ZStack {
                Color(uiColor: .systemGroupedBackground)
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    // Segmented Picker
                    Picker("Order Type", selection: $selectedTab) {
                        ForEach(AdminOrderTab.allCases, id: \.self) { tab in
                            Text(tab.rawValue).tag(tab)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding()
                    .background(Color(uiColor: .systemGroupedBackground))

                    // Content based on selected tab
                    if selectedTab == .activeOrders {
                        ActiveOrdersContent(vm: vm, navigationPath: $navigationPath)
                    } else {
                        MyOrdersContent(vm: vm, navigationPath: $navigationPath)
                    }
                }
            }
            .navigationDestination(for: Order.self) { order in
                OrderDetailView(order: order)
            }
            .customNavigationBar("Orders")
            .task {
                vm.fetchAllOrders()
                vm.fetchMyOrders()
            }
        }
    }
}

// MARK: - Active Orders Content
struct ActiveOrdersContent: View {
    @ObservedObject var vm: AdminOrdersViewModel
    @Binding var navigationPath: NavigationPath
    
    private var filteredOrders: [Order] {
        vm.allOrders
            .filter { $0.status != "Completed" }
            .sorted(by: { $0.timestamp > $1.timestamp })
    }
    
    var body: some View {
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
            ScrollView(showsIndicators: false) {
                LazyVStack(spacing: 16) {
                    ForEach(filteredOrders) { order in
                        Button {
                            navigationPath.append(order)
                        } label: {
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
                        .buttonStyle(.plain)
                    }
                }
                .padding(.vertical)
            }
        }
    }
}

// MARK: - My Orders Content
struct MyOrdersContent: View {
    @ObservedObject var vm: AdminOrdersViewModel
    @Binding var navigationPath: NavigationPath
    
    var body: some View {
        if vm.myOrders.isEmpty {
            VStack(spacing: 16) {
                Image(systemName: "cup.and.saucer.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.brown.opacity(0.7))
                Text("No Orders Yet")
                    .font(.title3)
                    .fontWeight(.semibold)
                Text("Your coffee orders will appear here.")
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            ScrollView(showsIndicators: false) {
                LazyVStack(spacing: 16) {
                    ForEach(vm.myOrders) { order in
                        Button {
                            navigationPath.append(order)
                        } label: {
                            OrderCardView(order: order)
                                .padding(.horizontal)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.vertical)
            }
        }
    }
}
