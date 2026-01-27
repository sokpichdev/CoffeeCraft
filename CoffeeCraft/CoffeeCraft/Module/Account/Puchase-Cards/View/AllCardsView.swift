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
    
    // MARK: - Minimal Card Row
    private func cardRow(card: LoyaltyCard) -> some View {
        VStack(spacing: 12) {
            // Status badge on TOP of card (only if shared)
            if !card.isOwnedByCurrentUser {
                Text("Shared")
                    .font(.caption2.weight(.medium))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(.blue)
                    .clipShape(Capsule())
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding(.trailing, 8)
            }
            
            FlippableCardView(
                card: card,
                width: cardWidth
            )
            
            if !card.isActiveForCurrentUser {
                Button("Activate") {
                    Task {
                        try await cardVM.setActiveCard(card)
                    }
                }
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.primary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(.ultraThinMaterial, in: Capsule())
            }
        }
    }
    
    // MARK: - Minimal Empty State
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
