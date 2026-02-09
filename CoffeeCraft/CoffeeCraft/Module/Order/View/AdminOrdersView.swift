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
    @State private var selectedTab: Segment = .activeOrders
    @State private var navigationPath = NavigationPath()

    var body: some View {
        NavigationStack(path: $navigationPath) {
            ZStack {
                LinearGradient(colors: [ Color(hex: "FFECE0"), Color.white], startPoint: .topLeading, endPoint: .bottomTrailing)
                    .cornerRadius(41, corners: [.topLeft, .topRight])
                    .edgesIgnoringSafeArea(.bottom)

                VStack(spacing: 0) {
                    // Segmented Picker
                    CustomSegmentedControl(
                        selectedSegment: $selectedTab,
                        segments: [.activeOrders, .myOrders]
                    ) {}
                    .padding()

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
        }
    }
}

// MARK: - Active Orders Content
struct ActiveOrdersContent: View {
    @ObservedObject var vm: AdminOrdersViewModel
    @Binding var navigationPath: NavigationPath
    @State private var isPaginating = false
    @State private var pageNum = 1
    
    private var filteredOrders: [Order] {
        vm.allOrders
            .filter { $0.status != "Completed" }
            .sorted(by: { $0.timestamp > $1.timestamp })
    }
    
    var body: some View {
        Group {
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
                        ForEach(Array(filteredOrders.enumerated()), id: \.element.id) { i, order in
                            Button {
                                navigationPath.append(order)
                            } label: {
                                OrderCardView(order: order) {
                                    AnyView(
                                        HStack(spacing: 8) {
                                            Button("Start") {
                                                vm.updateOrderStatus(order: order, status: "InProgress") { success in
                                                    
                                                }
                                            }
                                            .disabled(order.status != "Pending")

                                            Button("Ready") {
                                                vm.updateOrderStatus(order: order, status: "Ready") { success in
                                                    
                                                }
                                            }
                                            .disabled(order.status != "InProgress")

                                            Button("Complete") {
                                                vm.updateOrderStatus(order: order, status: "Completed") { success in
                                                    if success {
                                                        ToastManager.shared.show(message: "Order Completed", type: .success)
                                                    }
                                                }
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
                            .onAppear {
                                // Pagination logic
                                if vm.allOrders.count < vm.totalAllOrdersCount {
                                    if !vm.allOrders.isEmpty {
                                        if order.id == vm.allOrders.last?.id, !isPaginating {
                                            isPaginating = true
                                            pageNum += 1
                                            Task {
                                                let timer = MinimumLoadingTime(0.5)
                                                try? await timer.waitIfNeeded()
                                                
                                                await MainActor.run {
                                                    vm.fetchAllOrders(pageNum: pageNum) { success in
                                                        isPaginating = false
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        
                        // Loading indicator
                        if isPaginating {
                            ProgressView()
                                .padding()
                        }
                    }
                    .padding(.vertical)
                }
                .refreshable {
                    pageNum = 1
                    await withCheckedContinuation { continuation in
                        vm.refreshAllOrders { _ in
                            continuation.resume()
                        }
                    }
                }
            }
        }
        .onAppear {
            vm.fetchAllOrders(pageNum: 1)
        }
    }
}

// MARK: - My Orders Content
struct MyOrdersContent: View {
    @ObservedObject var vm: AdminOrdersViewModel
    @Binding var navigationPath: NavigationPath
    @State private var isPaginating = false
    @State private var pageNum = 1
    
    var body: some View {
        Group {
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
                        ForEach(Array(vm.myOrders.enumerated()), id: \.element.id) { i, order in
                            Button {
                                navigationPath.append(order)
                            } label: {
                                OrderCardView(order: order)
                                    .padding(.horizontal)
                            }
                            .buttonStyle(.plain)
                            .onAppear {
                                // Pagination logic
                                if vm.myOrders.count < vm.totalMyOrdersCount {
                                    if !vm.myOrders.isEmpty {
                                        if order.id == vm.myOrders.last?.id, !isPaginating {
                                            isPaginating = true
                                            pageNum += 1
                                            Task {
                                                let timer = MinimumLoadingTime(0.5)
                                                try? await timer.waitIfNeeded()
                                                
                                                await MainActor.run {
                                                    vm.fetchMyOrders(pageNum: pageNum) { success in
                                                        isPaginating = false
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        
                        // Loading indicator
                        if isPaginating {
                            ProgressView()
                                .padding()
                        }
                    }
                    .padding(.vertical)
                }
                .refreshable {
                    pageNum = 1
                    await withCheckedContinuation { continuation in
                        vm.refreshMyOrders { _ in
                            continuation.resume()
                        }
                    }
                }
            }
        }
        .onAppear {
            vm.fetchMyOrders(pageNum: 1)
        }
    }
}
