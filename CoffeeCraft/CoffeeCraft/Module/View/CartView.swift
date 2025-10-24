//
//  CartView.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 10/20/25.
//
import SwiftUI
import SDWebImageSwiftUI

struct CartView: View {
    @EnvironmentObject var cartManager: CartManager
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
                    
                    Button {
                        showCheckoutConfirm = true
                    } label: {
                        Text("Checkout")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(cartManager.items.isEmpty ? Color.gray : Color.brown)
                            .cornerRadius(14)
                            .shadow(radius: 3)
                    }
                    .padding(.bottom, 8)
                    .disabled(cartManager.items.isEmpty)
                }
                .padding()
                .background(.ultraThinMaterial)
                .cornerRadius(20, corners: [.topLeft, .topRight])
                .shadow(radius: 5)
            }
            .ignoresSafeArea(edges: .bottom)
            .sheet(item: $editingItem) { item in
                CoffeeDetailView(
                    product: item.product,
                    cartItem: item,
                    onUpdate: { editingItem = nil }
                )
                .environmentObject(cartManager)
            }
            .navigationTitle("My Cart")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.brown)
                    }
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

struct CardItemView: View {
    let item: CartItem
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            if let url = URL(string: item.product.imageURL) {
                WebImage(url: url)
                    .resizable()
                    .indicator(.activity)
                    .frame(width: 60, height: 60)
                    .cornerRadius(10)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(item.product.name)
                    .font(.headline)
                Text("\(item.size), \(item.milk)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                if !item.extras.isEmpty {
                    Text("Extras: \(item.extras.joined(separator: ", "))")
                        .font(.caption2)
                        .foregroundColor(.gray)
                }
            }
            Spacer()
            Text(String(format: "$%.2f", item.totalPrice))
                .font(.subheadline)
                .bold()
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(14)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}
