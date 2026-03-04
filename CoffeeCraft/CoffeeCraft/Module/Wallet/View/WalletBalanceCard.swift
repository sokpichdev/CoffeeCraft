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

    @State private var appear = false
    @State private var buttonPressed = false

    var body: some View {
        ZStack(alignment: .bottom) {
            RoundedRectangle(cornerRadius: 28)
                .fill(
                    LinearGradient(
                        colors: [Color(hex: "#1C0A00"), Color(hex: "#3B1A08"), Color(hex: "#6F3A1F")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            // Decorative coffee rings
            Circle()
                .strokeBorder(Color.white.opacity(0.055), lineWidth: 55)
                .frame(width: 270, height: 270)
                .offset(x: 110, y: -90)

            Circle()
                .strokeBorder(Color.white.opacity(0.035), lineWidth: 36)
                .frame(width: 150, height: 150)
                .offset(x: -70, y: 60)

            // Main content
            VStack(alignment: .leading, spacing: 0) {

                // Top section: label + balance + stats
                VStack(alignment: .leading, spacing: 16) {
                    balanceView
                    miniStatView
                }
                .padding(.horizontal, 24)
                .padding(.top, 26)
                .padding(.bottom, 20)

                // Hairline divider
                Rectangle()
                    .fill(Color.white.opacity(0.08))
                    .frame(height: 1)

                quickTopUp
            }
        }
//        .frame(maxWidth: .infinity)
//        .frame(height: 230)
        .clipShape(RoundedRectangle(cornerRadius: 28))
        .shadow(color: Color(hex: "#1C0A00").opacity(0.4), radius: 24, x: 0, y: 12)
        .scaleEffect(appear ? 1 : 0.96)
        .opacity(appear ? 1 : 0)
        .onAppear {
            withAnimation(.spring(response: 0.55, dampingFraction: 0.8).delay(0.08)) {
                appear = true
            }
        }
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
    }
    
    @ViewBuilder
    var balanceView: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                Text("MY WALLET")
                    .font(.system(size: 10, weight: .bold, design: .rounded))
                    .tracking(2.8)
                    .foregroundStyle(Color.white.opacity(0.45))

                if isLoading && wallet == nil {
                    ShimmerView(cornerRadius: 8)
                        .frame(width: 150, height: 46)
                        .padding(.top, 2)
                } else {
                    Text(wallet?.formattedBalance ?? "$0.00")
                        .font(.system(size: 44, weight: .heavy, design: .rounded))
                        .foregroundStyle(.white)
                        .contentTransition(.numericText())
                        .animation(.spring(duration: 0.5), value: wallet?.balance)
                }
            }

            Spacer()

            Image(systemName: "cup.and.saucer.fill")
                .font(.system(size: 28))
                .foregroundStyle(Color(hex: "#D4956A").opacity(0.35))
                .offset(y: 4)
        }
    }
    
    @ViewBuilder
    var miniStatView: some View {
        // Mini stats
        if let wallet {
            HStack(spacing: 0) {
                miniStat(
                    icon: "arrow.down",
                    label: "Topped Up",
                    value: wallet.totalTopUp.currencyFormatted,
                    color: Color(hex: "#7EC8A4")
                )
                Rectangle()
                    .fill(Color.white.opacity(0.12))
                    .frame(width: 1, height: 28)
                miniStat(
                    icon: "arrow.up",
                    label: "Spent",
                    value: wallet.totalSpent.currencyFormatted,
                    color: Color(hex: "#E07070")
                )
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 14)
            .background(Color.white.opacity(0.07))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(Color.white.opacity(0.09), lineWidth: 1)
            )
        }
    }
    @ViewBuilder
    var quickTopUp: some View {
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
                // Left: hint label
                HStack(spacing: 6) {
                    Image(systemName: "bolt.fill")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(Color(hex: "#D4956A"))
                    Text("Quick Top-Up")
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color.white.opacity(0.5))
                }

                Spacer()

                // Right: caramel pill — extra trailing clearance avoids clip
                HStack(spacing: 7) {
                    Image(systemName: "plus")
                        .font(.system(size: 13, weight: .black))
                    Text("Add Funds")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                }
                .foregroundStyle(Color(hex: "#1C0A00"))
                .padding(.horizontal, 18)
                .padding(.vertical, 10)
                .background(
                    LinearGradient(
                        colors: [Color(hex: "#E8C49A"), Color(hex: "#D4956A")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .clipShape(Capsule())
                // Shadow radius kept small so it doesn't bleed past the card edge
                .shadow(color: Color(hex: "#D4956A").opacity(0.5), radius: 6, x: 0, y: 3)
                .scaleEffect(buttonPressed ? 0.93 : 1.0)
            }
            // ↓ key fix: generous trailing padding keeps pill away from the clip edge
            .padding(.leading, 20)
            .padding(.trailing, 22)
            .padding(.vertical, 14)
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
