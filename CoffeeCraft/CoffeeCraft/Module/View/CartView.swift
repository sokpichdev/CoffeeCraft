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
                EditCartItemSheet(cartManager: cartManager, cartItem: item)
            }
            .navigationTitle("My Cart")
        }
    }
}

// MARK: - Edit Cart Item Sheet
struct EditCartItemSheet: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var cartManager: CartManager
    @State var cartItem: CartItem
    
    @State private var selectedSize: String = ""
    @State private var selectedMilk: String = ""
    @State private var selectedSugar: String = "Normal"
    @State private var selectedIce: String = "Regular"
    @State private var selectedExtras: [String] = []
    
    var sugarLevels = ["No Sugar", "Less", "Normal", "Extra"]
    var iceLevels = ["No Ice", "Less", "Regular", "Extra"]
    
    private var subtotal: Double {
        var price = cartItem.product.price
        switch selectedSize { case "Small": break; case "Medium": price += 0.5; case "Large": price += 1.0; default: break }
        switch selectedMilk { case "Whole": break; case "Oat": price += 0.5; case "Soy": price += 0.5; case "Almond": price += 0.5; default: break }
        price += Double(selectedExtras.count) * 0.5
        return price
    }
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text(cartItem.product.name).font(.title).bold()
                    
                    if let sizes = cartItem.product.customizations?["Size"] {
                        CustomSelectionChips(title: "Size", options: sizes, selected: $selectedSize)
                    }
                    if let milks = cartItem.product.customizations?["Milk"] {
                        CustomSelectionChips(title: "Milk", options: milks, selected: $selectedMilk)
                    }
                    CustomSelectionChips(title: "Sugar", options: sugarLevels, selected: $selectedSugar)
                    CustomSelectionChips(title: "Ice", options: iceLevels, selected: $selectedIce)
                    if let extras = cartItem.product.customizations?["Extras"] {
                        MultiSelectionChips(title: "Extras", options: extras, selected: $selectedExtras)
                    }
                }
                .padding()
            }
            
            // Sticky footer
            VStack(spacing: 12) {
                HStack {
                    Text("Subtotal:")
                        .font(.headline)
                    Spacer()
                    Text(String(format: "$%.2f", subtotal))
                        .font(.title2)
                        .bold()
                }
                
                Button {
                    // Update the cart item
                    if let index = cartManager.items.firstIndex(where: { $0.id == cartItem.id }) {
                        cartManager.items[index] = CartItem(
                            product: cartItem.product,
                            size: selectedSize,
                            milk: selectedMilk,
                            sugar: selectedSugar,
                            ice: selectedIce,
                            extras: selectedExtras
                        )
                    }
                    dismiss()
                } label: {
                    Text("Update Cart")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.brown)
                        .cornerRadius(12)
                        .shadow(radius: 3)
                }
            }
            .padding()
            .padding(.bottom, 8)
            .background(.ultraThinMaterial)
        }
        .onAppear {
            selectedSize = cartItem.size
            selectedMilk = cartItem.milk
            selectedSugar = cartItem.sugar
            selectedIce = cartItem.ice
            selectedExtras = cartItem.extras
        }
    }
}

