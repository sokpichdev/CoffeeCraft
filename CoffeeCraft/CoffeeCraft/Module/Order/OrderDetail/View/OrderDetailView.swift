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
        ZStack {
            // Background gradient matching your app theme
            LinearGradient(
                colors: [
                    Color.coffeeDarkBrown.opacity(0.15),
                    Color(.systemBackground),
                    Color(.systemBackground)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // Status Update Animation Overlay
                    if vm.showStatusUpdateAnimation {
                        StatusUpdateBanner(status: vm.lastStatusUpdate ?? vm.order.status)
                            .transition(.move(edge: .top).combined(with: .opacity))
                    }
                    
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
            }
        }
        .navigationTitle("Order #\(vm.order.orderId)")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showReceipt = true
                } label: {
                    Image(systemName: "doc.text")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.coffeeDarkBrown)
                }
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
