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

    // Derived — drives the badge on the inbox icon
    var unreadCount: Int {
        notifications.filter { !$0.isRead }.count
    }

    private let db = Firestore.firestore()
    private var listener: ListenerRegistration?

    deinit { listener?.remove() }

    // MARK: - Listen (call once on app start or tab appear)
    func listen() {
        guard listener == nil else { return }
        guard let userId = Auth.auth().currentUser?.uid else {
            AppLog.auth.warning("⚠️ InboxViewModel.listen — no authenticated user")
            return
        }

        AppLog.menu.debug("🔔 InboxViewModel — attaching listener for uid: \(userId)")
        isLoading = true

        listener = db
            .collection("users")
            .document(userId)
            .collection("notifications")
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self else { return }
                isLoading = false

                if let error {
                    AppLog.menu.error("❌ InboxViewModel listener error: \(error.localizedDescription)")
                    AlertManager.shared.showError(message: error.localizedDescription)
                    return
                }

                self.notifications = snapshot?.documents.compactMap {
                    try? $0.data(as: AppNotification.self)
                } ?? []

                AppLog.menu.debug("📬 InboxViewModel — \(self.notifications.count) notification(s), \(self.unreadCount) unread")
            }
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

        do {
            try await db
                .collection("users")
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

        let batch = db.batch()
        for notification in unread {
            guard let id = notification.id else { continue }
            let ref = db
                .collection("users")
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

        do {
            try await db
                .collection("users")
                .document(userId)
                .collection("notifications")
                .document(id)
                .delete()
            AppLog.menu.debug("🗑️ Deleted notification: \(id)")
        } catch {
            AppLog.menu.error("❌ Failed to delete notification: \(error.localizedDescription)")
        }
    }
}
