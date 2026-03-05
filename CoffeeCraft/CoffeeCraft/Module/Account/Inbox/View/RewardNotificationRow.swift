//
//  RewardNotificationRow.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 2/21/26.
//
import SwiftUI

struct RewardNotificationRow: View {
    let notification: AppNotification

    var body: some View {
        NotificationRowShell(
            notification: notification,
            icon: "star.fill",
            iconColor: .orange
        ) {
            Text(notification.title)
                .font(.subheadline.bold())

            Text(notification.message)
                .font(.subheadline)
                .foregroundColor(.textSecondary)
                .lineLimit(2)

            if let reward = notification.rewardPayload {
                HStack(spacing: 8) {
                    Label("+\(reward.pointsEarned) pts", systemImage: "plus.circle.fill")
                        .font(.caption.bold())
                        .foregroundColor(.orange)
                    Text("·")
                        .foregroundColor(.textSecondary)
                    Text("Total: \(reward.totalPoints)")
                        .font(.caption)
                        .foregroundColor(.textSecondary)
                }
                .padding(.top, 2)
            }
        }
    }
}
