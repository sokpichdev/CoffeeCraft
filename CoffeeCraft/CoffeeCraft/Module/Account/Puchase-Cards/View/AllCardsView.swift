//
//  AllCardsView.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 1/26/26.
//
import SwiftUI

struct AllCardsView: View {
    @EnvironmentObject var cardVM: CardViewModel
    @EnvironmentObject var authVM: AuthViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var isNavigateToPurchaseCard = false
    @State private var isNavigateToAddOtherCard = false

    @State private var showingShareSheet = false
    @State private var selectedCardForSharing: LoyaltyCard?
    
    @State private var snapshotCards: [LoyaltyCard] = []
    
    private let cardWidth: CGFloat = UIScreen.main.bounds.width - 32

    private var isShowingShimmer: Bool {
        (cardVM.isLoading && snapshotCards.isEmpty) || cardVM.isRefreshing
    }
    
    var body: some View {
        CustomRefreshScrollView( {
            VStack(spacing: 24) {
                if isShowingShimmer {
                    CardsShimmerView(width: cardWidth)
                } else if snapshotCards.isEmpty {
                    ownCardEmpty
                } else {
                    ForEach(snapshotCards) { card in
                        cardRow(card: card)
                    }
                    .transition(.opacity)
                }
                
                Spacer()
                    .frame(height: 100)
            }
            .padding()
        }, onRefresh: {
            if let userId = UserSession.shared.userId {
                cardVM.setUser(userId: userId, isRefresh: true)
            }
        })
        .background(Color.bgPrimary)
        .customNavigationBar("My Cards (\(snapshotCards.count))") {
            ToolBarButton.back {
                dismiss()
            }
            ToolBarButton(placement: .topBarTrailing, buttonType: .icon("cart.badge.plus")) {
                isNavigateToPurchaseCard = true
            }
            ToolBarButton(placement: .topBarTrailing, buttonType: .icon("plus")) {
                isNavigateToAddOtherCard = true
            }
            ToolBarButton(placement: .topBarTrailing, buttonType: .icon("square.and.arrow.up")) {
                if let firstOwned = cardVM.cards.first(where: { $0.isOwnedByCurrentUser }) {
                    selectedCardForSharing = firstOwned
                    showingShareSheet = true
                }
            }
        }
        .sheet(isPresented: $isNavigateToAddOtherCard) {
            NavigationStack {
                AddCardView()
                    .environmentObject(cardVM)
            }
        }
        .sheet(isPresented: $showingShareSheet) {
            if let card = selectedCardForSharing {
                ShareCardSheet(card: card)
                    .environmentObject(cardVM)
                    .environmentObject(authVM)
            }
        }
        .onChange(of: cardVM.activeCardNumber) { _, _ in
            // Re-apply access filter when active card changes
            snapshotCards = cardVM.cards.filter { $0.hasAccessForCurrentUser }
        }
        .onAppear {
            snapshotCards = cardVM.accessibleCards
        }
    }
    
    // MARK: - Card Row
    private func cardRow(card: LoyaltyCard) -> some View {
        VStack(spacing: 0) {
            // Top Status Badges
            if snapshotCards.count > 1 {
                HStack(spacing: 8) {
                    // Active Card Badge
                    if card.isActiveForCurrentUser {
                        StatusBadgeView(icon: "checkmark.circle.fill", text: "Active", bgColor: .semanticSuccess)
                    }
                    
                    // Ownership Status Badge
                    if card.isOwnedByCurrentUser {
                        StatusBadgeView(icon: "person.fill", text: "Owner", bgColor: Color.accentPrimary)
                    } else {
                        StatusBadgeView(icon: "person.2.fill", text: "Shared", bgColor: Color.borderColor)
                    }
                    Spacer()
                }
                .padding(.horizontal, 8)
                .padding(.bottom, 8)
            }

            FlippableCardView(card: card, width: cardWidth)
            
            // buttons
            HStack(spacing: 12) {
                if !card.isActiveForCurrentUser {
                    CustomCoffeeButton(title: "Activate",
                                       buttonImage: "checkmark.circle",
                                       bgColors: [Color.accentPrimary, Color.accentPrimary.opacity(0.6)]) {
                        Task {
                            try await cardVM.setActiveCard(card)
                        }
                    }
                }
                
                // Share Button (only for owned cards)
                if card.isOwnedByCurrentUser {
                    CustomCoffeeButton(
                        title: card.isActiveForCurrentUser ? "Share" : "",
                        buttonImage: "square.and.arrow.up",
                        foregroundColor: .textPrimary,
                        bgColors: [Color.surfaceSub],
                        horinzontalPadding: card.isActiveForCurrentUser ? 0 : 16,
                        maxWidth: card.isActiveForCurrentUser ? .infinity : nil
                    ) {
                        selectedCardForSharing = card
                        showingShareSheet = true
                    }
                }
            }
            .padding(.top, 12)
        }
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(card.isActiveForCurrentUser ? Color.accentPrimary.opacity(0.06) : Color.clear)
        )
    }
    
    private var ownCardEmpty: some View {
        Button {
            if let userId = UserSession.shared.userId, let userName = UserSession.shared.userName {
                Task {
                    try await cardVM.createInitialCard(userId: userId, userName: userName)
                }
            }
        } label: {
            CardEmptyView()
        }
        .buttonStyle(.plain)
    }
}

struct CardEmptyView: View {
    var title: String = "Create your own card"
    var cardWidth: CGFloat = UIScreen.main.bounds.width - 32
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "creditcard")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
                .opacity(0.6)

            Text(title)
                .font(.title2)
                .foregroundColor(.textPrimary)
        }
        .frame(width: cardWidth, height: cardWidth / (16 / 9))
        .background(
            RoundedRectangle(cornerRadius: 10)
                .strokeBorder(
                    style: StrokeStyle(lineWidth: 2, dash: [8])
                )
                .foregroundColor(.accentPrimary.opacity(0.4))
        )
        .contentShape(Rectangle())
    }
}

struct CardsShimmerView: View {
    var width: CGFloat = UIScreen.main.bounds.width - 32
    var body: some View {
        ForEach(0..<2) { _ in
            VStack(spacing: 0) {
                HStack(spacing: 8) {
                    ShimmerView()
                        .frame(width: 70, height: 30)
                        .clipShape(Capsule())
                    ShimmerView()
                        .frame(width: 70, height: 30)
                        .clipShape(Capsule())
                    Spacer()
                }
                .padding(.horizontal, 8)
                .padding(.bottom, 8)
                
                ShimmerView(cornerRadius: 16)
                    .frame(width: width, height: width / (16 / 9))
                
                ShimmerView()
                    .frame(width: width, height: 50)
                    .clipShape(Capsule())
                    .padding(.top, 12)
            }
            .padding(8)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color.accentPrimary.opacity(0.06))
            )
        }
    }
}
