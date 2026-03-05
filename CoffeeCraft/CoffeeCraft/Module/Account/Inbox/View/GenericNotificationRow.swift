//
//  GenericNotificationRow.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 2/21/26.
//
import SwiftUI

struct GenericNotificationRow: View { // for fallback
    let notification: AppNotification

    var body: some View {
        NotificationRowShell(
            notification: notification,
            icon: "bell.fill",
            iconColor: .brown
        ) {
            Text(notification.title)
                .font(.subheadline.bold())

            Text(notification.message)
                .font(.subheadline)
                .foregroundColor(.textSecondary)
                .lineLimit(2)
        }
    }
}
