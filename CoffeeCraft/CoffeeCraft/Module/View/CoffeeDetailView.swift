//
//  CoffeeDetailView.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 10/20/25.
//
import SwiftUI
import SDWebImageSwiftUI

struct CoffeeDetailView: View {
    @EnvironmentObject var cartManager: CartManager
    @Environment(\.dismiss) private var dismiss
    let product: Product
    var cartItem: CartItem? = nil // optional cart item for editing
    var onUpdate: (() -> Void)? = nil
    @State private var selectedSize: String
    @State private var selectedMilk: String
    @State private var selectedSugar: String
    @State private var selectedIce: String
    @State private var selectedExtras: [String]
    @State private var showAddedAlert = false

    var sugarLevels = ["No Sugar", "Less", "Normal", "Extra"]
    var iceLevels = ["No Ice", "Less", "Regular", "Extra"]

    // MARK: - Init to set initial selections from cartItem or defaults
    init(product: Product, cartItem: CartItem? = nil, onUpdate: (() -> Void)? = nil) {
        self.product = product
        self.cartItem = cartItem
        self.onUpdate = onUpdate
        _selectedSize = State(initialValue: cartItem?.size ?? (product.customizations?["Size"]?.first ?? ""))
        _selectedMilk = State(initialValue: cartItem?.milk ?? (product.customizations?["Milk"]?.first ?? ""))
        _selectedSugar = State(initialValue: cartItem?.sugar ?? "Normal")
        _selectedIce = State(initialValue: cartItem?.ice ?? "Regular")
        _selectedExtras = State(initialValue: cartItem?.extras ?? [])
    }

    // MARK: - Subtotal calculation
    private var subtotal: Double {
        var price = product.price

        switch selectedSize {
        case "Small": price += 0
        case "Medium": price += 0.5
        case "Large": price += 1.0
        default: break
        }

        switch selectedMilk {
        case "Whole": price += 0
        case "Oat", "Soy", "Almond": price += 0.5
        default: break
        }

        price += Double(selectedExtras.count) * 0.5
        return price
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    WebImage(url: URL(string: product.imageURL))
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 300)
                        .cornerRadius(20)
                        .shadow(radius: 5)

                    VStack(alignment: .leading, spacing: 6) {
                        Text(product.name)
                            .font(.title)
                            .fontWeight(.bold)
                        Text(product.description)
                            .font(.body)
                            .foregroundColor(.secondary)
                    }

                    VStack(alignment: .leading, spacing: 16) {
                        if let sizes = product.customizations?["Size"] {
                            CustomSelectionChips(title: "Size", options: sizes, selected: $selectedSize)
                        }
                        if let milks = product.customizations?["Milk"] {
                            CustomSelectionChips(title: "Milk", options: milks, selected: $selectedMilk)
                        }
                        CustomSelectionChips(title: "Sugar", options: sugarLevels, selected: $selectedSugar)
                        CustomSelectionChips(title: "Ice", options: iceLevels, selected: $selectedIce)
                        if let extras = product.customizations?["Extras"] {
                            MultiSelectionChips(title: "Extras", options: extras, selected: $selectedExtras)
                        }
                    }

                    Spacer(minLength: 180) // 👈 Add spacing so content doesn’t hide behind footer
                }
                .padding()
            }

            // MARK: - Sticky Footer
            VStack(spacing: 12) {
                HStack {
                    Text("Subtotal:")
                        .font(.headline)
                    Spacer()
                    Text(String(format: "$%.2f", subtotal))
                        .font(.title2)
                        .bold()
                }

                Button(action: {
                    if let cartItem = cartItem {
                        cartManager.updateCartItem(
                            item: cartItem,
                            size: selectedSize,
                            milk: selectedMilk,
                            sugar: selectedSugar,
                            ice: selectedIce,
                            extras: selectedExtras
                        )
                        onUpdate?()
                    } else {
                        cartManager.addToCart(
                            product: product,
                            size: selectedSize,
                            milk: selectedMilk,
                            sugar: selectedSugar,
                            ice: selectedIce,
                            extras: selectedExtras
                        )
                    }
                    showAddedAlert = true
                }) {
                    Text(cartItem == nil ? "Add to Cart" : "Update Cart")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.brown)
                        .cornerRadius(12)
                        .shadow(radius: 3)
                }
                .alert("Added to Cart ☕️", isPresented: cartItem == nil ? $showAddedAlert : .constant(false)) {
                    Button("OK", role: .cancel) {}
                }
            }
            .padding()
            .padding(.bottom, 8)
            .frame(maxWidth: .infinity)
            .background(.ultraThinMaterial)
            .cornerRadius(20, corners: [.topLeft, .topRight])
            .shadow(radius: 5)
        }
        .ignoresSafeArea(edges: .bottom)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .font(.headline)
                        .foregroundColor(Color.brown)
                }
            }
        }
        .navigationBarTitle(product.name, displayMode: .inline)
    }
}

// MARK: - Single Selection Chips
struct CustomSelectionChips: View {
    var title: String
    var options: [String]
    @Binding var selected: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title).font(.headline)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(options, id: \.self) { option in
                        Text(option)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 16)
                            .background(selected == option ? Color.brown : Color.gray.opacity(0.2))
                            .foregroundColor(selected == option ? .white : .primary)
                            .cornerRadius(12)
                            .onTapGesture { selected = option }
                    }
                }
            }
        }
    }
}

// MARK: - Multi Selection Chips
struct MultiSelectionChips: View {
    var title: String
    var options: [String]
    @Binding var selected: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title).font(.headline)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(options, id: \.self) { option in
                        Text(option)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 16)
                            .background(selected.contains(option) ? Color.brown : Color.gray.opacity(0.2))
                            .foregroundColor(selected.contains(option) ? .white : .primary)
                            .cornerRadius(12)
                            .onTapGesture {
                                if selected.contains(option) {
                                    selected.removeAll { $0 == option }
                                } else {
                                    selected.append(option)
                                }
                            }
                    }
                }
            }
        }
    }
}
