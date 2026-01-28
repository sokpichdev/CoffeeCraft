//
//  CartView.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 10/20/25.
//
import SwiftUI

struct CartView: View {
    @EnvironmentObject var cartManager: CartManager
    @EnvironmentObject var favVM: FavoriteViewModel
    @State private var editingItem: CartItem? = nil
    @State private var showCheckoutConfirm = false
    @State private var isPlacingOrder = false
    @State private var showSuccess = false
    @State private var showError = false
    @Environment(\.dismiss) private var dismiss

    private let orderService = OrderService()

    var body: some View {
        NavigationStack {
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
                                    cartManager.removeFromCart(item: item)
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
                        showCheckoutConfirm = true
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
                NavigationStack {
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
                Button("Yes") { placeOrder() }
            } message: {
                Text("Are you sure you want to place this order? ☕")
            }
            // MARK: - Order Result Alerts
            .alert("Order Placed!", isPresented: $showSuccess) {
                Button("OK") {
                    cartManager.clearCart()
                    dismiss()
                }
            } message: {
                Text("Your coffee order has been sent to the barista ☕")
            }
            .alert("Something went wrong", isPresented: $showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Please try again later.")
            }
        }
    }

    // MARK: - Place Order
    private func placeOrder() {
        Task {
            isPlacingOrder = true
            do {
                try await orderService.placeOrder(cartItems: cartManager.items, total: cartManager.total)
                isPlacingOrder = false
                showSuccess = true
            } catch {
                isPlacingOrder = false
                showError = true
                print("Error placing order: \(error.localizedDescription)")
            }
        }
    }
}
