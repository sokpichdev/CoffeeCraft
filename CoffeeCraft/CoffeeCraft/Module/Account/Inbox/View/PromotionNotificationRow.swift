//
//  PromotionNotificationRow.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 2/21/26.
//
import SwiftUI

struct PromotionNotificationRow: View {
    let notification: AppNotification

    var body: some View {
        NotificationRowShell(
            notification: notification,
            icon: "tag.fill",
            iconColor: .purple
        ) {
            Text(notification.title)
                .font(.subheadline.bold())

            Text(notification.message)
                .font(.subheadline)
                .foregroundColor(.textSecondary)
                .lineLimit(2)

            if let code = notification.promotionPayload?.discountCode {
                HStack(spacing: 6) {
                    Image(systemName: "ticket.fill")
                        .font(.caption)
                    Text(code)
                        .font(.caption.monospaced().bold())
                }
                .foregroundColor(.purple)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(Color.accentPrimary.opacity(0.1))
                .clipShape(Capsule())
                .padding(.top, 2)
            }
        }
    }
}
