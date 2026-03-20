import FirebaseAuth
import FirebaseFirestore
//
//  InboxViewModel.swift
//  CoffeeCraft
//
import SwiftUI
import UserNotifications

@MainActor
class InboxViewModel: ObservableObject {
    @Published var notifications: [AppNotification] = []
    @Published var isLoading = false
    @Published var hasMore = true
    @Published var unreadCount = 0

    private let db = Firestore.firestore()
    private var listener: ListenerRegistration?
    private let pageSize = 10
    private let maxListenerWindow = 50
    private var currentListenerLimit = 0

    /// Cursor pointing to the last document fetched.
    /// The next page query starts *after* this snapshot.
    private var lastDocument: DocumentSnapshot?

    deinit { listener?.remove() }

    // MARK: - Fetch (cursor-based pagination)

    func fetchNotifications(pageNum: Int) async {
        guard let userId = Auth.auth().currentUser?.uid else {
            AppLog.menu.warning("⚠️ fetchNotifications — no authenticated user, skipping")
            return
        }

        guard pageNum > 1 || notifications.isEmpty else { return }
        guard hasMore || pageNum == 1 else { return }

        AppLog.menu.debug(
            "📋 fetchNotif — uid: \(userId), page: \(pageNum), cursor: \(self.lastDocument?.documentID ?? "none")")

        if pageNum == 1 {
            isLoading = true
            // Use count() aggregation — returns a number without downloading any documents.
            // Replaces the two full getDocuments() count calls from before.
            await fetchUnreadCount(userId: userId)
        }

        do {
            var query: Query = db.collection("users")
                .document(userId)
                .collection("notifications")
                .order(by: "createdAt", descending: true)
                .limit(to: pageSize)

            if pageNum > 1, let cursor = lastDocument {
                query = query.start(afterDocument: cursor)
            }

            let snapshot = try await query.getDocuments()
            let newNotifications = snapshot.documents.compactMap {
                try? $0.data(as: AppNotification.self)
            }

            lastDocument = snapshot.documents.last
            hasMore = snapshot.documents.count == pageSize

            let existingIds = Set(notifications.compactMap { $0.id })
            let unique = newNotifications.filter { !existingIds.contains($0.id ?? "") }
            notifications.append(contentsOf: unique)

            AppLog.printList(unique, label: "Notifications Page \(pageNum)")
            AppLog.menu.debug(
                "✅ fetchNotif — appended \(unique.count), total: \(self.notifications.count), hasMore: \(self.hasMore)")

            if pageNum == 1 { isLoading = false }

            // Re-attach after every page so the listener window grows with
            // what's on screen — same fix as AdminOrdersViewModel.
            // Without this, .modified events for notifications beyond position 10
            // are never delivered.
            setupRealtimeListener(userId: userId)
        } catch {
            isLoading = false
            AppLog.menu.error("❌ fetchNotifications error: \(error.localizedDescription)")
            AlertManager.shared.showError(message: error.localizedDescription)
        }
    }

    // MARK: - Unread count via aggregation

    /// Fetches the unread count using Firestore's count() aggregation.
    /// No notification documents are downloaded — only a single integer is returned.
    private func fetchUnreadCount(userId: String) async {
        do {
            let query = db.collection("users")
                .document(userId)
                .collection("notifications")
                .whereField("isRead", isEqualTo: false)

            let snapshot = try await query.count.getAggregation(source: .server)
            unreadCount = Int(truncating: snapshot.count)
            syncAppIconBadge(unreadCount)
            AppLog.menu.debug("🔴 unreadCount from aggregation: \(self.unreadCount)")
        } catch {
            AppLog.menu.error("❌ fetchUnreadCount error: \(error.localizedDescription)")
        }
    }

    private func setupRealtimeListener(userId: String) {
        let newLimit = min(max(notifications.count, pageSize), maxListenerWindow)
        guard newLimit != currentListenerLimit else {
            AppLog.menu.debug("🔌 setupRealtimeListener — limit unchanged (\(newLimit)), skipping re-attach")
            return
        }
        currentListenerLimit = newLimit
        listener?.remove()

        AppLog.menu.debug("🔌 setupRealtimeListener — uid: \(userId), limit: \(newLimit)")

        listener = db.collection("users")
            .document(userId)
            .collection("notifications")
            .order(by: "createdAt", descending: true)
            .limit(to: newLimit)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self else { return }

                if let error {
                    AppLog.menu.error("❌ setupRealtimeListener — error: \(error.localizedDescription)")
                    return
                }

                guard let changes = snapshot?.documentChanges else { return }

                for change in changes {
                    switch change.type {
                    case .added:
                        if let notif = try? change.document.data(as: AppNotification.self),
                           !self.notifications.contains(where: { $0.id == notif.id }) {
                            self.notifications.insert(notif, at: 0)
                            if !notif.isRead {
                                self.unreadCount += 1
                                self.syncAppIconBadge(self.unreadCount)
                            }
                            AppLog.menu.debug("➕ Realtime — new notification: \(notif.id ?? "nil")")
                        }

                    case .modified:
                        if let updated = try? change.document.data(as: AppNotification.self),
                           let index = self.notifications.firstIndex(where: { $0.id == updated.id }) {
                            let wasUnread = !self.notifications[index].isRead
                            let isNowRead = updated.isRead
                            self.notifications[index] = updated
                            // Keep unreadCount in sync when listener picks up a read change
                            if wasUnread && isNowRead {
                                self.unreadCount = max(0, self.unreadCount - 1)
                                self.syncAppIconBadge(self.unreadCount)
                            }
                            AppLog.menu.debug("✏️ Realtime — updated: \(updated.id ?? "nil"), isRead: \(updated.isRead)")
                        }

                    case .removed:
                        if let removed = try? change.document.data(as: AppNotification.self),
                           let index = self.notifications.firstIndex(where: { $0.id == removed.id }) {
                            self.notifications.remove(at: index)
                            if !removed.isRead {
                                self.unreadCount = max(0, self.unreadCount - 1)
                                self.syncAppIconBadge(self.unreadCount)
                            }
                            AppLog.menu.debug("🗑️ Realtime — removed transient: \(removed.id ?? "nil")")
                        }

                    @unknown default:
                        break
                    }
                }
            }
    }

    // MARK: - Refresh

    func refreshNotifications() async {
        AppLog.menu.debug("🔄 refreshNotifications — clearing and re-fetching from page 1")
        listener?.remove()
        listener = nil
        currentListenerLimit = 0
        notifications = []
        lastDocument = nil
        hasMore = true
        unreadCount = 0
        await fetchNotifications(pageNum: 1)
    }

    // MARK: - Stop listening (e.g. on sign-out)
    func stopListening() {
        listener?.remove()
        listener = nil
        notifications = []
        unreadCount = 0
        syncAppIconBadge(0)
        AppLog.menu.debug("🔕 InboxViewModel — listener removed")
    }

    // MARK: - Mark one as read
    func markAsRead(_ notification: AppNotification) async {
        guard !notification.isRead, let id = notification.id else { return }
        guard let userId = Auth.auth().currentUser?.uid else { return }

        // Optimistic local update covers items outside the listener's page-1 window
        applyLocalUpdate(id: id, isRead: true)
        unreadCount = max(0, unreadCount - 1)
        syncAppIconBadge(unreadCount)

        do {
            try await db.collection("users")
                .document(userId)
                .collection("notifications")
                .document(id)
                .updateData(["isRead": true])
            AppLog.menu.debug("✅ Marked notification as read: \(id)")
        } catch {
            AppLog.menu.error("❌ Failed to mark read: \(error.localizedDescription)")
        }
    }

    // MARK: - Mark all as read
    func markAllAsRead() async {
        guard let userId = Auth.auth().currentUser?.uid else { return }

        let unread = notifications.filter { !$0.isRead }
        guard !unread.isEmpty else { return }

        AppLog.menu.debug("✅ Marking \(unread.count) notification(s) as read")

        // Optimistic update for all loaded pages
        for idx in notifications.indices where !notifications[idx].isRead {
            applyLocalUpdate(id: notifications[idx].id ?? "", isRead: true)
        }
        unreadCount = 0
        syncAppIconBadge(0)

        let batch = db.batch()
        for noti in unread {
            guard let id = noti.id else { continue }
            let ref = db.collection("users")
                .document(userId)
                .collection("notifications")
                .document(id)
            batch.updateData(["isRead": true], forDocument: ref)
        }

        do {
            try await batch.commit()
        } catch {
            AppLog.menu.error("❌ markAllAsRead batch failed: \(error.localizedDescription)")
        }
    }

    // MARK: - Delete one
    func delete(_ notification: AppNotification) async {
        guard let id = notification.id,
              let userId = Auth.auth().currentUser?.uid else { return }

        // Optimistic removal — decrement unread if needed
        if !notification.isRead {
            unreadCount = max(0, unreadCount - 1)
            syncAppIconBadge(unreadCount)
        }
        notifications.removeAll { $0.id == id }

        do {
            try await db.collection("users")
                .document(userId)
                .collection("notifications")
                .document(id)
                .delete()
            AppLog.menu.debug("🗑️ Deleted notification: \(id)")
        } catch {
            AppLog.menu.error("❌ Failed to delete notification: \(error.localizedDescription)")
        }
    }
    // MARK: - Fetch Order
    func fetchOrder(orderId: String) async -> Order? {
        do {
            let snapshot = try await db.collection("orders").document(orderId).getDocument()
            return try snapshot.data(as: Order.self)
        } catch {
            AlertManager.shared.showError(message: error.localizedDescription)
            return nil
        }
    }

    // MARK: - Helpers
    private func applyLocalUpdate(id: String, isRead: Bool) {
        guard let index = notifications.firstIndex(where: { $0.id == id }) else { return }
        let old = notifications[index]
        notifications[index] = AppNotification(
            id: old.id, type: old.type, title: old.title,
            message: old.message, isRead: isRead,
            isTransient: old.isTransient,
            createdAt: old.createdAt, payload: old.payload
        )
    }

    /// Syncs the app icon badge with the current unread count.
    /// Safe to call from anywhere — silently no-ops if permission not granted.
    private func syncAppIconBadge(_ count: Int) {
        UNUserNotificationCenter.current().setBadgeCount(count) { error in
            if let error {
                AppLog.menu.error("❌ setBadgeCount failed: \(error.localizedDescription)")
            }
        }
    }
}
