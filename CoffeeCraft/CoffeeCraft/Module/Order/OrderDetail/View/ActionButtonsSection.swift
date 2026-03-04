//
//  ActionButtonsSection.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 2/24/26.
//

import SwiftUI

struct ActionButtonsSection: View {
    let order: Order
    let isActive: Bool
    var isUpdating: Bool = false
    var isCancelling: Bool = false
    var onUpdateStatus: ((String) -> Void)? = nil
    var onReorder: (() -> Void)? = nil
    var onCancel: (() -> Void)? = nil

    private var isCompleted: Bool {
        let s = order.status?.lowercased() ?? ""
        return s == "completed" || s == "done"
    }
    private var isCancelled: Bool { order.status?.lowercased() == "cancelled" }
    private var canCancel: Bool {
        order.status == "Pending" && !isActive && order.userId == UserSession.shared.userId
    }

    var body: some View {
        VStack(spacing: 12) {

            if isActive && !isCompleted && !isCancelled {
                if order.status == "Pending" {
                    CustomCoffeeButton(title: isUpdating ? "Updating..." : "Start Preparing",
                        buttonImage: "flame.fill", bgColors: [.orange], isDisabled: isUpdating) {
                        onUpdateStatus?("InProgress") }
                } else if order.status == "InProgress" {
                    CustomCoffeeButton(title: isUpdating ? "Updating..." : "Mark as Ready",
                        buttonImage: "cup.and.saucer.fill", bgColors: [.coffeeOliveGreen], isDisabled: isUpdating) {
                        onUpdateStatus?("Ready") }
                } else if order.status == "Ready" {
                    CustomCoffeeButton(title: isUpdating ? "Updating..." : "Complete Order",
                        buttonImage: "checkmark.circle.fill", bgColors: [.coffeeDarkBrown], isDisabled: isUpdating) {
                        onUpdateStatus?("Completed") }
                }
            }

            if isCompleted {
                CustomCoffeeButton(title: "Reorder", buttonImage: "arrow.clockwise", bgColors: [.brown]) {
                    onReorder?() }
            }

            if canCancel {
                CustomCoffeeButton(
                    title: isCancelling ? "Cancelling..." : "Cancel Order",
                    buttonImage: isCancelling ? "" : "xmark.circle",
                    foregroundColor: .errorRed,
                    bgColors: [Color(.secondarySystemGroupedBackground)],
                    isDisabled: isCancelling
                ) { onCancel?() }
            }

            if isCancelled {
                HStack(spacing: 10) {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(Color.errorRed.opacity(0.8))
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Order Cancelled").font(.subheadline.weight(.semibold)).foregroundStyle(Color.errorRed)
                        if order.wasWalletPayment, let amount = order.walletAmountPaid {
                            Text("+\(amount.currencyFormatted) refunded to your wallet").font(.caption).foregroundStyle(.secondary)
                        }
                    }
                    Spacer()
                }
                .padding(14)
                .background(Color.errorRed.opacity(0.07))
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(Color.errorRed.opacity(0.2), lineWidth: 1))
            }
        }
    }
}
