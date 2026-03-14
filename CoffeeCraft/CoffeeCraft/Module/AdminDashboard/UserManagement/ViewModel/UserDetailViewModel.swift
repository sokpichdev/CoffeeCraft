//
//  UserDetailViewModel.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 3/13/26.
//

import Foundation

@MainActor
final class UserDetailViewModel: ObservableObject {

    // MARK: - Input

    let baseUser: UserStatItem

    // MARK: - Published

    @Published var detailData: UserDetailData?
    @Published var isLoading: Bool = false
    @Published var isSendingNotification: Bool = false

    // MARK: - Notification Compose State

    @Published var notifTitle: String = ""
    @Published var notifBody: String = ""
    @Published var showNotifSheet: Bool = false

    // MARK: - Private

    private let service = AnalyticsService.shared

    // MARK: - Init

    init(user: UserStatItem) {
        self.baseUser = user
    }

    // MARK: - Load

    func onAppear() {
        Task { await load() }
    }

    func load() async {
        isLoading = true
        do {
            detailData = try await service.fetchUserDetail(userId: baseUser.id, base: baseUser)
        } catch {
            AppLog.dashboard.error("UserDetailViewModel load: \(error.localizedDescription)")
            AlertManager.shared.showError(
                title: "Failed to load user",
                message: error.localizedDescription
            )
        }
        isLoading = false
    }

    // MARK: - Computed

    var canSendNotification: Bool {
        detailData?.fcmToken != nil
    }

    var notifFormIsValid: Bool {
        !notifTitle.trimmingCharacters(in: .whitespaces).isEmpty &&
        !notifBody.trimmingCharacters(in: .whitespaces).isEmpty
    }

    // MARK: - Send Notification

    func sendNotification() async {
        guard notifFormIsValid else { return }
        isSendingNotification = true

        do {
            try await service.sendNotificationToUser(
                userId: baseUser.id,
                title: notifTitle.trimmingCharacters(in: .whitespaces),
                body: notifBody.trimmingCharacters(in: .whitespaces)
            )
            showNotifSheet = false
            notifTitle = ""
            notifBody = ""
            ToastManager.shared.showTop(
                message: "Notification queued for \(baseUser.name)",
                type: .success
            )
        } catch {
            AppLog.dashboard.error("sendNotification: \(error.localizedDescription)")
            AlertManager.shared.showError(
                title: "Failed to send notification",
                message: error.localizedDescription
            )
        }

        isSendingNotification = false
    }
}
