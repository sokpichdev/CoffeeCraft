//
//  InboxViewModel.swift
//  CoffeeCraft
//
import SwiftUI
import FirebaseFirestore
import FirebaseAuth

@MainActor
class InboxViewModel: ObservableObject {
    @Published var notifications: [AppNotification] = []
    @Published var isLoading = false
    @Published var totalNotificationCount = 0

    var unreadCount: Int {
        notifications.filter { !$0.isRead }.count
    }

    private let db = Firestore.firestore()
    private var listener: ListenerRegistration?
    private let pageSize = 10

    deinit { listener?.remove() }

    // MARK: - Fetch (paginated)
    func fetchNotifications(pageNum: Int, completion: ((Bool) -> Void)? = nil) {
        guard let userId = Auth.auth().currentUser?.uid else {
            AppLog.menu.warning("⚠️ fetchNotifications — no authenticated user, skipping")
            completion?(false)
            return
        }
        guard pageNum != 1 || listener == nil else {
                completion?(true)
                return
            }

        let offset = (pageNum - 1) * pageSize
        AppLog.menu.debug("📋 fetchNotifications — uid: \(userId), page: \(pageNum), offset: \(offset)")

        // Get total count on first page load
        if pageNum == 1 {
            db.collection("users")
                .document(userId)
                .collection("notifications")
                .getDocuments { [weak self] snapshot, _ in
                    guard let self else { return }
                    Task { @MainActor in
                        self.totalNotificationCount = snapshot?.documents.count ?? 0
                        AppLog.menu.debug("📊 fetchNotifications — totalCount: \(self.totalNotificationCount)")
                    }
                }
        }

        db.collection("users")
            .document(userId)
            .collection("notifications")
            .order(by: "createdAt", descending: true)
            .getDocuments { [weak self] snapshot, error in
                guard let self else {
                    completion?(false)
                    return
                }

                if let error {
                    AppLog.menu.error("❌ fetchNotifications — error: \(error.localizedDescription)")
                    Task { @MainActor in
                        AlertManager.shared.showError(message: error.localizedDescription)
                    }
                    completion?(false)
                    return
                }

                guard let documents = snapshot?.documents else {
                    AppLog.menu.warning("⚠️ fetchNotifications — snapshot has no documents")
                    completion?(false)
                    return
                }

                // Manual pagination — slice the full result set
                let endIndex = min(offset + self.pageSize, documents.count)
                guard offset < documents.count else {
                    AppLog.menu.debug("📋 fetchNotifications — offset \(offset) beyond docs.count \(documents.count), no more pages")
                    completion?(true)
                    return
                }

                let pageDocuments = Array(documents[offset..<endIndex])
                let newNotifications = pageDocuments.compactMap {
                    try? $0.data(as: AppNotification.self)
                }

                Task { @MainActor in
                    let existingIds = Set(self.notifications.compactMap { $0.id })
                    let unique = newNotifications.filter { n in
                        guard let id = n.id else { return false }
                        return !existingIds.contains(id)
                    }
                    self.notifications.append(contentsOf: unique)
                    AppLog.menu.debug("✅ fetchNotifications — appended \(unique.count) on page \(pageNum), total loaded: \(self.notifications.count)")
                }

                // Attach realtime listener on first page only
                if pageNum == 1 {
                    Task { @MainActor in
                        self.setupRealtimeListener(userId: userId)
                    }
                }

                completion?(true)
            }
    }

    // MARK: - Realtime listener (new + updated notifications, page 1 window)
    private func setupRealtimeListener(userId: String) {
        listener?.remove()
        AppLog.menu.debug("🔌 setupRealtimeListener — attaching for uid: \(userId)")

        listener = db.collection("users")
            .document(userId)
            .collection("notifications")
            .order(by: "createdAt", descending: true)
            .limit(to: pageSize)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self else { return }

                if let error {
                    AppLog.menu.error("❌ setupRealtimeListener — error: \(error.localizedDescription)")
                    AlertManager.shared.showError(title: "Realtime listener error", message: error.localizedDescription)
                    return
                }

                guard let changes = snapshot?.documentChanges else { return }

                for change in changes {
                    switch change.type {
                    case .added:
                        if let n = try? change.document.data(as: AppNotification.self),
                           !self.notifications.contains(where: { $0.id == n.id }) {
                            self.notifications.insert(n, at: 0)
                            self.totalNotificationCount += 1
                            AppLog.menu.debug("➕ Realtime — new notification: \(n.id ?? "nil")")
                        }

                    case .modified:
                        if let updated = try? change.document.data(as: AppNotification.self),
                           let index = self.notifications.firstIndex(where: { $0.id == updated.id }) {
                            self.notifications[index] = updated
                            AppLog.menu.debug("✏️ Realtime — updated: \(updated.id ?? "nil"), isRead: \(updated.isRead)")
                        }

                    default:
                        break
                    }
                }
            }
    }

    // MARK: - Refresh
    func refreshNotifications(completion: ((Bool) -> Void)? = nil) {
        AppLog.menu.debug("🔄 refreshNotifications — clearing and re-fetching from page 1")
        listener?.remove()
        listener = nil
        notifications = []
        totalNotificationCount = 0
        fetchNotifications(pageNum: 1, completion: completion)
    }

    // MARK: - Stop listening (e.g. on sign-out)
    func stopListening() {
        listener?.remove()
        listener = nil
        notifications = []
        AppLog.menu.debug("🔕 InboxViewModel — listener removed")
    }

    // MARK: - Mark one as read
    func markAsRead(_ notification: AppNotification) async {
        guard !notification.isRead, let id = notification.id else { return }
        guard let userId = Auth.auth().currentUser?.uid else { return }

        // Optimistic local update covers items outside the listener's page-1 window
        applyLocalUpdate(id: id, isRead: true)

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
        for i in notifications.indices where !notifications[i].isRead {
            applyLocalUpdate(id: notifications[i].id ?? "", isRead: true)
        }

        let batch = db.batch()
        for n in unread {
            guard let id = n.id else { continue }
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

        // Optimistic removal
        notifications.removeAll { $0.id == id }
        totalNotificationCount = max(0, totalNotificationCount - 1)

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

    // MARK: - Helpers
    private func applyLocalUpdate(id: String, isRead: Bool) {
        guard let index = notifications.firstIndex(where: { $0.id == id }) else { return }
        let old = notifications[index]
        notifications[index] = AppNotification(
            id: old.id, type: old.type, title: old.title,
            message: old.message, isRead: isRead,
            createdAt: old.createdAt, payload: old.payload
        )
    }
}
