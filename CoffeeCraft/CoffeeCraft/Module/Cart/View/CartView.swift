//
//  CartView.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 10/20/25.
//
import SwiftUI

struct CartView: View {
    @EnvironmentObject var cartManager: CartManager
    @EnvironmentObject var cardVM: CardViewModel
    @EnvironmentObject var favVM: FavoriteViewModel
    @EnvironmentObject var walletVM: WalletViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var editingItem: CartItem? = nil
    @StateObject private var orderService = OrderService()
    @StateObject private var productVM = ProductViewModel()

    var body: some View {
        CustomNavigationStack {
            ZStack(alignment: .bottom) {
                CustomRefreshScrollView({
                    VStack(spacing: 12) {
                        ForEach(cartManager.items) { item in
                            Button { editingItem = item } label: { CardItemView(item: item) }
                                .buttonStyle(PlainButtonStyle())
                                .contextMenu {
                                    Button(role: .destructive) {
                                        if let userId = UserSession.shared.userId {
                                            cartManager.removeFromCart(userId: userId, item: item)
                                        }
                                    } label: { Label("Remove", systemImage: "trash") }
                                }
                        }
                        Spacer(minLength: 220)
                    }
                    .padding()
                }, onRefresh: {
                    if let userId = UserSession.shared.userId {
                        cartManager.loadCartFromFirestore(userId: userId)
                    }
                })

                StickyFooterView(label: "Total", amount: cartManager.total) {
                    VStack(spacing: 10) {
                        paymentMethodToggle

                        if cartManager.paymentMethod == .wallet,
                           !(walletVM.wallet?.canAfford(cartManager.total) ?? false) {
                            insufficientBalanceBanner
                        }

                        CustomCoffeeButton(
                            title: "Checkout",
                            bgColors: [Color.brown],
                            isDisabled: cartManager.items.isEmpty || !cartManager.canCheckout(walletBalance: walletVM.wallet?.balance)
                        ) {
                            confirmAndPlaceOrder()
                        }
                        .padding(.bottom, 8)
                    }
                }
            }
            .background(Color(.systemGroupedBackground))
            .ignoresSafeArea(edges: .bottom)
            .sheet(item: $editingItem) { item in
                CustomNavigationStack {
                    ProductDetailView(
                        product: item.product,
                        cartItem: item,
                        onUpdate: { editingItem = nil },
                        allProducts: productVM.products
                    )
                    .environmentObject(cartManager)
                    .environmentObject(favVM)
                }
            }
            .customNavigationBar("My Cart") {
                ToolBarButton.back { dismiss() }
            }
            .task { await productVM.fetchProducts() }
        }
    }

    // MARK: - Payment Toggle

    private var paymentMethodToggle: some View {
        HStack(spacing: 12) {
            ForEach(PaymentMethod.allCases, id: \.self) { method in
                paymentChip(method)
            }
        }
        .padding(.horizontal, 4)
    }

    private func paymentChip(_ method: PaymentMethod) -> some View {
        let isSelected = cartManager.paymentMethod == method
        let canAfford  = walletVM.wallet?.canAfford(cartManager.total) ?? false

        return Button {
            withAnimation(.spring(duration: 0.2)) {
                cartManager.paymentMethod = method
            }
        } label: {
            HStack(spacing: 6) {
                Image(systemName: method.icon).font(.caption.weight(.semibold))
                VStack(alignment: .leading, spacing: 1) {
                    Text(method.displayName)
                        .font(.caption)
                        .fontWeight(isSelected ? .bold : .regular)
                    if method == .wallet && UserSession.shared.isLoggedIn {
                        Text(walletVM.formattedBalance)
                            .font(.system(size: 10))
                            .foregroundStyle(canAfford ? Color.leafGreen : Color.errorRed)
                    }
                }
            }
            .padding(.horizontal, 12).padding(.vertical, 8)
            .frame(maxWidth: .infinity)
            .background(RoundedRectangle(cornerRadius: 10)
                .fill(isSelected ? Color.coffeeBrown : Color(.secondarySystemGroupedBackground)))
            .foregroundStyle(isSelected ? .white : .primary)
            .overlay(RoundedRectangle(cornerRadius: 10)
                .strokeBorder(isSelected ? Color.coffeeBrown : Color.coffeeBrown.opacity(0.2), lineWidth: 1))
        }
        .buttonStyle(.plain)
        .disabled(method == .wallet && !UserSession.shared.isLoggedIn)
    }

    // MARK: - Insufficient Balance Banner

    private var insufficientBalanceBanner: some View {
        HStack(spacing: 8) {
            Image(systemName: "exclamationmark.circle.fill").foregroundStyle(Color.errorRed)
            VStack(alignment: .leading, spacing: 1) {
                Text("Insufficient balance")
                    .font(.caption.weight(.semibold)).foregroundStyle(Color.errorRed)
                Text("Need \(cartManager.total.currencyFormatted) · have \(walletVM.formattedBalance)")
                    .font(.caption2).foregroundStyle(.secondary)
            }
            Spacer()
            Button {
                ToastManager.shared.show(message: "Top up your wallet first", type: .warning)
            } label: {
                Text("Top Up").font(.caption.weight(.bold)).foregroundStyle(Color.coffeeBrown)
            }
        }
        .padding(10)
        .background(Color.errorRed.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(RoundedRectangle(cornerRadius: 10).strokeBorder(Color.errorRed.opacity(0.25), lineWidth: 1))
    }

    // MARK: - Place Order

    private func confirmAndPlaceOrder() {
        let message = cartManager.paymentMethod == .wallet
            ? "\(cartManager.total.currencyFormatted) will be deducted from your wallet"
            : String(format: "Total: $%.2f — pay at the counter", cartManager.total)

        AlertManager.shared.showConfirmation(
            title: "Confirm Order",
            message: message,
            confirmTitle: "Place Order"
        ) {
            let payment = cartManager.paymentMethod
            orderService.placeOrder(
                cartItems: cartManager.items,
                total: cartManager.total,
                paymentMethod: payment
            ) {
                Task {
                    if let activeCard = cardVM.activeCard {
                        try? await cardVM.addPoints(to: activeCard, amount: 1)
                    }
                    if payment == .wallet, let userId = UserSession.shared.userId {
                        await walletVM.loadTransactions(userId: userId)
                    }
                }
                cartManager.clearCart(userId: UserSession.shared.userId ?? "")
                dismiss()
            }
        }
    }
}
