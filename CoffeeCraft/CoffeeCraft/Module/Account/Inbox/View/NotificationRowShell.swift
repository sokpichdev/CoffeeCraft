//
//  NotificationRowShell.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 2/21/26.
//
import SwiftUI

struct NotificationRowShell<Content: View>: View {
    let notification: AppNotification
    let icon: String
    let iconColor: Color
    @ViewBuilder let content: () -> Content

    var body: some View {
        HStack(alignment: .top, spacing: 14) {

            // Icon bubble
            ZStack {
                Circle()
                    .fill(iconColor.opacity(0.15))
                    .frame(width: 44, height: 44)
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(iconColor)
            }

            // Text content
            VStack(alignment: .leading, spacing: 5) {
                content()
                Text(notification.createdAt.dateValue().relativeFormatted)
                    .font(.caption2)
                    .foregroundColor(.textSecondary)
            }

            Spacer(minLength: 0)

            // Unread dot
            if !notification.isRead {
                Circle()
                    .fill(Color.semanticSuccess)
                    .frame(width: 12, height: 12)
                    .padding(.top, 6)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.surfacePrimary)
                .shadow(
                    color: Color.textPrimary.opacity(notification.isRead ? 0.04 : 0.08),
                    radius: notification.isRead ? 2 : 4,
                    x: 0, y: 2
                )
        )
        .opacity(notification.isRead ? 0.5 : 1)
        .overlay(alignment: .leading) {
            // Left accent bar for unread items
            if !notification.isRead {
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color.accentGold)
                    .frame(width: 3)
                    .padding(.vertical, 10)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}
