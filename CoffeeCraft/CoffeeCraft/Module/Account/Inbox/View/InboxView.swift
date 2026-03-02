//
//  InboxView.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 1/15/26.
//
import SwiftUI

struct InboxView: View {
    @EnvironmentObject var inboxVM: InboxViewModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.pushScreen) private var push
    @State private var isPaginating = false
    @State private var pageNum = 1

    var body: some View {
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
//        .onAppear {
//            inboxVM.fetchNotifications(pageNum: 1)
//        }
    }

    // MARK: - List
    private var notificationList: some View {
        CustomRefreshScrollView({
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
                            Task {
                                if notification.type == .orderStatus,
                                   let orderId = notification.payload?["orderId"] {
                                    if let order = await inboxVM.fetchOrder(orderId: orderId) {
                                        push(AnyView(OrderDetailView(order: order)))
                                    }
                                }
                                await inboxVM.markAsRead(notification)
                            }
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
                        // ── Pagination trigger ──────────────────────────────
                        .onAppear {
                            guard inboxVM.notifications.count < inboxVM.totalNotificationCount,
                                  notification.id == inboxVM.notifications.last?.id,
                                  !isPaginating
                            else { return }

                            isPaginating = true
                            pageNum += 1

                            Task {
                                let timer = MinimumLoadingTime(0.5)
                                try? await timer.waitIfNeeded()
                                await MainActor.run {
                                    inboxVM.fetchNotifications(pageNum: pageNum) { _ in
                                        isPaginating = false
                                    }
                                }
                            }
                        }
                }

                if isPaginating {
                    ProgressView()
                        .tint(.brown)
                        .padding()
                }
            }
            .padding(.vertical, 8)
        }, onRefresh: {
            pageNum = 1
            isPaginating = false
            await withCheckedContinuation { continuation in
                inboxVM.refreshNotifications { _ in continuation.resume() }
            }
        })
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
