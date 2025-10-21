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
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                ScrollView {
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
                .padding(.vertical, 8)
                .background(.ultraThinMaterial)
                .cornerRadius(20, corners: [.topLeft, .topRight])
                .shadow(radius: 5)
            }
            .ignoresSafeArea(edges: .bottom)
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
            .navigationBarTitle("My Cart", displayMode: .inline) // set the title
            .navigationBarBackButtonHidden(false) // show the back button
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        // Pop the view
                        // If using NavigationStack:
                        // presentationMode.wrappedValue.dismiss()
                        dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.brown)
                    }
                }
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
