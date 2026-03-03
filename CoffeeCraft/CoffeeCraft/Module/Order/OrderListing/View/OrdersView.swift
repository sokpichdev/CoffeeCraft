//
//  OrdersView.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 10/23/25.
//
import SwiftUI

struct OrdersView: View {
    @EnvironmentObject var orderVM: OrderViewModel
    @EnvironmentObject var coordinator: NotificationCoordinator
    @EnvironmentObject var cartManager: CartManager
    @Environment(\.pushScreen) private var push
    @State private var isPaginating = false
    @State private var pageNum = 1
    
    var body: some View {
        ZStack {
            Color(uiColor: .systemGroupedBackground)
                .ignoresSafeArea()

            if orderVM.isLoading {
                ScrollView {
                    OrderListShimmerView()
                        .padding(.horizontal)
                        .padding(.vertical)
                }
            } else if orderVM.orders.isEmpty {
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
                CustomRefreshScrollView({
                    LazyVStack(spacing: 8) {
                        ForEach(Array(orderVM.orders.enumerated()), id: \.element.id) { _, order in
                            OrderCardView(
                                order: order,
                                onNavigate: {
                                    push(AnyView(OrderDetailView(order: order).environmentObject(cartManager)))
                                },
                                onReorder: {
                                    handleReorder(for: order)
                                }
                            ).padding(.horizontal)
                            .onAppear {
                                if orderVM.orders.count < orderVM.totalOrdersCount {
                                    if order.id == orderVM.orders.last?.id, !isPaginating {
                                        isPaginating = true
                                        pageNum += 1
                                        Task {
                                            let timer = MinimumLoadingTime(0.5)
                                            try? await timer.waitIfNeeded()
                                            await orderVM.fetchOrders(pageNum: pageNum)
                                            isPaginating = false
                                        }
                                    }
                                }
                            }
                        }

                        if isPaginating {
                            ProgressView().padding()
                        }
                    }
                    .padding(.vertical)
                    .frame(maxWidth: .infinity)
                }, onRefresh: {
                    pageNum = 1
                    await orderVM.refreshOrders()
                })
            }
        }
        .customNavigationBar("My Orders")
        .onAppear {
            Task { await orderVM.fetchOrders(pageNum: 1) }
            handleDeepLink()
        }
        .onChange(of: coordinator.selectedOrderId) { _, _ in
            handleDeepLink()
        }
    }

    private func handleDeepLink() {
        guard let orderId = coordinator.selectedOrderId else { return }

        func navigate() {
            if let order = orderVM.orders.first(where: { $0.id == orderId }) {
                push(AnyView(OrderDetailView(order: order).environmentObject(cartManager)))
                coordinator.clearNavigation()
            }
        }

        if orderVM.orders.contains(where: { $0.id == orderId }) {
            navigate()
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                navigate()
            }
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
