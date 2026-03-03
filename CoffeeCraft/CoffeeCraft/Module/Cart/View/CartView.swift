//
//  CartView.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 10/20/25.
//
import SwiftUI

struct CartView: View {
    @EnvironmentObject var cartManager: CartManager
    @EnvironmentObject var cardVM: CardViewModel
    @EnvironmentObject var favVM: FavoriteViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var editingItem: CartItem? = nil

    @StateObject private var orderService = OrderService()
    @StateObject private var productVM = ProductViewModel()

    var body: some View {
        CustomNavigationStack {
            ZStack(alignment: .bottom) {
                CustomRefreshScrollView({
                    VStack(spacing: 12) {
                        ForEach(cartManager.items) { item in
                            Button {
                                editingItem = item
                            } label: {
                                CardItemView(item: item)
                            }
                            .buttonStyle(PlainButtonStyle())
                            .contextMenu {
                                Button(role: .destructive) {
                                    if let userId = UserSession.shared.userId {
                                        cartManager.removeFromCart(userId: userId, item: item)
                                    }
                                } label: {
                                    Label("Remove", systemImage: "trash")
                                }
                            }
                        }
                        Spacer(minLength: 180)
                    }
                    .padding()
                }, onRefresh: {
                    if let userId = UserSession.shared.userId {
                        cartManager.loadCartFromFirestore(userId: userId)
                    }
                })

                // MARK: - Checkout Footer
                StickyFooterView(label: "Total", amount: cartManager.total) {
                    CustomCoffeeButton(
                        title: "Checkout",
                        bgColors: [Color.brown],
                        isDisabled: cartManager.items.isEmpty
                    ) {
                        AlertManager.shared.showConfirmation(
                            title: "Confirm Order",
                            message: "the order total is \(String(format: "$%.2f", cartManager.total))",
                            confirmTitle: "Place"
                        ) {
                            orderService.placeOrder(
                                cartItems: cartManager.items,
                                total: cartManager.total
                            ) {
                                Task {
                                    if let activeCard = cardVM.activeCard {
                                        do {
                                            try await cardVM.addPoints(to: activeCard, amount: 1)
                                        } catch {
                                            AlertManager.shared.showError(message: error.localizedDescription)
                                        }
                                    }
                                }
                                cartManager.clearCart(userId: UserSession.shared.userId ?? "")
                                dismiss()
                            }
                        }
                    }
                    .padding(.bottom, 8)
                }
            }
            .background(Color(.systemGroupedBackground))
            .ignoresSafeArea(edges: .bottom)
            // Directly use ProductDetailView — selections/extras/quantity are now correctly
            // restored from cartItem in ProductDetailView's init, so no wrapper needed.
            .sheet(item: $editingItem) { item in
                CustomNavigationStack {
                    ProductDetailView(
                        product: item.product,
                        cartItem: item,
                        onUpdate: { editingItem = nil },
                        allProducts: productVM.products
                    )
                    .environmentObject(cartManager)
                    .environmentObject(favVM)
                }
            }
            .customNavigationBar("My Cart") {
                ToolBarButton.back {
                    dismiss()
                }
            }
            .task {
                await productVM.fetchProducts()
            }
        }
    }
}
