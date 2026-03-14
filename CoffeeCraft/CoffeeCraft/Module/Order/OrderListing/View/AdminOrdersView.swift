import FirebaseAuth
//
//  AdminOrdersView.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 10/23/25.
//
import SwiftUI

struct AdminOrdersView: View {
    @StateObject var vm = AdminOrdersViewModel()
    @EnvironmentObject var cartManager: CartManager
    @State private var selectedTab: Segment = .activeOrders
    @State private var showWaitTimeEditor = false
    @State private var waitTimeBranch: Branch?

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.accentPrimary.opacity(0.75), Color.accentPrimary.opacity(0.5), Color(.systemBackground)],
                startPoint: .top, endPoint: .bottom
            )
            .cornerRadius(36, corners: [.topLeft, .topRight])
            .edgesIgnoringSafeArea(.bottom)

            VStack(spacing: 0) {
                CustomSegmentedControl(
                    selectedSegment: $selectedTab,
                    segments: [.activeOrders, .myOrders]
                ) {}
                .padding()

                if selectedTab == .activeOrders {
                    ActiveOrdersContent(vm: vm)
                        .environmentObject(cartManager)
                        .padding(.horizontal)
                } else {
                    MyOrdersContent(vm: vm)
                        .environmentObject(cartManager)
                        .padding(.horizontal)
                }
            }
        }
        .customNavigationBar("Orders") {
            // Phase 6 — Wait time editor for any branch
            ToolBarButton(placement: .topBarTrailing, buttonType: .icon("clock.badge.fill")) {
                // Default to first branch; in a real build, pick from a list
                waitTimeBranch = MockBranchData.all.first
                showWaitTimeEditor = true
            }
        }
        .background(Color.bgSecondary)
        .sheet(isPresented: $showWaitTimeEditor) {
            if let branch = waitTimeBranch {
                BranchWaitTimeEditor(branch: branch)
                    .presentationDetents([.medium])
                    .presentationCornerRadius(24)
            }
        }
    }
}

// MARK: - Active Orders Content
struct ActiveOrdersContent: View {
    @ObservedObject var vm: AdminOrdersViewModel
    @EnvironmentObject var cartManager: CartManager
    @State private var isPaginating = false
    @State private var selectedOrder: Order?

    private var filteredOrders: [Order] {
        vm.allOrders
            .filter { $0.status != "Completed" }
            .sorted(by: {
                ($0.timestamp ?? .distantPast) > ($1.timestamp ?? .distantPast)
            })
    }

    var body: some View {
        Group {
            if vm.isLoadingAllOrders {
                ScrollView {
                    OrderListShimmerView(showAdminActions: true)
                }
                .clipShape(RoundedRectangle(cornerRadius: 24))
            } else if filteredOrders.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "cup.and.saucer.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.accentPrimary.opacity(0.8))
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
                CustomRefreshScrollView({
                    LazyVStack(spacing: 8) {
                        ForEach(Array(filteredOrders.enumerated()), id: \.element.id) { _, order in
                            OrderCardView(
                                order: order,
                                adminActions: {
                                    AnyView(
                                        HStack(spacing: 8) {
                                            Button("Start") {
                                                Task {
                                                    _ = await vm.updateOrderStatus(order: order, status: "InProgress")
                                                }
                                            }
                                            .disabled(order.status != "Pending")
                                            
                                            Button("Ready") {
                                                Task {
                                                    _ = await vm.updateOrderStatus(order: order, status: "Ready")
                                                }
                                            }
                                            .disabled(order.status != "InProgress")
                                            
                                            Button("Complete") {
                                                Task {
                                                    let success = await vm.updateOrderStatus(order: order,
                                                                                             status: "Completed")
                                                    if success {
                                                        ToastManager.shared.show(message: "Order Completed",
                                                                                 type: .success)
                                                    }
                                                }
                                            }
                                            .disabled(order.status != "Ready")
                                        }
                                            .buttonStyle(.borderedProminent)
                                            .tint(.accentPrimary)
                                    )},
                                onNavigate: {
                                    selectedOrder = order
                                }
                            )
                            .onAppear {
                                guard vm.hasMoreAllOrders else { return }
                                guard order.id == vm.allOrders.last?.id else { return }
                                guard !isPaginating else { return }

                                isPaginating = true
                                vm.allOrdersPage += 1

                                Task {
                                    let timer = MinimumLoadingTime(0.5)
                                    try? await timer.waitIfNeeded()

                                    await vm.fetchAllOrders(pageNum: vm.allOrdersPage)
                                    isPaginating = false
                                }
                            }
                        }

                        if isPaginating {
                            ProgressView()
                                .padding()
                        }
                    }
                    .padding(.bottom)
                }, onRefresh: {
                    vm.allOrdersPage = 1
                    await vm.refreshAllOrders()
                })
                .padding(.bottom)
                .clipShape(RoundedRectangle(cornerRadius: 24))
            }
        }
        .task {
            await vm.fetchAllOrders(pageNum: 1)
        }
        .navigationDestination(item: $selectedOrder) { order in
            OrderDetailView(order: order, isActive: true)
                .environmentObject(cartManager)
        }
    }
}

// MARK: - My Orders Content
struct MyOrdersContent: View {
    @ObservedObject var vm: AdminOrdersViewModel
    @EnvironmentObject var cartManager: CartManager
    @State private var isPaginating = false
    @State private var selectedOrder: Order?

    var body: some View {
        Group {
            if vm.isLoadingMyOrders {
                ScrollView {
                    OrderListShimmerView(showAdminActions: false)
                }
                .clipShape(RoundedRectangle(cornerRadius: 24))
            } else if vm.myOrders.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "cup.and.saucer.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.accentPrimary.opacity(0.7))
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
                CustomRefreshScrollView({
                    LazyVStack(spacing: 8) {
                        ForEach(Array(vm.myOrders.enumerated()), id: \.element.id) { _, order in
                            OrderCardView(
                                order: order,
                                onNavigate: {
                                    selectedOrder = order
                                }, onReorder: {
                                    handleReorder(for: order)
                                }
                            )
                            .onAppear {
                                guard vm.hasMoreMyOrders else { return }
                                guard order.id == vm.myOrders.last?.id else { return }
                                guard !isPaginating else { return }
                                
                                isPaginating = true
                                vm.myOrdersPage += 1
                                
                                Task {
                                    let timer = MinimumLoadingTime(0.5)
                                    try? await timer.waitIfNeeded()
                                    
                                    await vm.fetchMyOrders(pageNum: vm.myOrdersPage)
                                    isPaginating = false
                                }
                            }
                        }

                        if isPaginating {
                            ProgressView()
                                .padding()
                        }
                    }
                    .padding(.bottom)
                }, onRefresh: {
                    vm.myOrdersPage = 1
                    await vm.refreshMyOrders()
                })
                .padding(.bottom)
                .clipShape(RoundedRectangle(cornerRadius: 24))
            }
        }
        .task {
            await vm.fetchMyOrders(pageNum: 1)
        }
        .navigationDestination(item: $selectedOrder) { order in
            OrderDetailView(order: order)
                .environmentObject(cartManager)
        }
    }
    
    private func handleReorder(for order: Order) {
        guard let items = order.items as? [CartItemData] else { return }
        
        let hasDuplicates = ReorderManager.shared.hasDuplicates(
            orderItems: items,
            currentCart: cartManager.items
        )
        
        if hasDuplicates {
            let duplicateNames = ReorderManager.shared.getDuplicateNames(
                orderItems: items,
                currentCart: cartManager.items
            )
            let itemList = duplicateNames.joined(separator: ", ")
            
            AlertManager.shared.showConfirmation(
                title: "Items Already in Cart",
                message: "\(itemList) \(duplicateNames.count == 1 ? "is" : "are") already in your cart with the same options. Quantities will be combined.",
                confirmTitle: "Add to Cart",
                cancelTitle: "Cancel"
            ) {
                executeReorder(for: order)
            }
        } else {
            executeReorder(for: order)
        }
    }
    
    private func executeReorder(for order: Order) {
        Task {
            await ReorderManager.shared.executeReorder(
                order: order,
                cartManager: cartManager
            )
        }
    }
}
