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
    var cartItem: CartItem? // optional cart item for editing
    var onUpdate: (() -> Void)?
    var allProducts: [Product] = []
    
    @State private var selectedExtras: [String]
    @State private var selections: [String: String] // now initialized from cartItem
    @State private var quantity: Int

    init(product: Product, cartItem: CartItem? = nil, onUpdate: (() -> Void)? = nil, allProducts: [Product] = []) {
        self.product = product
        self.cartItem = cartItem
        self.onUpdate = onUpdate
        self.allProducts = allProducts
        // Restore ALL three pieces of state from the existing cart item when editing.
        // Previously only extras & quantity were restored — leaving selections empty —
        // which caused wrong option display and incorrect price in the edit sheet.
        _selectedExtras = State(initialValue: cartItem?.extras ?? [])
        _selections = State(initialValue: cartItem?.selections ?? [:])
        _quantity = State(initialValue: cartItem?.quantity ?? 1)
    }
    
    private var relatedProducts: [Product] {
        allProducts.filter { $0.category == product.category && $0.id != product.id }
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
                    VStack(alignment: .leading) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(product.name)
                                .font(.system(size: 24, weight: .bold, design: .serif))
                                .foregroundColor(.textPrimary)
                            
                            Text(product.description)
                                .font(.body)
                                .foregroundColor(.textTertiary)
                                .lineSpacing(3)
                        }
                        .padding(EdgeInsets(top: 16, leading: 16, bottom: 0, trailing: 16))
                        
                        Rectangle()
                            .fill(Color.accentPrimary.opacity(0.2))
                            .frame(height: 1)
                            .padding(.horizontal)
                        
                        if let customizations = product.customizations, !customizations.isEmpty {
                            ForEach(Array(customizations.keys.sorted()), id: \.self) { category in
                                let options = customizations[category] ?? [:]
                                
                                Group {
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
                                }
                                .padding(.top)
                                Rectangle()
                                    .fill(Color.accentPrimary.opacity(0.2))
                                    .frame(height: 1)
                            }
                            .padding(.horizontal)
                        } else {
                            Text("No customization available.")
                                .font(.subheadline)
                                .foregroundColor(.textTertiary)
                                .padding(.horizontal)
                        }
                        
                        // MARK: - Related Products Section
                        if !relatedProducts.isEmpty {
                            relatedProductsSection
                                .padding(.top)
                        }
                        
                        Spacer(minLength: 180)
                    }
                }
            })
            
            stickyFooter
        }
        .background(Color.bgPrimary)
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
                tint: favVM.isFavorite ? .semanticError : Color.accentPrimary
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
    
    private var relatedProductsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("More in \(product.category)")
                .font(.system(size: 17, weight: .semibold, design: .serif))
                .foregroundColor(Color.accentPrimary)
                .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(relatedProducts) { related in
                        MenuItemRow(item: related)
                            .frame(width: UIScreen.main.bounds.width * 0.72)
                            .onTapGesture {
                                push(
                                    AnyView(
                                        ProductDetailView(product: related, allProducts: allProducts)
                                            .environmentObject(cartManager)
                                            .environmentObject(favVM)
                                    )
                                )
                            }
                    }
                }
                .padding(.vertical, 4)  // prevents shadow clipping
                .padding(.horizontal)
            }
        }
    }
    
    // MARK: - Hero Image
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
                    .foregroundColor(Color.textPrimary)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 6)
                    .background(Capsule().fill(Color.parchment.opacity(0.92)))
                    .shadow(color: Color.accentPrimary.opacity(0.15), radius: 6, x: 0, y: 2)
                    .padding(.bottom, 16)
            }
            .frame(width: UIScreen.main.bounds.width, height: stretchHeight)
            .offset(y: minY > 0 ? -minY : 0)
        }
        .frame(height: heroImageHeight)
    }
    
    private var stickyFooter: some View {
        StickyFooterView(label: "Subtotal", amount: subtotal) {
            HStack(spacing: 12) {
                // Quantity stepper
                HStack(spacing: 0) {
                    Button {
                        if quantity > 1 { quantity -= 1 }
                    } label: {
                        Image(systemName: "minus")
                            .font(.headline.weight(.semibold))
                            .foregroundColor(quantity > 1 ? Color.accentPrimary : Color.accentPrimary.opacity(0.25))
                            .frame(width: 44, height: 44)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Text("\(quantity)")
                        .font(.headline.weight(.semibold))
                        .foregroundColor(Color.textPrimary)
                        .frame(minWidth: 28)
                        .contentTransition(.numericText())
                        .animation(.easeInOut(duration: 0.15), value: quantity)
                        .multilineTextAlignment(.center)
                    
                    Button {
                        quantity += 1
                    } label: {
                        Image(systemName: "plus")
                            .font(.headline.weight(.semibold))
                            .foregroundColor(Color.accentPrimary)
                            .frame(width: 44, height: 44)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .background(Capsule().fill(Color.accentPrimary.opacity(0.07)))
                .overlay(Capsule().stroke(Color.border, lineWidth: 1))
                
                CustomCoffeeButton(title: cartItem == nil ? "Add to Cart" : "Update Cart") {
                    if UserSession.shared.isLoggedIn {
                        if let cartItem = cartItem {
                            cartManager.updateCartItem(
                                userId: UserSession.shared.userId ?? "",
                                item: cartItem,
                                selections: selections,
                                extras: selectedExtras,
                                quantity: quantity
                            )
                            onUpdate?()
                        } else {
                            cartManager.addToCart(
                                userId: UserSession.shared.userId ?? "",
                                product: product,
                                selections: selections,
                                extras: selectedExtras,
                                quantity: quantity
                            )
                        }
                    } else {
                        push(AnyView(AuthView().environmentObject(AuthViewModel())))
                    }
                }
            }
        }
    }
}

//
//  StickyFooterView.swift
//  CoffeeCraft
//
struct StickyFooterView<Actions: View>: View {
    let label: String
    let amount: Double
    @ViewBuilder let actions: () -> Actions

    var body: some View {
        VStack(spacing: 12) {
            HStack(alignment: .center) {
                Text(label)
                    .font(.headline)
                    .foregroundColor(.textSecondary)

                Spacer()

                Text(String(format: "$%.2f", amount))
                    .font(.system(size: 22, weight: .bold, design: .serif))
                    .foregroundColor(.textPrimary)
                    .contentTransition(.numericText())
                    .animation(.easeInOut(duration: 0.2), value: amount)
            }

            actions()
        }
        .padding(EdgeInsets(top: 16, leading: 16, bottom: 24, trailing: 16))
        .background(.ultraThinMaterial)
        .cornerRadius(20, corners: [.topLeft, .topRight])
        .shadow(radius: 5)
    }
}
