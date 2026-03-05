//
//  PricingCard.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 2/24/26.
//

import SwiftUI

struct PricingCard: View {
    let totalPrice: Double
    let items: [CartItemData]
    var paymentMethod: String? = nil
    var walletAmountPaid: Double? = nil

    var subtotal: Double { items.reduce(0) { $0 + ($1.price ?? 0.0) } }
    var tax: Double { totalPrice - subtotal }

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Payment Summary").font(.title3).fontWeight(.bold).foregroundColor(.textPrimary)
                Spacer()
            }
            VStack(spacing: 12) {
                PriceRow(label: "Subtotal", value: subtotal)
                PriceRow(label: "Tax & Fees", value: tax, color: .secondary)
                Divider().background(Color.secondary.opacity(0.2)).padding(.vertical, 4)
                HStack {
                    Text("Total").font(.title3).fontWeight(.bold).foregroundColor(.textPrimary)
                    Spacer()
                    Text("\(totalPrice, specifier: "%.2f") USD").font(.title2).fontWeight(.bold)
                }
                if let method = paymentMethod {
                    Divider().background(Color.secondary.opacity(0.2))
                    paymentRow(method)
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color(.secondarySystemGroupedBackground))
                .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 4)
        )
    }

    @ViewBuilder
    private func paymentRow(_ method: String) -> some View {
        let isWallet = method == PaymentMethod.wallet.rawValue
        HStack(spacing: 8) {
            Image(systemName: isWallet ? "creditcard.fill" : "banknote")
                .font(.caption).foregroundStyle(isWallet ? Color.accentPrimary : Color.secondary)
            Text(isWallet ? "Paid with Wallet" : "Pay at Counter")
                .font(.caption).foregroundStyle(.secondary)
            Spacer()
            if isWallet, let amount = walletAmountPaid {
                Text(amount.currencyFormatted).font(.caption.weight(.bold)).foregroundStyle(Color.accentPrimary)
            }
        }
        .padding(.top, 2)
    }
}

struct PriceRow: View {
    let label: String
    let value: Double
    var color: Color = .primary
    var body: some View {
        HStack {
            Text(label).font(.subheadline).foregroundColor(color)
            Spacer()
            Text("\(value, specifier: "%.2f") USD").font(.subheadline).fontWeight(.medium).foregroundColor(color)
        }
    }
}
