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
    let cardWidth: CGFloat
    let onTopUp: () -> Void

    
    private var cardHeight: CGFloat {
        cardWidth / (16 / 9)
    }
    
    private var balanceHeight: CGFloat {
        cardHeight * 0.75
    }
    
    private var actionHeight: CGFloat {
        cardHeight * 0.25
    }

    private let cornerRadius: CGFloat = 28
    private let horizontalPad: CGFloat = 24

    @State private var appear = false
    @State private var buttonPressed = false

    var body: some View {
        ZStack {
            background
            decorativeRings

            VStack(spacing: 0) {
                balanceSection
                    .padding(.horizontal, horizontalPad)
                    .frame(maxWidth: .infinity, maxHeight: (balanceHeight), alignment: .topLeading)

                quickTopUpShelf
                    .frame(height: actionHeight)
                    .frame(maxWidth: .infinity)

            }
            .frame(width: cardWidth, height: cardHeight)
        }
        .frame(width: cardWidth, height: cardHeight)
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
        .shadow(color: Color(hex: "#1C0A00").opacity(0.4), radius: 24, x: 0, y: 12)
        .scaleEffect(appear ? 1 : 0.96)
        .opacity(appear ? 1 : 0)
        .onAppear {
            withAnimation(.spring(response: 0.55, dampingFraction: 0.8).delay(0.08)) {
                appear = true
            }
        }
    }

    private var background: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .fill(
                LinearGradient(
                    colors: [
                        Color(hex: "#1C0A00"),
                        Color(hex: "#3B1A08"),
                        Color(hex: "#6F3A1F")
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
    }

    private var decorativeRings: some View {
        ZStack {
            Circle()
                .strokeBorder(Color.white.opacity(0.055), lineWidth: 55)
                .frame(width: 270, height: 270)
                .offset(x: 110, y: -90)

            Circle()
                .strokeBorder(Color.white.opacity(0.035), lineWidth: 36)
                .frame(width: 150, height: 150)
                .offset(x: -70, y: 60)
        }
    }

    private var balanceSection: some View {
        VStack(alignment: .leading, spacing: 0) {

            // Label + icon
            HStack(alignment: .bottom) {
                Text("MY WALLET")
                    .font(.system(size: balanceHeight * 0.2 * 0.3, weight: .bold, design: .rounded))
                    .minimumScaleFactor(0.5)
                    .tracking(2.8)
                    .foregroundStyle(Color.white.opacity(0.45))

                Spacer()

//                Image(systemName: "cup.and.saucer.fill")
//                    .font(.system(size: balanceHeight * 0.2 * 0.8))
//                    .foregroundStyle(Color(hex: "#D4956A").opacity(0.35))
            }
            .frame(height: balanceHeight * 0.2)

            // Balance
            Text(wallet?.formattedBalance ?? "$0.00")
                .font(.system(size: balanceHeight * 0.4 * 0.8, weight: .heavy, design: .rounded))
                .foregroundStyle(.white)
                .contentTransition(.numericText())
                .animation(.spring(duration: 0.5), value: wallet?.balance)
                .frame(height: balanceHeight * 0.4)


            // Stats pill
            if let wallet {
                miniStatPill(wallet: wallet)
                    .frame(height: balanceHeight * 0.35)
            }
        }
        .frame(height: balanceHeight)
    }

    private func miniStatPill(wallet: Wallet) -> some View {
        HStack(spacing: 0) {
            miniStat(icon: "arrow.down", label: "Topped Up",
                     value: wallet.totalTopUp.currencyFormatted, color: Color(hex: "#7EC8A4"))
            Rectangle()
                .fill(Color.white.opacity(0.12))
                .frame(width: 1, height: 26)
            miniStat(icon: "arrow.up", label: "Spent",
                     value: wallet.totalSpent.currencyFormatted, color: Color(hex: "#E07070"))
        }
        .padding(.vertical, 9)
        .padding(.horizontal, 12)
        .frame(height: balanceHeight * 0.35)
        .background(Color.white.opacity(0.07))
        .clipShape(RoundedRectangle(cornerRadius: 11))
        .overlay(
            RoundedRectangle(cornerRadius: 11)
                .strokeBorder(Color.white.opacity(0.09), lineWidth: 1)
        )
    }

    private func miniStat(icon: String, label: String, value: String, color: Color) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(color)
                .frame(width: 18, height: 18)
                .background(color.opacity(0.18))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 1) {
                Text(value)
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                Text(label)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(Color.white.opacity(0.45))
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: balanceHeight * 0.4 * 0.9)
    }

    private var quickTopUpShelf: some View {
        Button(action: {
            withAnimation(.spring(response: 0.2, dampingFraction: 0.6)) {
                buttonPressed = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                withAnimation(.spring(response: 0.25)) { buttonPressed = false }
                onTopUp()
            }
        }) {
            HStack(spacing: 0) {
                // Left hint
                HStack(spacing: 6) {
                    Image(systemName: "bolt.fill")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(Color(hex: "#D4956A"))
                    Text("Quick Top-Up")
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color.white.opacity(0.5))
                }

                Spacer()

                // Caramel pill CTA
                HStack(spacing: 7) {
                    Image(systemName: "plus")
                        .font(.system(size: 12, weight: .black))
                    Text("Add Funds")
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                }
                .foregroundStyle(Color(hex: "#1C0A00"))
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    LinearGradient(
                        colors: [Color(hex: "#E8C49A"), Color(hex: "#D4956A")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .clipShape(Capsule())
                .shadow(color: Color(hex: "#D4956A").opacity(0.5), radius: 5, x: 0, y: 2)
                .scaleEffect(buttonPressed ? 0.93 : 1.0)
            }
            .padding(.horizontal, horizontalPad)
            .frame(height: actionHeight)
            .background(
                LinearGradient(
                    colors: [Color.white.opacity(0.06), Color.white.opacity(0.02)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
        }
        .buttonStyle(.plain)
    }
}
