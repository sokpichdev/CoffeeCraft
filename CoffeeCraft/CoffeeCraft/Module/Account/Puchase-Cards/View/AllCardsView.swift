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
    @State private var isNavigateToAddCard = false
    @State private var showingShareSheet = false
    @State private var selectedCardForSharing: LoyaltyCard?
    
    @State private var snapshotCards: [LoyaltyCard] = []
    
    private let cardWidth: CGFloat = UIScreen.main.bounds.width - 32
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                if cardVM.isLoading && snapshotCards.isEmpty {
                    ProgressView()
                        .frame(height: 300)
                } else if snapshotCards.isEmpty {
                    emptyStateView
                } else {
                    // prevents refresh during swipe
                    ForEach(snapshotCards) { card in
                        cardRow(card: card)
                    }
                }
                
                Spacer()
                    .frame(height: 100)
            }
            .padding()
        }
        .customNavigationBar("My Cards (\(snapshotCards.count))") {
            ToolBarButton.back {
                dismiss()
            }
            ToolBarButton(placement: .topBarTrailing, buttonType: .icon("cart.badge.plus")) {
                isNavigateToPurchaseCard = true
            }
            ToolBarButton(placement: .topBarTrailing, buttonType: .icon("plus")) {
                isNavigateToAddCard = true
            }
            ToolBarButton(placement: .topBarTrailing, buttonType: .icon("square.and.arrow.up")) {
                if let firstOwned = cardVM.cards.first(where: { $0.isOwnedByCurrentUser }) {
                    selectedCardForSharing = firstOwned
                    showingShareSheet = true
                }
            }
        }
        .sheet(isPresented: $isNavigateToAddCard) {
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
                        StatusBadgeView(icon: "checkmark.circle.fill", text: "Active", bgColor: .coffeeOliveGreen)
                    }
                    
                    // Ownership Status Badge
                    if card.isOwnedByCurrentUser {
                        StatusBadgeView(icon: "person.fill", text: "Owner", bgColor: Color.coffeeLight)
                    } else {
                        StatusBadgeView(icon: "person.2.fill",text: "Shared", textColor: .black, bgColor: Color.coffeeCream)
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 8)
                .padding(.bottom, 8)
            }

            FlippableCardView(card: card,  width: cardWidth)
            
            // buttons
            HStack(spacing: 12) {
                // Activate Button
                if !card.isActiveForCurrentUser {
                    CustomCoffeeButton(title: "Activate", buttonImage: "checkmark.circle", bgColors: [Color.coffeeBrown, Color.coffeeLight]){
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
                        foregroundColor: .coffeeCream,
                        bgColors: [Color(.secondarySystemGroupedBackground)],
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
                .fill(card.isActiveForCurrentUser ? Color.coffeeBrown.opacity(0.06) : Color.clear)
        )
    }
    
    // MARK: - Empty State
    private var emptyStateView: some View {
        VStack(spacing: 24) {
            Image(systemName: "creditcard")
                .font(.system(size: 80))
                .foregroundStyle(.secondary)
                .opacity(0.5)
            
            VStack(spacing: 8) {
                Text("No Cards")
                    .font(.largeTitle.weight(.semibold))
                
                Button("Add Card") {
                    isNavigateToAddCard = true
                }
                .font(.headline)
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
            }
        }
        .frame(maxHeight: .infinity)
    }
}
