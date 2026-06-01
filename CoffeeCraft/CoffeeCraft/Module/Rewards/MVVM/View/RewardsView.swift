//
//  RewardsView.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 3/30/26.
//
//  Main Rewards screen — shows the active loyalty card, points progress,
//  and a live history of earned points.
//

import SwiftUI

struct RewardsView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var cardVM: CardViewModel
    @StateObject private var rewardsVM = RewardsViewModel()

    var body: some View {
        CustomRefreshScrollView({
            VStack(spacing: 24) {
                // MARK: - Active Card
                if let card = cardVM.activeCard {
                    FlippableCardView(card: card, width: UIScreen.main.bounds.width - 32)
                        .padding(.horizontal)
                } else {
                    noCardView
                }

                // MARK: - Points Progress
                if let card = cardVM.activeCard {
                    PointsProgressView(currentPoints: card.points)
                        .padding(.horizontal)
                }

                // MARK: - Points History
                VStack(alignment: .leading, spacing: 12) {
                    Label("Points History", systemImage: "clock.arrow.circlepath")
                        .font(.headline)
                        .foregroundColor(.accentPrimary)
                        .padding(.horizontal)

                    if rewardsVM.isLoadingHistory {
                        historySkeletonView
                    } else if rewardsVM.pointsHistory.isEmpty {
                        emptyHistoryView
                    } else {
                        VStack(spacing: 0) {
                            ForEach(rewardsVM.pointsHistory) { transaction in
                                PointsTransactionRow(transaction: transaction)
                                    .padding(.horizontal)
                                    .padding(.vertical, 4)

                                if transaction.id != rewardsVM.pointsHistory.last?.id {
                                    Divider()
                                        .padding(.horizontal)
                                }
                            }
                        }
                        .background(RoundedRectangle(cornerRadius: 16).fill(Color.surfacePrimary))
                        .padding(.horizontal)
                    }
                }

                Spacer(minLength: 32)
            }
            .padding(.top, 16)
        }, onRefresh: {
            // Listener auto-refreshes; nothing to pull-refresh manually
        })
        .background(Color.bgSecondary)
        .customNavigationBar("Rewards") {
            ToolBarButton.back { dismiss() }
        }
        .onAppear {
            if let userId = UserSession.shared.userId {
                rewardsVM.setup(userId: userId)
            }
        }
        .onDisappear {
            rewardsVM.teardown()
        }
    }

    // MARK: - Subviews

    private var noCardView: some View {
        VStack(spacing: 12) {
            Image(systemName: "creditcard.and.123")
                .font(.system(size: 48))
                .foregroundColor(.textSecondary)
            Text("No active loyalty card")
                .font(.headline)
                .foregroundColor(.textSecondary)
            Text("Add a card from your Account to start earning points.")
                .font(.caption)
                .foregroundColor(.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(32)
        .background(RoundedRectangle(cornerRadius: 16).fill(Color.surfacePrimary))
        .padding(.horizontal)
    }

    private var emptyHistoryView: some View {
        VStack(spacing: 8) {
            Image(systemName: "star.slash")
                .font(.system(size: 32))
                .foregroundColor(.textSecondary)
            Text("No points earned yet")
                .font(.subheadline)
                .foregroundColor(.textSecondary)
            Text("Complete an order to start earning loyalty points.")
                .font(.caption)
                .foregroundColor(.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(32)
        .background(RoundedRectangle(cornerRadius: 16).fill(Color.surfacePrimary))
        .padding(.horizontal)
    }

    private var historySkeletonView: some View {
        VStack(spacing: 12) {
            ForEach(0..<4, id: \.self) { _ in
                HStack(spacing: 12) {
                    ShimmerView()
                        .frame(width: 36, height: 36)
                        .clipShape(Circle())
                    VStack(alignment: .leading, spacing: 6) {
                        ShimmerView().frame(width: 160, height: 14).cornerRadius(4)
                        ShimmerView().frame(width: 80, height: 11).cornerRadius(4)
                    }
                    Spacer()
                    ShimmerView().frame(width: 60, height: 28).clipShape(Capsule())
                }
                .padding(.horizontal)
            }
        }
        .padding(.vertical, 12)
        .background(RoundedRectangle(cornerRadius: 16).fill(Color.surfacePrimary))
        .padding(.horizontal)
    }
}
