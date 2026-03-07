//
//  OrderDetailView.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 2/6/26.
//
// The user's mental flow when opening an order detail is: who / when → what happened → what did I get → how much → now what?

import SwiftUI

struct OrderDetailView: View {
    let initialOrder: Order
    var isActive: Bool = false
    
    @StateObject private var vm: OrderDetailViewModel
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var cartManager: CartManager
    @State private var showReceipt = false
    
    init(order: Order, isActive: Bool = false) {
        self.initialOrder = order
        self.isActive = isActive
        _vm = StateObject(wrappedValue: OrderDetailViewModel(order: order))
    }
    
    var body: some View {
        CustomRefreshScrollView( {
            VStack(spacing: 0) {
                VStack(spacing: 24) {
                    OrderHeaderCard(order: vm.order, userName: vm.userName, isLoadingUser: vm.isLoadingUser)
                    
                    StatusTimelineView(status: vm.order.status ?? "")
                    
                    OrderItemsCard(items: vm.order.items as? [CartItemData] ?? [])
                    
                    PricingCard(
                        totalPrice: vm.order.totalPrice ?? 0.0,
                        items: vm.order.items as? [CartItemData] ?? [],
                        paymentMethod: vm.order.paymentMethod,
                        walletAmountPaid: vm.order.walletAmountPaid
                    )

                    ActionButtonsSection(
                        order: vm.order,
                        isActive: isActive,
                        isUpdating: vm.isUpdatingStatus,
                        isCancelling: vm.isCancelling,
                        onUpdateStatus: { newStatus in
                            Task { await vm.updateOrderStatus(to: newStatus) }
                        },
                        onReorder: { handleReorder() },
                        onCancel: { confirmCancel() }
                    )
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 20)
            }
        })
        .background(Color.bgSecondary)
        .customNavigationBar("Order Detail") {
            ToolBarButton.back {
                dismiss()
            }
            ToolBarButton(placement: .topBarTrailing, buttonType: .icon("doc.text")) {
                showReceipt = true
            }
        }
        .sheet(isPresented: $showReceipt) {
            OrderReceiptView(order: vm.order, userName: vm.userName)
        }
        .onAppear {
            if let orderId = vm.order.id {
                vm.startListening(orderId: orderId)
            }
            if let userId = vm.order.userId, !userId.isEmpty {
                vm.fetchUserInfo(userId: userId)
            }
        }
        .onDisappear {
            vm.stopListening()
        }
    }
    
    // MARK: - Cancel (Phase 5)
    private func confirmCancel() {
        AlertManager.shared.showDestructive(
            title: "Cancel Order?",
            message: vm.cancelConfirmationMessage,
            destructiveTitle: "Yes, Cancel"
        ) { Task { await vm.cancelOrder() } }
    }

    private func handleReorder() {
        guard let items = vm.order.items as? [CartItemData] else { return }
        
        // Check if any duplicates exist
        let hasDuplicates = ReorderManager.shared.hasDuplicates(
            orderItems: items,
            currentCart: cartManager.items
        )
        
        if hasDuplicates {
            // Show confirmation that some items will be merged
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
                executeReorder()
            }
        } else {
            // No duplicates, add directly
            executeReorder()
        }
    }
    
    private func executeReorder() {
        Task {
            await ReorderManager.shared.executeReorder(
                order: vm.order,
                cartManager: cartManager
            )
        }
    }
}
