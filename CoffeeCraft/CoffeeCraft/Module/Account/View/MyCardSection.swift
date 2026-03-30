//
//  MyCardSection.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 3/30/26.
//

import SwiftUI

// MARK: - My Cards Section
struct MyCardSection: View {
    @EnvironmentObject var cardVM: CardViewModel
    @EnvironmentObject var userSession: UserSession
    @EnvironmentObject var authVM: AuthViewModel
    @Binding var isOpenAddCard: Bool
    @Binding var showAuth: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "creditcard.fill")
                    .font(.headline)
                    .foregroundColor(Color.textSecondary)
                Text("My Cards")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.textPrimary)
            }
            .padding(.leading, 4)
            
            VStack(alignment: .center) {
                HStack(spacing: 0) {
                    let cardWidth = (UIScreen.main.bounds.width * 0.8) - 32
                    if userSession.isLoggedIn {
                        if cardVM.isRefreshing || (cardVM.isLoading && cardVM.activeCard == nil) {
                            ShimmerView(cornerRadius: 10)
                                .frame(width: cardWidth, height: cardWidth / (16 / 9))
                        } else if let activeCard = cardVM.activeCard {
                            FlippableCardView(card: activeCard, width: cardWidth)
                        }
                    } else {
                        NavigationLink {
                            AuthView().environmentObject(authVM)
                        } label: {
                            CardEmptyView(title: "Log in to see your cards", cardWidth: cardWidth)
                        }
                    }
                    Spacer()
                    NavigationLink {
                        if userSession.isLoggedIn {
                            AllCardsView()
                                .environmentObject(cardVM)
                        } else {
                            AuthView().environmentObject(authVM)
                        }
                    } label: {
                        VStack {
                            ZStack {
                                Circle()
                                    .fill(Color.surfacePrimary)
                                    .frame(width: 50, height: 50)
                                    .shadow(color: Color.textPrimary.opacity(0.08), radius: 12, y: 4)
                                
                                Image(systemName: "arrow.right")
                                    .font(.headline)
                                    .foregroundColor(Color.textSecondary)
                            }
                            Text("See All")
                                .font(.subheadline)
                                .foregroundColor(.textPrimary)
                        }
                    }
                }
                HStack {
                    Button(action: {
                        if userSession.isLoggedIn {
                            AlertManager.shared.showWarning(title: "Coming Soon",
                                                            message: "This Feature will be coming soon.")
                        } else {
                            showAuth = true
                        }
                    }, label: {
                        VStack {
                            ZStack {
                                Circle()
                                    .fill(Color.accentPrimary)
                                    .frame(width: 50, height: 50)
                                
                                Image(systemName: "cart.badge.plus")
                                    .font(.headline)
                                    .foregroundColor(.textPrimary)
                                    .colorInvert()
                            }
                            Text("Purchase")
                                .font(.subheadline)
                                .foregroundColor(.textPrimary)
                        }
                    })
                    Button(action: {
                        if userSession.isLoggedIn {
                            isOpenAddCard = true
                        } else {
                            showAuth = true
                        }
                    }, label: {
                        VStack {
                            ZStack {
                                Circle()
                                    .fill(Color.surfacePrimary)
                                    .frame(width: 50, height: 50)
                                    .shadow(color: Color.textPrimary.opacity(0.08), radius: 12, y: 4)
                                
                                Image(systemName: "plus")
                                    .font(.headline)
                                    .foregroundColor(Color.textSecondary)
                            }
                            Text("Add")
                                .font(.subheadline)
                                .foregroundColor(.textPrimary)
                        }
                    })
                }
            }
        }
    }
}
