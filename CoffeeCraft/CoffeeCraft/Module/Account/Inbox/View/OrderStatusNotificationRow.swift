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
            iconColor: .semanticSuccess
        ) {
            Text(notification.title)
                .font(.subheadline.bold())
                .foregroundColor(.textPrimary)
                .fixedSize(horizontal: false, vertical: true)

            Text(notification.message)
                .font(.caption)
                .foregroundColor(Color.textMuted)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}
