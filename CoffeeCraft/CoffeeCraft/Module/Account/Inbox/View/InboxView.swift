//
//  InboxView.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 1/15/26.
//
import SwiftUI

// ─────────────────────────────────────────────────────────────
// MARK: - InboxView
// ─────────────────────────────────────────────────────────────
struct InboxView: View {
    @EnvironmentObject var inboxVM: InboxViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        CustomNavigationStack {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()

                Group {
                    if inboxVM.isLoading {
                        loadingState
                    } else if inboxVM.notifications.isEmpty {
                        emptyState
                    } else {
                        notificationList
                    }
                }
            }
            .customNavigationBar("Inbox") {
                ToolBarButton.back { dismiss() }

                if inboxVM.unreadCount > 0 {
                    ToolBarButton(
                        placement: .topBarTrailing,
                        buttonType: .text("Mark all read")
                    ) {
                        Task { await inboxVM.markAllAsRead() }
                    }
                }
            }
        }
    }

    // MARK: - List
    private var notificationList: some View {
        ScrollView {
            // Unread count pill
            if inboxVM.unreadCount > 0 {
                HStack {
                    Label(
                        "\(inboxVM.unreadCount) unread",
                        systemImage: "bell.badge.fill"
                    )
                    .font(.caption.bold())
                    .foregroundColor(.brown)
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .padding(.bottom, 4)
            }

            LazyVStack(spacing: 10) {
                ForEach(inboxVM.notifications) { notification in
                    NotificationRow(notification: notification)
                        .padding(.horizontal, 16)
                        .onTapGesture {
                            Task { await inboxVM.markAsRead(notification) }
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(role: .destructive) {
                                Task { await inboxVM.delete(notification) }
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                        .swipeActions(edge: .leading) {
                            if !notification.isRead {
                                Button {
                                    Task { await inboxVM.markAsRead(notification) }
                                } label: {
                                    Label("Read", systemImage: "envelope.open")
                                }
                                .tint(.brown)
                            }
                        }
                }
            }
            .padding(.vertical, 8)
        }
    }

    // MARK: - Loading State
    private var loadingState: some View {
        VStack(spacing: 16) {
            ProgressView()
                .tint(.brown)
                .scaleEffect(1.2)
            Text("Loading notifications...")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Empty State
    private var emptyState: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.brown.opacity(0.1))
                    .frame(width: 90, height: 90)
                Image(systemName: "bell.slash.fill")
                    .font(.system(size: 38))
                    .foregroundColor(.brown.opacity(0.6))
            }
            Text("All caught up!")
                .font(.title3.bold())
            Text("No notifications yet.\nWe'll let you know when your order is ready.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}

// ─────────────────────────────────────────────────────────────
// MARK: - NotificationRow (router)
// ─────────────────────────────────────────────────────────────
struct NotificationRow: View {
    let notification: AppNotification

    var body: some View {
        Group {
            switch notification.type {
            case .orderStatus:
                OrderStatusNotificationRow(notification: notification)
            case .promotion:
                PromotionNotificationRow(notification: notification)
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

// ─────────────────────────────────────────────────────────────
// MARK: - Shared Row Shell
// ─────────────────────────────────────────────────────────────
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
                    .foregroundColor(.secondary)
            }

            Spacer(minLength: 0)

            // Unread dot
            if !notification.isRead {
                Circle()
                    .fill(Color.brown)
                    .frame(width: 9, height: 9)
                    .padding(.top, 6)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(notification.isRead
                      ? Color(.secondarySystemGroupedBackground)
                      : Color.brown.opacity(0.06))
                .shadow(
                    color: Color.black.opacity(notification.isRead ? 0.04 : 0.08),
                    radius: notification.isRead ? 2 : 4,
                    x: 0, y: 2
                )
        )
        .overlay(alignment: .leading) {
            // Left accent bar for unread items
            if !notification.isRead {
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color.brown)
                    .frame(width: 3)
                    .padding(.vertical, 10)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

// ─────────────────────────────────────────────────────────────
// MARK: - Row: Order Status
// ─────────────────────────────────────────────────────────────
struct OrderStatusNotificationRow: View {
    let notification: AppNotification

    private var payload: OrderStatusPayload? { notification.orderStatusPayload }

    var body: some View {
        NotificationRowShell(
            notification: notification,
            icon: payload?.statusIcon ?? "clock.fill",
            iconColor: statusColor(payload?.status)
        ) {
            Text(notification.title)
                .font(.subheadline.bold())
                .foregroundColor(.primary)

            Text(notification.message)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(2)

            if let orderId = payload?.orderId {
                Label(orderId, systemImage: "number")
                    .font(.caption.bold())
                    .foregroundColor(.brown)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Color.brown.opacity(0.1))
                    .clipShape(Capsule())
                    .padding(.top, 2)
            }
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

// ─────────────────────────────────────────────────────────────
// MARK: - Row: Promotion
// ─────────────────────────────────────────────────────────────
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
                .foregroundColor(.secondary)
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
                .background(Color.purple.opacity(0.1))
                .clipShape(Capsule())
                .padding(.top, 2)
            }
        }
    }
}

// ─────────────────────────────────────────────────────────────
// MARK: - Row: Reward
// ─────────────────────────────────────────────────────────────
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
                .foregroundColor(.secondary)
                .lineLimit(2)

            if let reward = notification.rewardPayload {
                HStack(spacing: 8) {
                    Label("+\(reward.pointsEarned) pts", systemImage: "plus.circle.fill")
                        .font(.caption.bold())
                        .foregroundColor(.orange)
                    Text("·")
                        .foregroundColor(.secondary)
                    Text("Total: \(reward.totalPoints)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 2)
            }
        }
    }
}

// ─────────────────────────────────────────────────────────────
// MARK: - Row: Announcement
// ─────────────────────────────────────────────────────────────
struct AnnouncementNotificationRow: View {
    let notification: AppNotification

    var body: some View {
        NotificationRowShell(
            notification: notification,
            icon: "megaphone.fill",
            iconColor: .blue
        ) {
            Text(notification.title)
                .font(.subheadline.bold())

            Text(notification.message)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(3)
        }
    }
}

// ─────────────────────────────────────────────────────────────
// MARK: - Row: Generic fallback
// ─────────────────────────────────────────────────────────────
struct GenericNotificationRow: View {
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
                .foregroundColor(.secondary)
                .lineLimit(2)
        }
    }
}

// ─────────────────────────────────────────────────────────────
// MARK: - Date helper
// ─────────────────────────────────────────────────────────────
private extension Date {
    var relativeFormatted: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: self, relativeTo: Date())
    }
}
