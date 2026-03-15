//
//  OrderDetailView.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 2/6/26.
//
// The user's mental flow when opening an order detail is: who / when → what happened → what did I get → how much → now what?

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
    @State private var showReceipt        = false
    @State private var navigateToDelivery = false
    // Captured at activation time so navigationDestination always has a non-nil VM.
    // Reading OrderEnvironment.shared.activeDeliveryVM inside navigationDestination is
    // a race — it may still be nil when SwiftUI evaluates the destination closure.
    @State private var capturedDeliveryVM: DeliveryViewModel? = nil
    
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

                    // Ready-for-pickup banner — only for pickup orders at Ready status
                    if vm.order.deliveryType == "pickup",
                       vm.order.status == "Ready",
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

                    // Track delivery button — shown once the simulator is active
                    // for this specific order (status reached Ready).
                    if vm.order.isDeliveryOrder,
                       OrderEnvironment.shared.activeDeliverySession?.orderId == vm.order.id,
                       let trackVM = OrderEnvironment.shared.activeDeliveryVM {
                        TrackDeliveryButton {
                            // Re-capture in case the user navigated back and returns
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
            // capturedDeliveryVM is set synchronously before navigateToDelivery = true,
            // so it is guaranteed non-nil here. The fallback should never be reached.
            if let vm = capturedDeliveryVM ?? OrderEnvironment.shared.activeDeliveryVM {
                DeliveryMapView(vm: vm)
            }
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
                productName: item.name    ?? "Item",
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
            }
            if let userId = vm.order.userId, !userId.isEmpty {
                vm.fetchUserInfo(userId: userId)
            }
            // pre-load which items the user has already rated
            loadRatedProductIds()
        }
        // ── Delivery activation on status change ───────────────
        // The real-time listener in OrderDetailViewModel fires this
        // whenever the barista updates the order status in the admin panel.
        // "Ready" is the trigger for delivery orders:
        //   Pending → InProgress → Ready → (simulator starts) → Delivered
        .onChange(of: vm.order.status) { _, newStatus in
            guard newStatus == "Ready",
                  vm.order.isDeliveryOrder,
                  OrderEnvironment.shared.activeDeliveryVM == nil
            else { return }

            // 1. Activate simulator — reads coordinates from the order document
            //    (written to Firestore at checkout) so it works after clear() wipes memory.
            OrderEnvironment.shared.activateDelivery(order: vm.order)

            // 2. Capture VM directly into @State so navigationDestination always
            //    has a non-nil value regardless of SwiftUI's render timing.
            capturedDeliveryVM = OrderEnvironment.shared.activeDeliveryVM

            // 3. Navigate
            navigateToDelivery = true
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        }
        .onDisappear {
            vm.stopListening()
        }
    }

    /// Queries Firestore for any products in this order that the current user
    /// has already rated, so prompts show the correct "Rated / Rate" state
    /// immediately without waiting for each item's sheet to open.
    private func loadRatedProductIds() {
        guard
            let userId     = UserSession.shared.userId,
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
                            userId: userId,
                            productId: productId
                        )
                        return (productId, existing != nil)
                    }
                }
                for await (productId, hasRating) in group {
                    if hasRating { rated.insert(productId) }
                }
            }
            await MainActor.run { ratedProductIds = rated }
        }
    }

    private var isCompletedOrder: Bool {
        let s = vm.order.status?.lowercased() ?? ""
        return s == "completed" || s == "done"
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
