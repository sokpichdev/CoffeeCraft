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
    var onUpdateStatus: ((String) -> Void)?
    var onReorder: (() -> Void)?
    var onCancel: (() -> Void)?

    private var isCompleted: Bool {
        let status = order.status?.lowercased() ?? ""
        return status == "completed" || status == "done"
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
                        buttonImage: "cup.and.saucer.fill", bgColors: [.semanticSuccess], isDisabled: isUpdating) {
                        onUpdateStatus?("Ready") }
                } else if order.status == "Ready" {
                    CustomCoffeeButton(title: isUpdating ? "Updating..." : "Complete Order",
                        buttonImage: "checkmark.circle.fill", bgColors: [.accentPrimary], isDisabled: isUpdating) {
                        onUpdateStatus?("Completed") }
                }
            }

            if isCompleted {
                CustomCoffeeButton(title: "Reorder", buttonImage: "arrow.clockwise", bgColors: [.accentPrimary]) {
                    onReorder?() }
            }

            if canCancel {
                CustomCoffeeButton(
                    title: isCancelling ? "Cancelling..." : "Cancel Order",
                    buttonImage: isCancelling ? "" : "xmark.circle",
                    foregroundColor: .semanticError,
                    bgColors: [Color(.secondarySystemGroupedBackground)],
                    isDisabled: isCancelling
                ) { onCancel?() }
            }

            if isCancelled {
                HStack(spacing: 10) {
                    Image(systemName: "xmark.circle.fill").foregroundColor(Color.semanticError.opacity(0.8))
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Order Cancelled")
                            .font(.subheadline.weight(.semibold))
                            .foregroundColor(Color.semanticError)
                        if order.wasWalletPayment, let amount = order.walletAmountPaid {
                            Text("+\(amount.currencyFormatted) refunded to your wallet")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    Spacer()
                }
                .padding(14)
                .background(Color.semanticError.opacity(0.07))
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .strokeBorder(Color.semanticError.opacity(0.2), lineWidth: 1)
                )
            }
        }
    }
}
