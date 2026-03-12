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
    @EnvironmentObject var orderEnv: OrderEnvironment   // Phase 4 — clear after order
    @Environment(\.dismiss) private var dismiss

    @State private var editingItem: CartItem?
    @StateObject private var orderService = OrderService()
    @StateObject private var productVM = ProductViewModel()

    private var isDisableButton: Bool {
        cartManager.items.isEmpty || !cartManager.canCheckout(walletBalance: walletVM.wallet?.balance)
    }
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                CustomRefreshScrollView({
                    VStack(spacing: 12) {
                        // ── Branch info card (shown when a branch is selected) ──
                        if let branch = orderEnv.selectedBranch {
                            CartBranchInfoCard(branch: branch)
                        }

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
                            bgColors: [Color.semanticSuccess.opacity(0.85), Color.semanticSuccess],
                            isDisabled: isDisableButton
                        ) {
                            confirmAndPlaceOrder()
                        }
                        .padding(.bottom, 8)
                    }
                }
            }
            .background(Color.bgPrimary)
            .ignoresSafeArea(edges: .bottom)
            .sheet(item: $editingItem) { item in
                NavigationStack {
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
//            .task { await productVM.fetchProducts() }
        }
        .applyApiUIComponents()
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
                            .foregroundColor(canAfford ? Color.semanticSuccess : Color.semanticError)
                    }
                }
            }
            .padding(.horizontal, 12).padding(.vertical, 8)
            .frame(maxWidth: .infinity)
            .background(RoundedRectangle(cornerRadius: 10)
                .fill(isSelected ? Color.accentPrimary : Color(.secondarySystemGroupedBackground)))
            .foregroundColor(isSelected ? .white : .primary)
            .overlay(RoundedRectangle(cornerRadius: 10)
                .strokeBorder(isSelected ? Color.accentPrimary : Color.accentPrimary.opacity(0.2), lineWidth: 1))
        }
        .buttonStyle(.plain)
        .disabled(method == .wallet && !UserSession.shared.isLoggedIn)
    }

    // MARK: - Insufficient Balance Banner

    private var insufficientBalanceBanner: some View {
        HStack(spacing: 8) {
            Image(systemName: "exclamationmark.circle.fill").foregroundColor(Color.semanticError)
            VStack(alignment: .leading, spacing: 1) {
                Text("Insufficient balance")
                    .font(.caption.weight(.semibold)).foregroundColor(Color.semanticError)
                Text("Need \(cartManager.total.currencyFormatted) · have \(walletVM.formattedBalance)")
                    .font(.caption2).foregroundColor(.secondary)
            }
            Spacer()
            Button {
                ToastManager.shared.show(message: "Top up your wallet first", type: .warning)
            } label: {
                Text("Top Up").font(.caption.weight(.bold)).foregroundColor(Color.accentPrimary)
            }
        }
        .padding(10)
        .background(Color.semanticError.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(RoundedRectangle(cornerRadius: 10).strokeBorder(Color.semanticError.opacity(0.25), lineWidth: 1))
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
                }
                cartManager.clearCart(userId: UserSession.shared.userId ?? "")
                orderEnv.clear()   // Phase 4 — reset selected branch after order
                dismiss()
            }
        }
    }
}

// MARK: - CartBranchInfoCard

/// Displays the selected branch name and address at the top of the cart.
/// Shown whenever OrderEnvironment has a selectedBranch set.
struct CartBranchInfoCard: View {
    let branch: Branch

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.accentPrimary.opacity(0.12))
                    .frame(width: 44, height: 44)
                Image(systemName: "mappin.circle.fill")
                    .font(.system(size: 22, weight: .medium))
                    .foregroundColor(.accentPrimary)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text("Ordering from")
                    .font(.custom("Nunito-Regular", size: 11))
                    .foregroundColor(.textMuted)
                    .textCase(.uppercase)
                    .tracking(0.4)
                Text(branch.name)
                    .font(.custom("Nunito-Bold", size: 15))
                    .foregroundColor(.textPrimary)
                    .lineLimit(1)
                Text(branch.address)
                    .font(.custom("Nunito-Regular", size: 12))
                    .foregroundColor(.textSecondary)
                    .lineLimit(1)
            }

            Spacer()

            HStack(spacing: 4) {
                Circle()
                    .fill(branch.isOpen ? Color.semanticSuccess : Color.semanticError)
                    .frame(width: 7, height: 7)
                Text(branch.isOpen ? "Open" : "Closed")
                    .font(.custom("Nunito-SemiBold", size: 12))
                    .foregroundColor(branch.isOpen ? .semanticSuccess : .semanticError)
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.surfacePrimary)
                .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(Color.accentPrimary.opacity(0.2), lineWidth: 1)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Ordering from \(branch.name), \(branch.address), \(branch.isOpen ? "Open" : "Closed")")
    }
}
