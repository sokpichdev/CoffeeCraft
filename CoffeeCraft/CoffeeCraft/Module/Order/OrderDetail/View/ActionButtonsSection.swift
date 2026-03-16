//
//  ActionButtonsSection.swift
//  CoffeeCraft
//
//  nextStatus(isDelivery:) drives all transitions —
//  no hardcoded status strings, no duplicated switch.
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

    private var orderStatus: OrderStatus { order.orderStatus }
    private var canCancel: Bool {
        orderStatus == .pending && !isActive &&
        order.userId == UserSession.shared.userId
    }

    var body: some View {
        VStack(spacing: 12) {

            // - Manager progression ─
            if isActive && !orderStatus.isTerminal {
                managerProgressButton
            }

            // Reorder (customer, completed only) ─
            if orderStatus == .completed {
                CustomCoffeeButton(
                    title: "Reorder",
                    buttonImage: "arrow.clockwise",
                    bgColors: [.accentPrimary]
                ) { onReorder?() }
            }

            // Cancel (customer, pending only) ─
            if canCancel {
                CustomCoffeeButton(
                    title: isCancelling ? "Cancelling..." : "Cancel Order",
                    buttonImage: isCancelling ? "" : "xmark.circle",
                    foregroundColor: .semanticError,
                    bgColors: [Color(.secondarySystemGroupedBackground)],
                    isDisabled: isCancelling
                ) { onCancel?() }
            }

            // - Cancelled banner ─
            if orderStatus == .cancelled {
                HStack(spacing: 10) {
                    Image(systemName: OrderStatus.cancelled.icon)
                        .foregroundColor(Color.semanticError.opacity(0.8))
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Order Cancelled")
                            .font(.subheadline.weight(.semibold))
                            .foregroundColor(Color.semanticError)
                        if order.wasWalletPayment, let amount = order.walletAmountPaid {
                            Text("+\(amount.currencyFormatted) refunded to your wallet")
                                .font(.caption).foregroundColor(.secondary)
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

    // MARK: - Manager Progress Button

    @ViewBuilder
    private var managerProgressButton: some View {
        // nextStatus(isDelivery:) returns nil for terminal/unsupported states.
        if let next = orderStatus.nextStatus(isDelivery: order.isDeliveryOrder) {
            CustomCoffeeButton(
                title: isUpdating ? "Updating..." : buttonTitle(for: next),
                buttonImage: next.icon,
                bgColors: [buttonColor(for: next)],
                isDisabled: isUpdating
            ) { onUpdateStatus?(next.rawValue) }
        }
    }

    /// Button title for advancing to `next` — phrased as an action, not a state name.
    private func buttonTitle(for next: OrderStatus) -> String {
        switch next {
        case .inProgress: return "Start Preparing"
        case .ready: return "Mark as Ready"
        case .onDelivery: return "Dispatch Rider"
        case .completed: return order.isDeliveryOrder ? "Mark as Delivered" : "Complete Order"
        default: return next.displayLabel
        }
    }

    /// Button background color — matches the destination status color.
    private func buttonColor(for next: OrderStatus) -> Color {
        switch next {
        case .inProgress: return .orange
        case .ready: return .semanticSuccess
        case .onDelivery: return .blue
        case .completed: return .accentPrimary
        default: return .accentPrimary
        }
    }
}
