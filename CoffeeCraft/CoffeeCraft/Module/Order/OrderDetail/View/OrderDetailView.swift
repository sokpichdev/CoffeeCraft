//
//  OrderDetailView.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 2/6/26.
//
//  The user's mental flow: who/when → progress → items → pricing → actions.
//

import MapKit
import SwiftUI

struct OrderDetailView: View {
    let initialOrder: Order
    var isActive: Bool = false
    
    @StateObject private var vm: OrderDetailViewModel

    @StateObject private var reviewVM = ReviewViewModel()
    @State private var selectedItemForRating: CartItemData?
    @State private var ratedProductIds: Set<String> = []

    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var cartManager: CartManager
    @State private var showReceipt = false
    @State private var navigateToDelivery = false
    // Captured at activation time so navigationDestination always has a non-nil VM.
    // capturedDeliveryVM is set before navigateToDelivery = true
    // a race — it may still be nil when SwiftUI evaluates the destination closure.
    @State private var capturedDeliveryVM: DeliveryViewModel?

    /// Observing OrderEnvironment makes the TrackDeliveryButton appear
    /// as soon as DeliveryRestoreService re-hydrates the VM on relaunch,
    /// without needing a status change to trigger onChange.
    @ObservedObject private var orderEnv = OrderEnvironment.shared
    
    init(order: Order, isActive: Bool = false) {
        self.initialOrder = order
        self.isActive = isActive
        _vm = StateObject(wrappedValue: OrderDetailViewModel(order: order))
    }

    var body: some View {
        CustomRefreshScrollView({
            VStack(spacing: 0) {
                VStack(spacing: 24) {
                    OrderHeaderCard(order: vm.order, userName: vm.userName, isLoadingUser: vm.isLoadingUser)
                    
                    StatusTimelineView(
                        status: vm.order.status ?? "",
                        isDeliveryOrder: vm.order.isDeliveryOrder
                    )

                    // Pickup-only: ready-for-pickup banner
                    if !vm.order.isDeliveryOrder,
                       vm.order.orderStatus == .ready,
                       let branch = vm.order.branchName {
                        PickupReadyBanner(branchName: branch) {
                            // Open Apple Maps to the branch
                            if let id = vm.order.branchId,
                               let branch = MockBranchData.all.first(where: { $0.id == id }) {
                                let item = MKMapItem(placemark: MKPlacemark(coordinate: branch.coordinate))
                                item.name = branch.name
                                item.openInMaps(launchOptions: [
                                    MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving
                                ])
                            }
                        }
                    }

                    // passes rating context when order is Completed
                    OrderItemsCard(
                        items: vm.order.items as? [CartItemData] ?? [],
                        orderStatus: vm.order.status,
                        ratedProductIds: ratedProductIds,
                        onRateItem: { item in
                            selectedItemForRating = item
                        }
                    )

                    PricingCard(
                        totalPrice: vm.order.totalPrice ?? 0.0,
                        items: vm.order.items as? [CartItemData] ?? [],
                        paymentMethod: vm.order.paymentMethod,
                        walletAmountPaid: vm.order.walletAmountPaid
                    )

                    // Delivery map track button — shown once simulator is active.
                    // Reads orderEnv (the @ObservedObject) so the button appears
                    // immediately when DeliveryRestoreService populates the VM on relaunch.
                    if vm.order.isDeliveryOrder,
                       let orderId = vm.order.id,
                       let trackVM = orderEnv.activeDeliveryVMs[orderId] {
                        TrackDeliveryButton {
                            capturedDeliveryVM = trackVM
                            navigateToDelivery = true
                        }
                    }

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
        .navigationDestination(isPresented: $navigateToDelivery) {
            if let vm = capturedDeliveryVM { DeliveryMapView(vm: vm) }
        }
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
        .sheet(item: $selectedItemForRating) { item in
            RatingInputSheet(
                vm: reviewVM,
                productName: item.name ?? "Item",
                imageURL: item.imageURL ?? ""
            )
            .onAppear {
                // Load proof-of-purchase + any existing rating for this product
                if let productId = item.productId {
                    Task {
                        await reviewVM.loadInitialState(productId: productId)
                        // Pre-seed the proof orderId from the order we're already on
                        if reviewVM.proofOrderId == nil, let orderId = vm.order.id {
                            reviewVM.proofOrderId = orderId
                        }
                    }
                }
            }
            .onDisappear {
                // If the user just submitted, mark that product as rated locally
                if let productId = item.productId, reviewVM.existingRating != nil {
                    ratedProductIds.insert(productId)
                }
            }
        }
        .onAppear {
            if let orderId = vm.order.id {
                vm.startListening(orderId: orderId)

                // If the app was relaunched while this order was OnDelivery,
                // DeliveryRestoreService will have already populated the VM.
                // onChange(of: status) won't fire because the status isn't
                // changing — so we sync capturedDeliveryVM here instead.
                if vm.order.isDeliveryOrder,
                   OrderStatus.from(vm.order.status) == .onDelivery,
                   let restoredVM = orderEnv.activeDeliveryVMs[orderId] {
                    capturedDeliveryVM = restoredVM
                }
            }
            if let userId = vm.order.userId, !userId.isEmpty {
                vm.fetchUserInfo(userId: userId)
            }
            // pre-load which items the user has already rated
            loadRatedProductIds()
        }
        // Delivery map activates when status reaches OnDelivery (rider dispatched)
        .onChange(of: vm.order.status) { _, newStatus in
            guard OrderStatus.from(newStatus) == .onDelivery,
                  vm.order.isDeliveryOrder,
                  let orderId = vm.order.id,
                  OrderEnvironment.shared.deliveryVM(for: orderId) == nil
            else { return }

            OrderEnvironment.shared.activateDelivery(order: vm.order)
            capturedDeliveryVM = OrderEnvironment.shared.deliveryVM(for: orderId)
            navigateToDelivery = true
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        }
        .onDisappear {
            vm.stopListening()
        }
    }

    // MARK: - Helpers

    private var isCompletedOrder: Bool { vm.order.orderStatus == .completed }

    private func loadRatedProductIds() {
        guard let userId = UserSession.shared.userId,
              let productIds = vm.order.productIds,
              !productIds.isEmpty,
              isCompletedOrder
        else { return }

        Task {
            var rated = Set<String>()
            await withTaskGroup(of: (String, Bool).self) { group in
                for productId in productIds {
                    group.addTask {
                        let existing = try? await RatingService.shared.fetchUserRating(
                            userId: userId, productId: productId)
                        return (productId, existing != nil)
                    }
                }
                for await (productId, hasRating) in group where hasRating {
                    rated.insert(productId)
                }
            }
            await MainActor.run { ratedProductIds = rated }
        }
    }

    private func confirmCancel() {
        AlertManager.shared.showDestructive(
            title: "Cancel Order?",
            message: vm.cancelConfirmationMessage,
            destructiveTitle: "Yes, Cancel"
        ) { Task { await vm.cancelOrder() } }
    }

    private func handleReorder() {
        guard let items = vm.order.items as? [CartItemData] else { return }
        let hasDuplicates = ReorderManager.shared.hasDuplicates(
            orderItems: items, currentCart: cartManager.items)
        if hasDuplicates {
            let duplicateNames = ReorderManager.shared.getDuplicateNames(
                orderItems: items, currentCart: cartManager.items)
            let itemList = duplicateNames.joined(separator: ", ")
            AlertManager.shared.showConfirmation(
                title: "Items Already in Cart",
                message: """
                \(itemList) \(duplicateNames.count == 1 ? "is" : "are") already in your \
                cart with the same options. Quantities will be combined.
                """,
                confirmTitle: "Add to Cart", cancelTitle: "Cancel"
            ) { executeReorder() }
        } else {
            executeReorder()
        }
    }

    private func executeReorder() {
        Task {
            await ReorderManager.shared.executeReorder(order: vm.order, cartManager: cartManager)
        }
    }
}
