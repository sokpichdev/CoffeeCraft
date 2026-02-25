//
//  OrderDetailView.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 2/6/26.
//

import SwiftUI

struct OrderDetailView: View {
    let initialOrder: Order
    var isActive: Bool = false
    
    @StateObject private var vm: OrderDetailViewModel
    @Environment(\.dismiss) private var dismiss
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
                    // Header Card with Order Info & User
                    OrderHeaderCard(
                        order: vm.order,
                        userName: vm.userName,
                        isLoadingUser: vm.isLoadingUser
                    )
                    
                    // Live Status Timeline
                    StatusTimelineView(status: vm.order.status)
                    
                    // Order Items Card
                    OrderItemsCard(items: vm.order.items)
                    
                    // Pricing Breakdown
                    PricingCard(totalPrice: vm.order.totalPrice, items: vm.order.items)
                    
                    // Action Buttons
                    ActionButtonsSection(order: vm.order, isActive: isActive)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 20)
            }
        })
        .background(Color(.systemGroupedBackground))
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
            if !vm.order.userId.isEmpty {
                vm.fetchUserInfo(userId: vm.order.userId)
            }
        }
        .onDisappear {
            vm.stopListening()
        }
    }
}
