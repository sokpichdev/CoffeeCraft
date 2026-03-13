//
//  UserManagementViewModel.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 3/13/26.
//

import Foundation
import FirebaseFirestore

@MainActor
final class UserManagementViewModel: ObservableObject {

    // MARK: - Published

    @Published var users: [UserStatItem] = []
    @Published var searchText: String = ""
    @Published var isLoading: Bool = false
    @Published var isLoadingMore: Bool = false
    @Published var canLoadMore: Bool = true

    // MARK: - Private

    private let service = AnalyticsService.shared
    private var lastDocument: DocumentSnapshot?
    private var enrichmentTask: Task<Void, Never>?

    // MARK: - Lifecycle

    func onAppear() {
        guard users.isEmpty else { return }
        Task { await load() }
    }

    // MARK: - Load First Page

    func load() async {
        isLoading = true
        lastDocument = nil
        canLoadMore = true
        enrichmentTask?.cancel()

        do {
            let page = try await service.fetchUserList(searchText: searchText)
            users = page.items
            lastDocument = page.lastDocument
            canLoadMore = page.hasMore
            enrichVisible()
        } catch {
            AppLog.dashboard.error("UserManagementViewModel load: \(error.localizedDescription)")
            AlertManager.shared.showError(
                title: "Failed to load users",
                message: error.localizedDescription
            )
        }

        isLoading = false
    }

    // MARK: - Load More (Infinite Scroll)

    func loadMore() async {
        guard canLoadMore, !isLoadingMore, !isLoading,
              let cursor = lastDocument else { return }

        isLoadingMore = true

        do {
            let page = try await service.fetchMoreUsers(after: cursor, searchText: searchText)
            users.append(contentsOf: page.items)
            lastDocument = page.lastDocument
            canLoadMore = page.hasMore
            // Enrich only the newly added rows
            let newIds = page.items.map(\.id)
            enrichSubset(ids: newIds)
        } catch {
            AppLog.dashboard.error("UserManagementViewModel loadMore: \(error.localizedDescription)")
        }

        isLoadingMore = false
    }

    // MARK: - Search

    func applySearch() async {
        await load()
    }

    // MARK: - Background Enrichment

    /// Kicks off a concurrent background fetch of totalOrders + totalSpent
    /// for all currently visible users. Merges results into `users` array
    /// one-by-one so the UI updates progressively as each user's data arrives.
    private func enrichVisible() {
        let ids = users.map(\.id)
        enrichSubset(ids: ids)
    }

    private func enrichSubset(ids: [String]) {
        enrichmentTask?.cancel()
        enrichmentTask = Task {
            let stats = await service.enrichUsersWithOrderStats(userIds: ids)
            guard !Task.isCancelled else { return }

            // Merge enrichment results back into the users array
            for (userId, (count, spent)) in stats {
                if let idx = users.firstIndex(where: { $0.id == userId }) {
                    users[idx].totalOrders = count
                    users[idx].totalSpent  = spent
                }
            }
        }
    }
}
