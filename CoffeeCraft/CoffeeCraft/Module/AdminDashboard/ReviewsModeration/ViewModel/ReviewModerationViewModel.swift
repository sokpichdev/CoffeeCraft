//
//  ReviewModerationViewModel.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 3/13/26.
//

import FirebaseFirestore
import Foundation

// MARK: - Section

enum ReviewDashboardSection: String, CaseIterable, Identifiable {
    case queue = "Reviews"
    case analytics = "Analytics"
    var id: String { rawValue }
    var icon: String {
        switch self {
        case .queue: return "text.bubble.fill"
        case .analytics: return "chart.bar.fill"
        }
    }
}

// MARK: - ViewModel

@MainActor
final class ReviewModerationViewModel: ObservableObject {

    // MARK: - Section

    @Published var selectedSection: ReviewDashboardSection = .queue

    // MARK: - Queue State

    @Published var reviews: [ReviewItem] = []
    @Published var filter = ReviewFilter()
    @Published var productOptions: [ProductOption] = []
    @Published var isLoadingQueue: Bool = false
    @Published var isLoadingMore: Bool = false
    @Published var canLoadMore: Bool = true
    @Published var togglingIds: Set<String> = [] // in-flight hide/unhide guards

    // MARK: - Analytics State

    @Published var analyticsData: ReviewAnalyticsData?
    @Published var selectedProductId: String?
    @Published var isLoadingAnalytics: Bool = false

    // MARK: - Private

    private let service = AnalyticsService.shared
    private var lastDocument: DocumentSnapshot?

    // MARK: - Lifecycle

    func onAppear() {
        Task {
            await withTaskGroup(of: Void.self) { group in
                group.addTask { await self.loadQueue() }
                group.addTask { await self.loadProductOptions() }
            }
        }
    }

    // MARK: - Queue

    func loadQueue() async {
        isLoadingQueue = true
        lastDocument = nil
        canLoadMore = true

        do {
            let (items, cursor) = try await service.fetchAllReviews(filter: filter)
            reviews = items
            lastDocument = cursor
            canLoadMore = cursor != nil
        } catch {
            AppLog.dashboard.error("ReviewModerationViewModel loadQueue: \(error.localizedDescription)")
            AlertManager.shared.showError(
                title: "Failed to load reviews",
                message: error.localizedDescription
            )
        }

        isLoadingQueue = false
    }

    func loadMore() async {
        guard canLoadMore, !isLoadingMore, !isLoadingQueue,
              let cursor = lastDocument else { return }

        isLoadingMore = true
        do {
            let (items, newCursor) = try await service.fetchMoreReviews(
                after: cursor, filter: filter)
            reviews.append(contentsOf: items)
            lastDocument = newCursor
            canLoadMore = newCursor != nil
        } catch {
            AppLog.dashboard.error("ReviewModerationViewModel loadMore: \(error.localizedDescription)")
        }
        isLoadingMore = false
    }

    func applyFilter() async {
        await loadQueue()
    }

    // MARK: - Hide / Unhide

    /// Optimistically toggles `isHidden` in-memory, then writes to Firestore.
    /// Reverts if the write fails.
    func toggleHidden(for review: ReviewItem) async {
        guard !togglingIds.contains(review.id) else { return }
        togglingIds.insert(review.id)

        // Optimistic update
        if let idx = reviews.firstIndex(where: { $0.id == review.id }) {
            reviews[idx].isHidden.toggle()
        }

        do {
            try await service.setReviewHidden(
                productId: review.productId,
                reviewId: review.id,
                hidden: !review.isHidden // original value before toggle
            )
        } catch {
            // Revert on failure
            if let idx = reviews.firstIndex(where: { $0.id == review.id }) {
                reviews[idx].isHidden = review.isHidden
            }
            AlertManager.shared.showError(
                title: "Failed to update review",
                message: error.localizedDescription
            )
        }

        togglingIds.remove(review.id)
    }

    // MARK: - Product Options

    private func loadProductOptions() async {
        do {
            productOptions = try await service.fetchReviewedProducts()
            // Auto-select first product for analytics tab
            if selectedProductId == nil {
                selectedProductId = productOptions.first?.id
                await loadAnalytics()
            }
        } catch {
            AppLog.dashboard.error("ReviewModerationViewModel loadProductOptions: \(error.localizedDescription)")
        }
    }

    // MARK: - Analytics

    func loadAnalytics() async {
        guard let productId = selectedProductId,
              let productName = productOptions.first(where: { $0.id == productId })?.name
        else { return }

        isLoadingAnalytics = true
        do {
            analyticsData = try await service.fetchReviewAnalytics(
                productId: productId, productName: productName)
        } catch {
            AppLog.dashboard.error("ReviewModerationViewModel loadAnalytics: \(error.localizedDescription)")
        }
        isLoadingAnalytics = false
    }

    func productChanged() async {
        analyticsData = nil
        await loadAnalytics()
    }
    
    func setSelectedProduct(_ id: String?) async {
        selectedProductId = id
        filter.productId = id

        if selectedSection == .queue {
            await loadQueue()
            return
        }

        // Analytics section
        guard let id else {
            analyticsData = nil
            return
        }

        await loadAnalytics()
    }
}
