//
//  ProductDetailView.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 10/20/25.
//
import SwiftUI
import SDWebImageSwiftUI

struct ProductDetailView: View {
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

    // MARK: - Init to set initial selections from cartItem or defaults
    init(product: Product, cartItem: CartItem? = nil, onUpdate: (() -> Void)? = nil) {
        self.product = product
        self.cartItem = cartItem
        self.onUpdate = onUpdate
        _selectedSize = State(initialValue: cartItem?.size ?? "Size")
        _selectedMilk = State(initialValue: cartItem?.milk ?? "Milk")
        _selectedSugar = State(initialValue: cartItem?.sugar ?? "Normal")
        _selectedIce = State(initialValue: cartItem?.ice ?? "Regular")
        _selectedExtras = State(initialValue: cartItem?.extras ?? [])
    }

    // MARK: - Subtotal calculation
    private var subtotal: Double {
        var total = product.price

        // Size
        if let sizePrice = product.customizations?["Size"]?[selectedSize] {
            total += sizePrice
        }

        // Milk
        if let milkPrice = product.customizations?["Milk"]?[selectedMilk] {
            total += milkPrice
        }

        // Extras (multiple)
        if let extrasDict = product.customizations?["Extras"] {
            for extra in selectedExtras {
                total += extrasDict[extra] ?? 0
            }
        }

        return total
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    WebImage(url: URL(string: product.imageURL))
                        .resizable()
                        .scaledToFill()
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
                            CustomSingleSelectionview(title: "Size", sizePrice: product.price, options: sizes, selected: $selectedSize)
                        }
                        if let milks = product.customizations?["Milk"] {
                            CustomSingleSelectionview(title: "Milk", options: milks, selected: $selectedMilk)
                        }
                        if let sugarLevels = product.customizations?["Sugar"] {
                            CustomSingleSelectionview(title: "Sugar", options: sugarLevels, selected: $selectedSugar)
                        }
                        if let iceLevels = product.customizations?["Ice"] {
                            CustomSingleSelectionview(title: "Ice", options: iceLevels, selected: $selectedIce)
                        }
                        if let extras = product.customizations?["Extras"] {
                            CustomMultipleSelectionView(title: "Extras", options: extras, selected: $selectedExtras)
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
