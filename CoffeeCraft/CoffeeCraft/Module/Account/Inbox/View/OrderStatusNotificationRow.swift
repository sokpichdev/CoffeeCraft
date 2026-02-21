//
//  OrderStatusNotificationRow.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 2/21/26.
//
import SwiftUI

struct OrderStatusNotificationRow: View {
    let notification: AppNotification

    private var payload: OrderStatusPayload? { notification.orderStatusPayload }

    var body: some View {
        NotificationRowShell(
            notification: notification,
            icon: payload?.statusIcon ?? "clock.fill",
            iconColor: statusColor(payload?.status)
        ) {
            // Order ID — single, top aligned, subtle
            if let orderId = payload?.orderId {
                Text(orderId)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            // Title
            Text(notification.title)
                .font(.subheadline.bold())
                .foregroundColor(.primary)
                .fixedSize(horizontal: false, vertical: true)

            // Message
            Text(notification.message)
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private func statusColor(_ status: String?) -> Color {
        switch status {
        case "Preparing":  return .orange
        case "Ready":      return .green
        case "Completed":  return .brown
        case "Cancelled":  return .red
        default:           return .gray
        }
    }
}

 //
