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
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 16) {
                if !cardVM.cards.isEmpty {
                    ForEach(cardVM.cards.filter { $0.hasAccessForCurrentUser }) { card in
                        FlippableCardView(
                            card: card,
                            width: UIScreen.main.bounds.width - 32
                        )
                    }
                } else {
                    Text("No cards yet")
                        .foregroundColor(.secondary)
                }
            }
            .padding()
        }
        .customNavigationBar("My Cards") {
            ToolBarButton.back {
                dismiss()
            }
            ToolBarButton(placement: .topBarTrailing, buttonType: .icon("cart.badge.plus")) {
                isNavigateToPurchaseCard = true
            }
            ToolBarButton(placement: .topBarTrailing, buttonType: .icon("plus")) {
                isNavigateToAddCard = true
            }
        }
        .sheet(isPresented: $isNavigateToAddCard) {
            NavigationStack {
                AddCardView()
                    .environmentObject(cardVM)
            }
        }
        .task {
            cardVM.setUser(userId: authVM.currentUser?.id ?? "")
        }
    }
}
