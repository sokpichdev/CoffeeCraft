//
//  CartView.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 10/20/25.
//
import SwiftUI

struct CartView: View {
    @EnvironmentObject var cartManager: CartManager
    @State private var editingItem: CartItem? = nil
    @State private var showEditSheet = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                List {
                    ForEach(cartManager.items) { item in
                        Button {
                            editingItem = item
                            showEditSheet = true
                        } label: {
                            VStack(alignment: .leading) {
                                Text(item.product.name)
                                    .font(.headline)
                                Text("\(item.size), \(item.milk)")
                                if !item.extras.isEmpty {
                                    Text("Extras: \(item.extras.joined(separator: ", "))")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                Text(String(format: "$%.2f", item.totalPrice))
                                    .font(.subheadline)
                                    .foregroundColor(.primary)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                    .onDelete { indexSet in
                        indexSet.forEach { cartManager.removeFromCart(item: cartManager.items[$0]) }
                    }
                }
                
                // MARK: - Checkout Footer
                VStack(spacing: 12) {
                    HStack {
                        Text("Total: ")
                            .font(.headline)
                        Spacer()
                        Text(String(format: "$%.2f", cartManager.total))
                            .font(.title2)
                            .bold()
                    }
                    .padding(.horizontal)
                    
                    Button {
                        // Handle checkout action here
                        print("Checkout tapped")
                    } label: {
                        Text("Checkout")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.brown)
                            .cornerRadius(12)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 8)
                }
                .background(.ultraThinMaterial)
            }
            .sheet(item: $editingItem) { item in
                CoffeeDetailView(product: item.product, cartItem: item)
                                    .environmentObject(cartManager)
            }
            .navigationTitle("My Cart")
        }
    }
}
