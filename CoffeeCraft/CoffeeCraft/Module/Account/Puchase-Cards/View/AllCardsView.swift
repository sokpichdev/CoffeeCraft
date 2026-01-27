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
    
    // MARK: - Individual Card Row (BIG SIZE)
    private func cardRow(card: LoyaltyCard) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header with status badges
            HStack {
                Text(card.isActiveForCurrentUser ? "Active Card" : card.displayName)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                // Status badges
                HStack(spacing: 6) {
                    if card.isOwnedByCurrentUser {
                        Image(systemName: "crown.fill")
                            .foregroundStyle(.yellow)
                            .font(.caption)
                    }
                    
                    Text(card.isActiveForCurrentUser ? "ACTIVE" : "Shared")
                        .font(.caption)
                        .fontWeight(.medium)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            card.isActiveForCurrentUser ?
                            Color.green.opacity(0.2) :
                            Color.blue.opacity(0.2)
                        )
                        .foregroundStyle(
                            card.isActiveForCurrentUser ?
                            .green :
                            .blue
                        )
                        .cornerRadius(8)
                }
            }
            
            // BIG FlippableCardView
            FlippableCardView(
                card: card,
                width: cardWidth
            )
            
            // Points and action row
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(card.points) points")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(.primary)
                    
                    Text(card.memberSince)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                // Action button
                if card.isActiveForCurrentUser {
                    Text("Active ✓")
                        .font(.headline)
                        .foregroundStyle(.green)
                } else {
                    Button("Make Active") {
                        Task {
                            try await cardVM.setActiveCard(card)
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.blue)
                }
            }
        }
        .padding(16)
        .background(Color(.systemGray6))
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
    }
    
    // MARK: - Empty State
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "creditcard")
                .font(.system(size: 80))
                .foregroundStyle(.secondary)
            
            Text("No Cards Yet")
                .font(.largeTitle)
                .fontWeight(.semibold)
            
            Text("Add your first loyalty card to start earning points")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button("Add Card") {
                isNavigateToAddCard = true
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
        .frame(maxHeight: .infinity)
    }
    
    // MARK: - Share Card Sheet (unchanged)
    private var shareCardSheet: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Share Card")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                if let card = selectedCardForSharing {
                    FlippableCardView(card: card, width: 280)
                        .padding()
                    
                    VStack(spacing: 12) {
                        Text("Share with friend")
                            .font(.headline)
                        
                        TextField("Friend's User ID", text: $enteredUserId)
                            .textFieldStyle(.roundedBorder)
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.never)
                        
                        Button("Share Card") {
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
                        .buttonStyle(.borderedProminent)
                        .disabled(enteredUserId.isEmpty)
                    }
                }
                
                Spacer()
            }
            .padding()
            .customNavigationBar("Share Card") {
                ToolBarButton.back {
                    showingShareSheet = false
                }
            }
        }
    }
}
