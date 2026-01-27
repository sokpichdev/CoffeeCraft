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
    @State private var enteredUserId = ""
    
    private let cardWidth: CGFloat = UIScreen.main.bounds.width - 40
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                if cardVM.isLoading && cardVM.accessibleCards.isEmpty {
                    ProgressView()
                        .frame(height: 300)
                } else if cardVM.accessibleCards.isEmpty {
                    emptyStateView
                } else {
                    ForEach(cardVM.accessibleCards) { card in
                        cardRow(card: card)
                    }
                }
                
                Spacer()
                    .frame(height: 100)
            }
            .padding()
        }
        .customNavigationBar("My Cards (\(cardVM.accessibleCards.count))") {
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
            shareCardSheet
        }
        .task {
            cardVM.setUser(userId: authVM.currentUser?.id ?? "")
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
    
    // MARK: - Compact Status Badge
    private func statusBadge(for card: LoyaltyCard) -> some View {
        HStack(spacing: 4) {
            if card.isOwnedByCurrentUser {
                Image(systemName: "crown")
                    .font(.caption)
                    .foregroundStyle(.yellow)
            }
            
            if card.isActiveForCurrentUser {
                Text("ACTIVE")
                    .font(.caption2.weight(.medium))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(.green)
                    .clipShape(Capsule())
            } else {
                Text("Shared")
                    .font(.caption2.weight(.medium))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(.blue)
                    .clipShape(Capsule())
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
    
    // MARK: - Share Card Sheet (minimal)
    private var shareCardSheet: some View {
        NavigationStack {
            VStack(spacing: 24) {
                if let card = selectedCardForSharing {
                    VStack(spacing: 20) {
                        FlippableCardView(card: card, width: 300)
                        
                        VStack(spacing: 12) {
                            Text("Share this card")
                                .font(.headline)
                            
                            TextField("Friend's User ID", text: $enteredUserId)
                                .textFieldStyle(.roundedBorder)
                                .autocorrectionDisabled()
                                .textInputAutocapitalization(.never)
                            
                            Button("Share") {
                                Task {
                                    do {
                                        try await cardVM.shareCard(card, with: enteredUserId)
                                        enteredUserId = ""
                                        showingShareSheet = false
                                    } catch {
                                        print("Share error: \(error)")
                                    }
                                }
                            }
                            .font(.headline)
                            .buttonStyle(.borderedProminent)
                            .disabled(enteredUserId.isEmpty)
                        }
                    }
                }
                
                Spacer()
            }
            .padding()
            .presentationDetents([.medium, .large])
        }
    }
}
