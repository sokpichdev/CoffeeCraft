//
//  ReviewViewModel.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 3/10/26.
//

import FirebaseAuth
import FirebaseFirestore
import SwiftUI
// MARK: - ReviewSortOrder

enum ReviewSortOrder: String, CaseIterable, Identifiable {
    case newest      = "Newest"
    case mostHelpful = "Most Helpful"
    var id: String { rawValue }
}

@MainActor
final class ReviewViewModel: ObservableObject {

    // MARK: - Product context

    /// Set once at init. All service calls use this.
    private(set) var productId: String = ""

    // MARK: - Review list state

    /// product ratings snapshot
    @Published var latestProductRatings: (avg: Double, count: Int, distribution: [String: Int])?
    
    /// Visible, non-hidden reviews for the current product (paginated).
    @Published var reviews: [Review] = []

    /// True while the first page is loading.
    @Published var isLoadingReviews: Bool = false

    /// True while the next page is loading (Load More button spinner).
    @Published var isLoadingMore: Bool = false

    /// False when the last page returned fewer items than the page size,
    /// meaning there are no more reviews to fetch.
    @Published var canLoadMore: Bool = false

    // MARK: - User's own rating state

    /// The current user's existing rating for this product, if any.
    /// nil = user has never rated this product.
    @Published var existingRating: UserRating?

    /// True while checking for an existing rating.
    @Published var isLoadingUserRating: Bool = false

    // MARK: - Proof of purchase state

    /// The orderId from the proof-of-purchase query.
    /// nil = user has no qualifying completed order → hide rating CTA.
    @Published var proofOrderId: String?

    /// True while the proof-of-purchase query is running.
    @Published var isCheckingEligibility: Bool = false

    // MARK: - Input state (drives RatingInputSheet)

    /// The score currently selected in the star picker.
    /// Pre-filled from existingRating.score when editing.
    @Published var draftScore: Int = 0

    /// The text currently typed in the review body field.
    /// Pre-filled from existingRating's review body when editing.
    @Published var draftBody: String = ""

    /// The headline typed in the review title field (max 60 chars).
    @Published var draftTitle: String = ""

    /// Current sort order for the review list. Changing this triggers a reload.
    @Published var sortOrder: ReviewSortOrder = .mostHelpful

    /// True while a submit or edit write is in flight.
    @Published var isSubmitting: Bool = false

    // MARK: - Computed helpers (drive UI decisions)

    /// True when the user is eligible to rate AND hasn't rated yet.
    /// Controls whether the "Write a Review" CTA is visible.
    var canSubmitNewRating: Bool {
        proofOrderId != nil && existingRating == nil
    }

    /// True when the user has already submitted a rating.
    /// Controls whether to show the "Edit your review" button.
    var canEditRating: Bool {
        existingRating != nil
    }

    /// True when draftScore is valid (1–5) — enables the Submit button.
    var isInputValid: Bool {
        (1...5).contains(draftScore)
    }

    /// The label shown on the submit button — "Submit Review" vs "Update Review".
    var submitButtonLabel: String {
        existingRating == nil ? "Submit Review" : "Update Review"
    }

    /// The current user's Firebase UID. Nil = not logged in.
    private var currentUserId: String? {
        Auth.auth().currentUser?.uid
    }

    /// The current user's display name, falling back gracefully.
    private var currentUserName: String {
        UserSession.shared.userName ?? "Coffee Lover"
    }

    // MARK: - Pagination cursor

    // Firestore DocumentSnapshot cursor for the next page.
    // nil after the first page is loaded, then set from fetchReviews result.
    // Firestore DocumentSnapshot cursor — typed as Any to avoid a FirebaseFirestore
    // import at the top of this file. Cast to DocumentSnapshot inside the service call.
    private var lastDocument: Any?

    private let pageSize = 10

    // MARK: - Service

    private let service = RatingService.shared
}

// MARK: - Initial Load

extension ReviewViewModel {

    /// Entry point — called from ProductDetailView and RatingInputSheet on appear.
    /// Runs proof-of-purchase check, user rating fetch, and first review page
    /// concurrently via async let to minimise total wait time.
    func loadInitialState(productId: String) async {
        guard !productId.isEmpty else { return }
        self.productId = productId

        AppLog.firestore.debug("📦 ReviewViewModel.loadInitialState — productId: \(productId)")

        // Run all three fetches concurrently
        async let eligibilityTask: Void = checkEligibility(productId: productId)
        async let userRatingTask: Void = fetchUserRating(productId: productId)
        async let reviewsTask: Void = loadReviews(productId: productId, reset: true)

        _ = await (eligibilityTask, userRatingTask, reviewsTask)

        AppLog.firestore.debug("✅ ReviewViewModel.loadInitialState complete")
    }

    // MARK: Eligibility check

    private func checkEligibility(productId: String) async {
        guard let userId = currentUserId else {
            AppLog.firestore.debug("⚠️ checkEligibility — no authenticated user")
            return
        }

        isCheckingEligibility = true
        defer { isCheckingEligibility = false }

        do {
            proofOrderId = try await service.checkProofOfPurchase(
                userId: userId,
                productId: productId
            )
            AppLog.firestore.debug("✅ eligibility — proofOrderId: \(self.proofOrderId ?? "nil")")
        } catch {
            AppLog.firestore.error("❌ checkEligibility failed: \(error.localizedDescription)")
            // Non-fatal — user just won't see the rating CTA
        }
    }

    // MARK: User rating fetch

    private func fetchUserRating(productId: String) async {
        guard let userId = currentUserId else { return }

        isLoadingUserRating = true
        defer { isLoadingUserRating = false }

        do {
            existingRating = try await service.fetchUserRating(
                userId: userId,
                productId: productId
            )
            // Pre-fill draft fields so the sheet opens with previous values
            if let existing = existingRating {
                draftScore = existing.score
                // Note: draftBody is pre-filled from the review doc in
                // prepareForEditing(review:) when the user taps "Edit"
            }
            AppLog.firestore.debug("✅ fetchUserRating — found: \(self.existingRating != nil)")
        } catch {
            AppLog.firestore.error("❌ fetchUserRating failed: \(error.localizedDescription)")
        }
    }

    // MARK: Review list load (shared by first page and refresh)

    private func loadReviews(productId: String, reset: Bool, sort: ReviewSortOrder? = nil) async {
        isLoadingReviews = true
        defer { isLoadingReviews = false }

        if reset {
            reviews      = []
            lastDocument = nil
            canLoadMore  = false
        }

        do {
            let result = try await service.fetchReviews(
                productId: productId,
                limit: pageSize,
                sort: sort ?? sortOrder,
                after: nil
            )
            reviews      = result.reviews
            lastDocument = result.lastDocument
            canLoadMore  = result.reviews.count == pageSize

            AppLog.firestore.debug("✅ loadReviews — loaded \(result.reviews.count), canLoadMore: \(self.canLoadMore)")
        } catch {
            AppLog.firestore.error("❌ loadReviews failed: \(error.localizedDescription)")
            AlertManager.shared.showError(
                title: "Couldn't load reviews",
                message: error.localizedDescription
            )
        }
    }
}

// MARK: - Sort

extension ReviewViewModel {

    /// Called when the user picks a different sort from the picker.
    /// Resets to page 1 and reloads with the new sort order.
    func changeSortOrder(to order: ReviewSortOrder) async {
        guard order != sortOrder else { return }
        sortOrder = order
        await loadReviews(productId: productId, reset: true, sort: order)
    }
}

// MARK: - Pagination

extension ReviewViewModel {

    /// Appends the next page of reviews to the existing list.
    /// Guards against double-calls with `isLoadingMore`.
    func loadMoreReviews() async {
        guard canLoadMore, !isLoadingMore else { return }

        isLoadingMore = true
        defer { isLoadingMore = false }

        AppLog.firestore.debug("📄 ReviewViewModel.loadMoreReviews — productId: \(self.productId)")

        do {
            let result = try await service.fetchReviews(
                productId: productId,
                limit: pageSize,
                sort: sortOrder,
                after: lastDocument
            )
            reviews.append(contentsOf: result.reviews)
            lastDocument = result.lastDocument
            canLoadMore  = result.reviews.count == pageSize

            AppLog.firestore.debug("✅ loadMoreReviews — +\(result.reviews.count), canLoadMore: \(self.canLoadMore)")
        } catch {
            AppLog.firestore.error("❌ loadMoreReviews failed: \(error.localizedDescription)")
        }
    }
}

// MARK: - Submit / Edit

extension ReviewViewModel {

    /// Called when the user taps "Submit Review" or "Update Review" in RatingInputSheet.
    /// Routes to submitRating() or editRating() based on existingRating.
    func submitOrEdit() async {
        guard isInputValid else { return }
        guard let userId = currentUserId else {
            AlertManager.shared.showError(message: "Please log in to submit a review.")
            return
        }

        isSubmitting = true
        defer { isSubmitting = false }

        let trimmedBody = draftBody.trimmingCharacters(in: .whitespacesAndNewlines)
        let bodyToWrite = trimmedBody.isEmpty ? nil : trimmedBody

        do {
            if existingRating == nil {
                // MARK: First-time submit
                guard let orderId = proofOrderId else {
                    AlertManager.shared.showError(message: "No qualifying order found.")
                    return
                }

                AppLog.firestore.info("⭐ submitOrEdit — submitting new rating: \(self.draftScore)")

                let trimmedTitle = draftTitle.trimmingCharacters(in: .whitespacesAndNewlines)
                let titleToWrite = trimmedTitle.isEmpty ? nil : trimmedTitle

                try await service.submitRating(
                    productId: productId,
                    userId: userId,
                    userName: currentUserName,
                    orderId: orderId,
                    score: draftScore,
                    title: titleToWrite,
                    body: bodyToWrite
                )

                ToastManager.shared.showTop(
                    message: "Thanks for your review! ☕",
                    type: .success
                )
            } else {
                // MARK: Edit existing rating
                AppLog.firestore.info("✏️ submitOrEdit — editing rating: \(self.draftScore)")

                let trimmedTitle2 = draftTitle.trimmingCharacters(in: .whitespacesAndNewlines)
                let titleToWrite2 = trimmedTitle2.isEmpty ? nil : trimmedTitle2

                try await service.editRating(
                    productId: productId,
                    userId: userId,
                    userName: currentUserName,
                    newScore: draftScore,
                    newTitle: titleToWrite2,
                    newBody: bodyToWrite
                )

                ToastManager.shared.showTop(
                    message: "Review updated ✓",
                    type: .success
                )
            }

            // Refresh both the user's rating doc and page 1 of reviews
            await refreshAfterSubmit()
        } catch let error as RatingError {
            AppLog.firestore.error("❌ submitOrEdit RatingError: \(error.localizedDescription)")
            AlertManager.shared.showError(
                title: "Couldn't submit review",
                message: error.localizedDescription
            )
        } catch {
            AppLog.firestore.error("❌ submitOrEdit error: \(error.localizedDescription)")
            AlertManager.shared.showError(
                title: "Couldn't submit review",
                message: error.localizedDescription
            )
        }
    }

    /// Refreshes the user's own rating + page 1 of the review list after a write.
    /// Runs both concurrently.
    private func refreshAfterSubmit() async {
        async let ratingRefresh: Void = fetchUserRating(productId: productId)
        async let reviewRefresh: Void = loadReviews(productId: productId, reset: true)
        async let productRefresh: Void = refreshProductRatings()
        _ = await (ratingRefresh, reviewRefresh, productRefresh)
    }
    
    private func refreshProductRatings() async {
        do {
            let doc = try await Firestore.firestore()
                .collection(Firebase.Products.collection).document(productId).getDocument()
            let avg = doc.data()?["avgRating"] as? Double ?? 0.0
            let count = doc.data()?["ratingCount"] as? Int ?? 0
            let dist = doc.data()?["ratingDistribution"] as? [String: Int] ?? [:]
            latestProductRatings = (avg, count, dist)
        } catch { /* non-fatal */ }
    }
    
    /// Called when the user taps "Edit" on their existing review card.
    /// Pre-fills draftBody from the review text so the sheet opens with it populated.
    func prepareForEditing(existingReview: Review?) {
        draftScore = existingRating?.score ?? 0
        draftTitle = existingReview?.title ?? ""
        draftBody  = existingReview?.body  ?? ""
    }

    /// Resets draft state — called when the input sheet is dismissed without saving.
    func resetDraft() {
        draftScore = existingRating?.score ?? 0
        draftTitle = ""
        draftBody  = ""
    }
}

// MARK: - Helpful Toggle

extension ReviewViewModel {

    /// Optimistically updates the local review list, then writes to Firestore.
    /// If the Firestore write fails, rolls back the local change.
    func toggleHelpful(review: Review) async {
        guard let userId = currentUserId else {
            AlertManager.shared.showError(message: "Please log in to mark reviews as helpful.")
            return
        }
        guard let reviewId = review.id else { return }

        // MARK: Optimistic update — update list immediately for snappy UI
        let wasHelpful  = review.isHelpful(for: userId)
        let delta       = wasHelpful ? -1 : 1

        applyHelpfulUpdate(reviewId: reviewId, userId: userId, wasHelpful: wasHelpful, delta: delta)

        AppLog.firestore.debug("👍 toggleHelpful — reviewId: \(reviewId), wasHelpful: \(wasHelpful)")

        // MARK: Firestore write
        do {
            try await service.toggleHelpful(
                productId: productId,
                reviewId: reviewId,
                userId: userId
            )
            AppLog.firestore.debug("✅ toggleHelpful complete")
        } catch {
            // MARK: Rollback on failure
            AppLog.firestore.error("❌ toggleHelpful failed — rolling back: \(error.localizedDescription)")
            applyHelpfulUpdate(reviewId: reviewId, userId: userId, wasHelpful: !wasHelpful, delta: -delta)
            AlertManager.shared.showError(
                title: "Couldn't update",
                message: error.localizedDescription
            )
        }
    }

    /// Applies a local helpful state mutation to the reviews array.
    /// Used for both the optimistic update and the rollback.
    private func applyHelpfulUpdate(
        reviewId: String,
        userId: String,
        wasHelpful: Bool,
        delta: Int
    ) {
        guard let index = reviews.firstIndex(where: { $0.id == reviewId }) else { return }

        var updated = reviews[index]

        if wasHelpful {
            updated.helpfulBy     = updated.helpfulBy.filter { $0 != userId }
            updated.helpfulCount  = max(0, updated.helpfulCount - 1)
        } else {
            updated.helpfulBy.append(userId)
            updated.helpfulCount += 1
        }

        reviews[index] = updated
    }
}

// MARK: - Refresh

extension ReviewViewModel {

    /// Pull-to-refresh — resets to page 1 and refetches everything.
    func refresh() async {
        AppLog.firestore.debug("🔄 ReviewViewModel.refresh — productId: \(self.productId)")
        await loadInitialState(productId: productId)
    }
}
