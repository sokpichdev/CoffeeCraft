//
//  ActionButtonsSection.swift
//  CoffeeCraft
//
//  Updated: branched manager flow for pickup vs delivery.
//  Pickup:   Pending → InProgress → Ready → Completed
//  Delivery: Pending → InProgress → Ready → OnDelivery → Completed
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

    // MARK: - Helpers

    private var isCompleted: Bool {
        let s = order.status?.lowercased() ?? ""
        return s == "completed" || s == "done"
    }
    private var isCancelled: Bool { order.status?.lowercased() == "cancelled" }
    private var canCancel: Bool {
        order.status == "Pending" && !isActive &&
        order.userId == UserSession.shared.userId
    }

    // MARK: - Body

    var body: some View {
        VStack(spacing: 12) {

            // ── Manager progression buttons ─────────────────────────
            if isActive && !isCompleted && !isCancelled {
                managerProgressButton
            }

            // ── Reorder (customer, completed only) ──────────────────
            if isCompleted {
                CustomCoffeeButton(
                    title: "Reorder",
                    buttonImage: "arrow.clockwise",
                    bgColors: [.accentPrimary]
                ) { onReorder?() }
            }

            // ── Cancel (customer, Pending only) ─────────────────────
            if canCancel {
                CustomCoffeeButton(
                    title: isCancelling ? "Cancelling..." : "Cancel Order",
                    buttonImage: isCancelling ? "" : "xmark.circle",
                    foregroundColor: .semanticError,
                    bgColors: [Color(.secondarySystemGroupedBackground)],
                    isDisabled: isCancelling
                ) { onCancel?() }
            }

            // ── Cancelled state banner ───────────────────────────────
            if isCancelled {
                HStack(spacing: 10) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(Color.semanticError.opacity(0.8))
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

    // MARK: - Manager progression button (branched by order type)

    @ViewBuilder
    private var managerProgressButton: some View {
        let status = order.status ?? ""
        let isDelivery = order.isDeliveryOrder

        if status == "Pending" {
            CustomCoffeeButton(
                title: isUpdating ? "Updating..." : "Start Preparing",
                buttonImage: "flame.fill",
                bgColors: [.orange],
                isDisabled: isUpdating
            ) { onUpdateStatus?("InProgress") }

        } else if status == "InProgress" {
            CustomCoffeeButton(
                title: isUpdating ? "Updating..." : "Mark as Ready",
                buttonImage: "cup.and.saucer.fill",
                bgColors: [.semanticSuccess],
                isDisabled: isUpdating
            ) { onUpdateStatus?("Ready") }

        } else if status == "Ready" && isDelivery {
            // Delivery: Ready → OnDelivery (hand off to rider)
            CustomCoffeeButton(
                title: isUpdating ? "Updating..." : "Dispatch Rider",
                buttonImage: "bicycle",
                bgColors: [.blue],
                isDisabled: isUpdating
            ) { onUpdateStatus?("OnDelivery") }

        } else if status == "Ready" && !isDelivery {
            // Pickup: Ready → Completed (customer collected)
            CustomCoffeeButton(
                title: isUpdating ? "Updating..." : "Complete Order",
                buttonImage: "checkmark.circle.fill",
                bgColors: [.accentPrimary],
                isDisabled: isUpdating
            ) { onUpdateStatus?("Completed") }

        } else if status == "OnDelivery" {
            // Delivery: OnDelivery → Completed (rider confirmed drop-off)
            CustomCoffeeButton(
                title: isUpdating ? "Updating..." : "Mark as Delivered",
                buttonImage: "bag.fill",
                bgColors: [.accentPrimary],
                isDisabled: isUpdating
            ) { onUpdateStatus?("Completed") }
        }
    }
}
