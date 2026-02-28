//
//  ProductDetailView.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 10/20/25.
//
import SwiftUI

struct ProductDetailView: View {
    @EnvironmentObject var cartManager: CartManager
    @EnvironmentObject var favVM: FavoriteViewModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.pushScreen) private var push
    let product: Product
    var cartItem: CartItem? = nil // optional cart item for editing
    var onUpdate: (() -> Void)? = nil
    
    @State private var selectedExtras: [String]
    @State private var selections: [String: String] = [:]
    @State private var quantity: Int = 1

    init(product: Product, cartItem: CartItem? = nil, onUpdate: (() -> Void)? = nil) {
        self.product = product
        self.cartItem = cartItem
        _selectedExtras = State(initialValue: cartItem?.extras ?? [])
    }

    private func bindingFor(_ category: String) -> Binding<String> {
        Binding<String>(
            get: { selections[category] ?? "" },
            set: { selections[category] = $0 }
        )
    }

    // MARK: - Subtotal calculation
    private var subtotal: Double {
        var total = product.price

        if let customizations = product.customizations {
            for (category, options) in customizations {
                guard category.lowercased() != "extras" else { continue }
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

        return total * Double(quantity)
    }

    private var customizationHash: String {
        favVM.buildCustomizationHash(
            favVM.currentCustomizationForFavorite(
                selections: selections,
                selectedExtras: selectedExtras
            )
        )
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            CustomRefreshScrollView({
                VStack(alignment: .leading, spacing: 0) {
                    stickyHeroImage
                    VStack(alignment: .leading, spacing: 20) {

                        VStack(alignment: .leading, spacing: 6) {
                            Text(product.name)
                                .font(.system(size: 24, weight: .bold, design: .serif))
                                .foregroundColor(Color.brown)

                            Text(product.description)
                                .font(.body)
                                .foregroundColor(.secondary)
                                .lineSpacing(3)
                        }

                        Rectangle()
                            .fill(Color.brown.opacity(0.1))
                            .frame(height: 1)

                        if let customizations = product.customizations, !customizations.isEmpty {
                            ForEach(Array(customizations.keys.sorted()), id: \.self) { category in
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
                                        selected: bindingFor(category)
                                    )
                                }

                                Rectangle()
                                    .fill(Color.brown.opacity(0.07))
                                    .frame(height: 1)
                            }
                        } else {
                            Text("No customization available.")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }

                        Spacer(minLength: 200)
                    }
                    .padding(20)
                }
            })

            stickyFooter
        }
        .task(id: customizationHash) {
            await favVM.loadFavoriteState(
                product: product,
                selections: selections,
                selectedExtras: selectedExtras
            )
        }
        .onDisappear { favVM.resetFavoriteState() }
        .ignoresSafeArea(edges: .bottom)
        .customNavigationBar(product.name) {
            if cartItem != nil {
                ToolBarButton(placement: .topBarLeading, buttonType: .icon("xmark")) {
                    dismiss()
                }
            } else {
                ToolBarButton.back { dismiss() }
            }
            ToolBarButton(
                placement: .topBarTrailing,
                buttonType: .icon(favVM.isFavorite ? "heart.fill" : "heart"),
                tint: favVM.isFavorite ? .red : Color.brown
            ) {
                if UserSession.shared.isLoggedIn {
                    Task {
                        await favVM.toggleFavorite(
                            product: product,
                            selections: selections,
                            selectedExtras: selectedExtras
                        )
                    }
                } else {
                    push(AnyView(AuthView().environmentObject(AuthViewModel())))
                }
            }
        }
    }
    
    private var heroImageHeight: CGFloat { UIScreen.main.bounds.width * 9 / 16 }

    private var stickyHeroImage: some View {
        GeometryReader { geo in
            let minY = geo.frame(in: .global).minY
            let stretchHeight = heroImageHeight + (minY > 0 ? minY : 0)

            ZStack(alignment: .bottom) {
                AsyncImageCard(
                    imageURL: product.imageURL,
                    height: stretchHeight,
                    width: UIScreen.main.bounds.width,
                    corner: 0
                )
                .clipped()

                // Base price pill on the image
                Text("from $\(product.price, specifier: "%.2f")")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(Color.brown)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(Color.parchment.opacity(0.92))
                    )
                    .shadow(color: Color.brown.opacity(0.15), radius: 6, x: 0, y: 2)
                    .padding(.bottom, 16)
            }
            .frame(width: UIScreen.main.bounds.width, height: stretchHeight)
            .offset(y: minY > 0 ? -minY : 0)
        }
        .frame(height: heroImageHeight)
    }

    private var stickyFooter: some View {
        VStack(spacing: 12) {

            HStack(alignment: .center) {
                Text("Subtotal")
                    .font(.headline)
                    .foregroundColor(.secondary)

                Spacer()

                Text(String(format: "$%.2f", subtotal))
                    .font(.system(size: 22, weight: .bold, design: .serif))
                    .foregroundColor(Color.brown)
                    .contentTransition(.numericText())
                    .animation(.easeInOut(duration: 0.2), value: subtotal)
            }

            HStack(spacing: 12) {

                HStack(spacing: 0) {
                    Button {
                        if quantity > 1 { quantity -= 1 }
                    } label: {
                        Image(systemName: "minus")
                            .font(.headline.weight(.semibold))
                            .foregroundColor(quantity > 1 ? Color.brown : Color.brown.opacity(0.25))
                            .frame(width: 36, height: 36)
                    }
                    .buttonStyle(PlainButtonStyle())

                    Text("\(quantity)")
                        .font(.headline.weight(.semibold))
                        .foregroundColor(Color.brown)
                        .frame(minWidth: 28)
                        .contentTransition(.numericText())
                        .animation(.easeInOut(duration: 0.15), value: quantity)
                        .multilineTextAlignment(.center)

                    Button {
                        quantity += 1
                    } label: {
                        Image(systemName: "plus")
                            .font(.headline.weight(.semibold))
                            .foregroundColor(Color.brown)
                            .frame(width: 36, height: 36)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .background(Capsule().fill(Color.brown.opacity(0.07)))
                .overlay(Capsule().stroke(Color.brown.opacity(0.18), lineWidth: 1))

                
                CustomCoffeeButton(title: cartItem == nil ? "Add to Cart" : "Update Cart") {
                    if UserSession.shared.isLoggedIn {
                        if let cartItem = cartItem {
                            cartManager.updateCartItem(
                                userId: UserSession.shared.userId ?? "",
                                item: cartItem,
                                selections: selections,
                                extras: selectedExtras
                            )
                            onUpdate?()
                        } else {
                            cartManager.addToCart(
                                userId: UserSession.shared.userId ?? "",
                                product: product,
                                selections: selections,
                                extras: selectedExtras // TODO: add qty
                            )
                        }
                    } else {
                        push(AnyView(AuthView().environmentObject(AuthViewModel())))
                    }
                }
            }
        }
        .padding(EdgeInsets(top: 16, leading: 16, bottom: 24, trailing: 16))
        .background(.ultraThinMaterial)
        .cornerRadius(20, corners: [.topLeft, .topRight])
        .shadow(radius: 5)
    }}
