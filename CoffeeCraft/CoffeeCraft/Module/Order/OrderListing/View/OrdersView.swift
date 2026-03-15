//
//  OrdersView.swift
//  CoffeeCraft
//
//  Updated: works with cursor-based OrderViewModel.
//  Removed pageNum + isPaginating — ViewModel owns all pagination state.
//
import SwiftUI

struct OrdersView: View {
    @EnvironmentObject var orderVM: OrderViewModel
    @EnvironmentObject var coordinator: NotificationCoordinator
    @EnvironmentObject var cartManager: CartManager
    @State private var selectedOrder: Order?
    @State private var navigateToDelivery  = false
    @State private var capturedDeliveryVM: DeliveryViewModel? = nil

    var body: some View {
        ZStack {
            Color(uiColor: .systemGroupedBackground)
                .ignoresSafeArea()

            if orderVM.isLoading {
                loadingView
            } else if orderVM.orders.isEmpty {
                emptyStateView
            } else {
                ordersListView
            }
        }
        .customNavigationBar("My Orders")
        .navigationDestination(item: $selectedOrder) { order in
            OrderDetailView(order: order)
                .environmentObject(cartManager)
        }
        .navigationDestination(isPresented: $navigateToDelivery) {
            if let vm = capturedDeliveryVM {
                DeliveryMapView(vm: vm)
            }
        }
        .onAppear {
            Task { await orderVM.fetchOrders() }
            handleDeepLink()
        }
        .onChange(of: coordinator.selectedOrderId) { _, _ in
            handleDeepLink()
        }
    }

    // MARK: - Loading

    private var loadingView: some View {
        ScrollView {
            OrderListShimmerView()
                .padding(.horizontal)
                .padding(.vertical)
        }
    }

    // MARK: - Empty State

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "cup.and.saucer.fill")
                .font(.system(size: 60))
                .foregroundColor(.accentPrimary.opacity(0.7))
            Text("No Orders Yet")
                .font(.title3)
                .fontWeight(.semibold)
            Text("Your recent coffee orders will appear here.")
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Orders List

    private var ordersListView: some View {
        CustomRefreshScrollView({
            LazyVStack(spacing: 8) {
                ForEach(orderVM.orders) { order in
                    orderRow(for: order)
                }
                paginationFooter
            }
            .padding(.vertical)
            .frame(maxWidth: .infinity)
        }, onRefresh: {
            await orderVM.refreshOrders()
        })
    }

    // MARK: - Order Row

    // Extracted into its own function to avoid the "unable to type-check
    // expression in reasonable time" compiler error caused by deeply
    // nested closures inside ForEach + .onAppear + Task.
    private func orderRow(for order: Order) -> some View {
        OrderCardView(
            order: order,
            onNavigate: {
                // If this card has an active delivery, go straight to the map
                if order.isDeliveryOrder,
                   let orderId = order.id,
                   let trackVM = OrderEnvironment.shared.deliveryVM(for: orderId) {
                    capturedDeliveryVM = trackVM
                    navigateToDelivery = true
                } else {
                    navigateToDetail(order: order)
                }
            },
            onReorder: { handleReorder(for: order) }
        )
        .padding(.horizontal)
        .onAppear {
            if order.id == orderVM.orders.last?.id {
                Task { await orderVM.loadMore() }
            }
        }
    }

    // MARK: - Pagination Footer

    @ViewBuilder
    private var paginationFooter: some View {
        if orderVM.isLoadingMore {
            HStack {
                Spacer()
                ProgressView()
                    .padding(.vertical, 16)
                Spacer()
            }
        } else if !orderVM.hasMorePages && orderVM.orders.count > 5 {
            Text("You've seen all your orders ☕")
                .font(.caption)
                .foregroundColor(.textSecondary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
        }
    }

    // MARK: - Navigation

    private func navigateToDetail(order: Order) {
        selectedOrder = order
    }

    // MARK: - Deep Link

    private func handleDeepLink() {
        guard let orderId = coordinator.selectedOrderId else { return }

        if orderVM.orders.contains(where: { $0.id == orderId }) {
            navigateToLinkedOrder(orderId: orderId)
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                navigateToLinkedOrder(orderId: orderId)
            }
        }
    }

    private func navigateToLinkedOrder(orderId: String) {
        guard let order = orderVM.orders.first(where: { $0.id == orderId }) else { return }
        navigateToDetail(order: order)
        coordinator.clearNavigation()
    }

    // MARK: - Reorder

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
            let noun = duplicateNames.count == 1 ? "is" : "are"

            AlertManager.shared.showConfirmation(
                title: "Items Already in Cart",
                message: "\(itemList) \(noun) already in your cart with the same options. Quantities will be combined.",
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
