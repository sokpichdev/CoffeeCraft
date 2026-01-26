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
    
    @State var isNavigateToPurchaseCard: Bool = false
    @State var isNavigateToAddCard: Bool = false
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack {
                if !cardVM.userCards.isEmpty, let activeCardDetail = cardVM.activeCardDetails {
                    ForEach(cardVM.userCards) { card in
                        FlippableCardView(
                            activeCard: card,
                            activeCardDetails: activeCardDetail,
                            width: UIScreen.main.bounds.width - 32)
                    }
                }
            }
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
    }
}
