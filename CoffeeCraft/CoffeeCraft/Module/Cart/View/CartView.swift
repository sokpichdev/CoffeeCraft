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
    @State private var editingItem: CartItem? = nil
    @State private var showCheckoutConfirm = false
    @State private var showPlaceOrderAlert: Bool = false
    
    @Environment(\.dismiss) private var dismiss

    @StateObject var orderService = OrderService()

    var body: some View {
        CustomNavigationStack {
            ZStack(alignment: .bottom) {
                ScrollView(showsIndicators: false) {
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
                    }
                    .padding()
                    .padding(.bottom, 100) // space for sticky footer
                }
                
                // MARK: - Checkout Footer
                VStack(spacing: 12) {
                    HStack {
                        Text("Total")
                            .font(.headline)
                        Spacer()
                        Text(String(format: "$%.2f", cartManager.total))
                            .font(.title2.bold())
                    }
                    
                    CustomCoffeeButton(title: "Checkout", bgColors: [Color.brown], isDisabled: cartManager.items.isEmpty) {
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
                    .padding(.bottom, 8)
                }
                .padding()
                .background(.ultraThinMaterial)
                .cornerRadius(20, corners: [.topLeft, .topRight])
                .shadow(radius: 5)
            }
            .ignoresSafeArea(edges: .bottom)
            .sheet(item: $editingItem) { item in
                CustomNavigationStack {
                    ProductDetailView(
                        product: item.product,
                        cartItem: item,
                        onUpdate: { editingItem = nil }
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
            // MARK: - Checkout Confirmation
            .alert("Confirm Order", isPresented: $showCheckoutConfirm) {
                Button("Cancel", role: .cancel) {}
                Button("Yes") {
//                    orderService.placeOrder(
//                        cartItems: cartManager.items,
//                        total: cartManager.total
//                    ) {
//                        Task {
//                            if let activeCard = cardVM.activeCard {
//                                do {
//                                    try await cardVM.addPoints(to: activeCard, amount: 1)
//                                } catch {
//                                    AlertManager.shared.showError(message: error.localizedDescription)
//                                }
//                            }
//                        }
//                        cartManager.clearCart(userId: UserSession.shared.userId ?? "")
//                        dismiss()
//                    }
                }
                
            } message: {
                Text("Are you sure you want to place this order? ☕")
            }
        }
    }
}
