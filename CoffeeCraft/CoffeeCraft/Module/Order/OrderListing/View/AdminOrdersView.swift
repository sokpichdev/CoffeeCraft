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

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.coffeeDarkBrown.opacity(0.75), Color.coffeeDarkBrown.opacity(0.5), Color(.systemBackground)],
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
                        .padding(.horizontal)
                } else {
                    MyOrdersContent(vm: vm)
                        .padding(.horizontal)
                }
            }
        }
        .customNavigationBar("Orders")
    }
}

// MARK: - Active Orders Content
struct ActiveOrdersContent: View {
    @ObservedObject var vm: AdminOrdersViewModel
    @Environment(\.pushScreen) private var push
    @State private var isPaginating = false

    private var filteredOrders: [Order] {
        vm.allOrders
            .filter { $0.status != "Completed" }
            .sorted(by: { $0.timestamp > $1.timestamp })
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
                CustomRefreshScrollView({
                    LazyVStack(spacing: 8) {
                        ForEach(Array(filteredOrders.enumerated()), id: \.element.id) { _, order in
                            PushLink {
                                OrderDetailView(order: order, isActive: true)
                            } label: {
                                OrderCardView(order: order) {
                                    AnyView(
                                        HStack(spacing: 8) {
                                            Button("Start") {
                                                Task {
                                                    let _ = await vm.updateOrderStatus(order: order, status: "InProgress")
                                                }
                                            }
                                            .disabled(order.status != "Pending")

                                            Button("Ready") {
                                                Task {
                                                    let _ = await vm.updateOrderStatus(order: order, status: "Ready")
                                                }
                                            }
                                            .disabled(order.status != "InProgress")

                                            Button("Complete") {
                                                Task {
                                                    let success = await vm.updateOrderStatus(order: order, status: "Completed")
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
                            }
                            .onAppear {
                                guard vm.allOrders.count < vm.totalAllOrdersCount else { return }
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
    }
}

// MARK: - My Orders Content
struct MyOrdersContent: View {
    @ObservedObject var vm: AdminOrdersViewModel
    @Environment(\.pushScreen) private var push
    @State private var isPaginating = false

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
                CustomRefreshScrollView({
                    LazyVStack(spacing: 8) {
                        ForEach(Array(vm.myOrders.enumerated()), id: \.element.id) { _, order in
                            PushLink {
                                OrderDetailView(order: order)
                            } label: {
                                OrderCardView(order: order)
//                                Text("Hi")
                            }
                            .onAppear {
                                guard vm.myOrders.count < vm.totalMyOrdersCount else { return }
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
    }
}
