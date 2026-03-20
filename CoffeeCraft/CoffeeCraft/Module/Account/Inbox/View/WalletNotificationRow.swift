//
//  WalletNotificationRow.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 3/19/26.
//
//  Handles all wallet-related inbox notifications:
//  topup | payment | refund
//  (loyalty rewards remain in RewardNotificationRow via .reward type)
//
import SwiftUI

struct WalletNotificationRow: View {
    let notification: AppNotification

    private var payload: WalletPayload? { notification.walletPayload }

    var body: some View {
        NotificationRowShell(
            notification: notification,
            icon: payload?.icon ?? "creditcard.fill",
            iconColor: payload.map { Color($0.iconColorName) } ?? .accentPrimary
        ) {
            Text(notification.title)
                .font(.subheadline.bold())
                .foregroundColor(.textPrimary)
                .fixedSize(horizontal: false, vertical: true)

            Text(notification.message)
                .font(.caption)
                .foregroundColor(.textMuted)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)

            if let wallet = payload {
                HStack(spacing: 8) {
                    // Amount chip
                    Text(wallet.formattedAmount)
                        .font(.caption.bold())
                        .foregroundColor(Color(wallet.iconColorName))

                    Text("·")
                        .foregroundColor(.textSecondary)

                    // Balance after
                    Label(wallet.formattedBalance, systemImage: "wallet.bifold")
                        .font(.caption)
                        .foregroundColor(.textSecondary)
                }
                .padding(.top, 2)
            }
        }
    }
}
