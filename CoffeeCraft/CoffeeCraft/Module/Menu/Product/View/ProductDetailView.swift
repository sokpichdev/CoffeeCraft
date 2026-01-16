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
    @EnvironmentObject var favVM: FavoriteViewModel
    @Environment(\.dismiss) private var dismiss
    
    let product: Product
    var cartItem: CartItem? = nil // optional cart item for editing
    var onUpdate: (() -> Void)? = nil
    
    @State private var selectedExtras: [String]
    @State private var showAddedAlert = false
    @State private var selections: [String: String] = [:]
    
    // MARK: - Init to set initial selections from cartItem or defaults
    init(product: Product, cartItem: CartItem? = nil, onUpdate: (() -> Void)? = nil) {
        self.product = product
        self.cartItem = cartItem
        _selectedExtras = State(initialValue: cartItem?.extras ?? [])
    }

    private func bindingFor(_ category: String) -> Binding<String> {
        return Binding<String>(
            get: { selections[category] ?? "" },
            set: { selections[category] = $0 }
        )
    }

    // MARK: - Subtotal calculation
    private var subtotal: Double {
        var total = product.price

        if let customizations = product.customizations {
            for (category, options) in customizations {
                if category.lowercased() == "extras" {
                    continue // skip
                }
                // single-selection
                if let selectedOption = selections[category],
                   let price = options[selectedOption] {
                    total += price
                }
            }

            // multiple-selection extras
            if let extrasDict = customizations["Extras"] {
                for extra in selectedExtras {
                    total += extrasDict[extra] ?? 0
                }
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
                        if let customizations = product.customizations, !customizations.isEmpty {
                            ForEach(Array(customizations.keys), id: \.self) { category in
                                let options = customizations[category] ?? [:]

                                if category == "Extras" {
                                    CustomMultipleSelectionView(
                                        title: category,
                                        options: options,
                                        selected: $selectedExtras
                                    )
                                } else {
                                    CustomSingleSelectionview(
                                        title: category,
                                        sizePrice: product.price,
                                        options: options,
                                        selected: bindingFor(category) // dynamic bindings for selections
                                    )
                                }
                            }
                        } else {
                            Text("No customization available.")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    Spacer(minLength: 180)
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
                            selections: selections,
                            extras: selectedExtras
                        )
                        onUpdate?()
                    } else {
                        cartManager.addToCart(
                            product: product,
                            selections: selections,
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
        .onAppear {
            Task { await favVM.loadFavoriteState(product: product, selections: selections, selectedExtras: selectedExtras) }
        }
        .onChange(of: selections) {
            Task { await favVM.loadFavoriteState(product: product, selections: selections, selectedExtras: selectedExtras) }
        }
        .onChange(of: selectedExtras) {
            Task { await favVM.loadFavoriteState(product: product, selections: selections, selectedExtras: selectedExtras) }
        }
        .ignoresSafeArea(edges: .bottom)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            if cartItem != nil { // sheet
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.headline)
                            .foregroundColor(Color.brown)
                    }
                }
            } else { // navigation mode
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.headline)
                            .foregroundColor(Color.brown)
                    }
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    Task {
                        await favVM.toggleFavorite(product: product, selections: selections, selectedExtras: selectedExtras)
                    }
                } label: {
                    Image(systemName: favVM.isFavorite ? "heart.fill" : "heart")
                        .font(.headline)
                        .foregroundColor(favVM.isFavorite ? .red : .brown)
                }
            }
        }
        .navigationBarTitle(product.name, displayMode: .inline)
    }
}
