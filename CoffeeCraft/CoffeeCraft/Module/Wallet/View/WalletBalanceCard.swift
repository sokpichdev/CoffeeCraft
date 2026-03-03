//
//  WalletBalanceCard.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 03/03/2026.
//

import SwiftUI

struct WalletBalanceCard: View {
    let wallet: Wallet?
    let isLoading: Bool
    let onTopUp: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                LinearGradient(
                    colors: [Color.coffeeDarkBrown, Color.coffeeBrown, Color.coffeeWarmBrown],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                Circle()
                    .fill(Color.white.opacity(0.06))
                    .frame(width: 180, height: 180)
                    .offset(x: 100, y: -60)
                Circle()
                    .fill(Color.white.opacity(0.04))
                    .frame(width: 120, height: 120)
                    .offset(x: -80, y: 60)
                VStack(spacing: 16) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("CoffeeCoins Balance")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundStyle(Color.white.opacity(0.75))
                            if isLoading && wallet == nil {
                                ShimmerView(cornerRadius: 8)
                                    .frame(width: 140, height: 44)
                            } else {
                                Text(wallet?.formattedBalance ?? "0 CC")
                                    .font(.system(size: 42, weight: .bold, design: .rounded))
                                    .foregroundStyle(.white)
                                    .contentTransition(.numericText())
                                    .animation(.spring(duration: 0.4), value: wallet?.balance)
                            }
                        }
                        Spacer()
                        Image(systemName: "cup.and.saucer.fill")
                            .font(.system(size: 36))
                            .foregroundStyle(Color.white.opacity(0.25))
                    }
                    if let wallet {
                        HStack(spacing: 0) {
                            statItem(label: "Topped Up", value: "\(Int(wallet.totalTopUp)) CC")
                            Divider()
                                .frame(height: 28)
                                .overlay(Color.white.opacity(0.2))
                            statItem(label: "Spent", value: "\(Int(wallet.totalSpent)) CC")
                        }
                        .padding(.vertical, 10)
                        .padding(.horizontal, 12)
                        .background(Color.white.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
                .padding(24)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 200)
            .clipShape(RoundedRectangle(cornerRadius: 20))

            CustomCoffeeButton(
                title: "Top Up",
                buttonImage: "plus.circle.fill",
                bgColors: [Color.coffeeBrown, Color.coffeeLight]
            ) { onTopUp() }
            .padding(.top, 14)
        }
    }

    private func statItem(label: String, value: String) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.subheadline).fontWeight(.semibold).foregroundStyle(.white)
            Text(label)
                .font(.caption2).foregroundStyle(Color.white.opacity(0.65))
        }
        .frame(maxWidth: .infinity)
    }
}
