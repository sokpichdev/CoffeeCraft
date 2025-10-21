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
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(cartManager.items) { item in
                            Button {
                                editingItem = item
                            } label: {
                                HStack(alignment: .top, spacing: 12) {
                                    // Optional product image
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
                                                .font(.caption)
                                                .foregroundColor(.gray)
                                        }
                                        
                                        Text(String(format: "$%.2f", item.totalPrice))
                                            .font(.subheadline)
                                            .bold()
                                    }
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.gray)
                                }
                                .padding()
                                .background(.ultraThinMaterial)
                                .cornerRadius(14)
                                .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
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
                            .font(.title2)
                            .bold()
                    }
                    
                    Button {
                        print("Checkout tapped")
                    } label: {
                        Text("Checkout")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.brown)
                            .cornerRadius(14)
                            .shadow(radius: 3)
                    }
                    .padding(.bottom, 8)
                }
                .padding(.horizontal)
                .padding(.top, 8)
                .background(.ultraThinMaterial)
                .cornerRadius(20, corners: [.topLeft, .topRight])
                .shadow(radius: 5)
            }
            .sheet(item: $editingItem) { item in
                CoffeeDetailView(
                    product: item.product,
                    cartItem: item,
                    onUpdate: {
                        editingItem = nil
                    }
                )
                .environmentObject(cartManager)
            }
            .navigationTitle("My Cart")
        }
    }
}
