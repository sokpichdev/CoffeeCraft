//
//  NotificationRow.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 2/21/26.
//
import SwiftUI

struct NotificationRow: View {
    let notification: AppNotification

    var body: some View {
        Group {
            switch notification.type {
            case .orderStatus:
                OrderStatusNotificationRow(notification: notification)
            case .promotion:
                PromotionNotificationRow(notification: notification)
            case .wallet:
                WalletNotificationRow(notification: notification)
            case .reward:
                RewardNotificationRow(notification: notification)
            case .announcement:
                AnnouncementNotificationRow(notification: notification)
            case .unknown:
                GenericNotificationRow(notification: notification)
            }
        }
    }
}
