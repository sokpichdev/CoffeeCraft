//
//  ReviewSectionView.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 3/10/26.
//

import SwiftUI

// MARK: - ReviewSectionView

struct ReviewSectionView: View {

    @ObservedObject var vm: ReviewViewModel
    let product: Product

    /// Called when the user taps "Write a Review" or "Edit your review".
    /// Parent is responsible for presenting RatingInputSheet.
    let onWriteReview: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader
            ratingSummaryHeader
            reviewContent
        }
    }
}

// MARK: - Section Header

private extension ReviewSectionView {

    var sectionHeader: some View {
        SectionHeader(title: "Reviews", icon: "bubble.left.and.bubble.right.fill")
    }
}

// MARK: - Rating Summary Header

private extension ReviewSectionView {

    /// Shows the aggregate rating row + the Write / Edit CTA button.
    var ratingSummaryHeader: some View {
        HStack(alignment: .center, spacing: 0) {

            // Aggregate stars + count
            if product.hasRatings {
                VStack(alignment: .leading, spacing: 4) {
                    StarRatingView.summary(
                        average: product.displayRating,
                        count: product.displayRatingCount,
                        size: 18
                    )
                    Text("Based on \(product.displayRatingCount) rating\(product.displayRatingCount == 1 ? "" : "s")")
                        .font(.caption)
                        .foregroundColor(.textMuted)
                }
            } else {
                Text("No reviews yet")
                    .font(.subheadline)
                    .foregroundColor(.textMuted)
            }

            Spacer()

            // CTA — only shown when eligible or already reviewed
            if vm.canSubmitNewRating || vm.canEditRating {
                writeEditButton
            }
        }
        .padding(16)
        .background(Color.surfacePrimary)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(Color.borderColor.opacity(0.4), lineWidth: 1)
        )
    }

    var writeEditButton: some View {
        Button(action: onWriteReview) {
            HStack(spacing: 6) {
                Image(systemName: vm.canEditRating
                      ? "pencil.circle.fill"
                      : "star.bubble.fill")
                    .font(.system(size: 13, weight: .semibold))

                Text(vm.canEditRating ? "Edit review" : "Write a review")
                    .font(.system(size: 13, weight: .semibold))
            }
            .foregroundColor(.white)
            .padding(.horizontal, 14)
            .padding(.vertical, 9)
            .background(
                Capsule()
                    .fill(LinearGradient.brandPrimary)
                    .shadow(color: Color.accentPrimary.opacity(0.3), radius: 6, y: 3)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Review Content

private extension ReviewSectionView {

    @ViewBuilder
    var reviewContent: some View {
        if vm.isLoadingReviews {
            loadingSkeletons
        } else if vm.reviews.isEmpty && vm.existingRating == nil {
            emptyState
        } else {
            reviewList
        }
    }

    // MARK: Loading skeletons

    var loadingSkeletons: some View {
        VStack(spacing: 12) {
            ForEach(0..<3, id: \.self) { _ in
                ReviewCardShimmer()
            }
        }
    }

    // MARK: Empty state

    var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "bubble.left.and.bubble.right")
                .font(.system(size: 36))
                .foregroundColor(.textMuted.opacity(0.5))

            Text("No reviews yet")
                .font(.subheadline.weight(.medium))
                .foregroundColor(.textSecondary)

            if vm.canSubmitNewRating {
                Text("Be the first to share your experience!")
                    .font(.caption)
                    .foregroundColor(.textMuted)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 36)
    }

    // MARK: Review list

    var reviewList: some View {
        VStack(spacing: 12) {

            // ── User's own review — pinned at top ────────────────────
            if let ownReview = ownReview {
                ReviewCard(
                    review: ownReview,
                    vm: vm,
                    isOwn: true
                )
                .transition(.opacity.combined(with: .move(edge: .top)))

                if !otherReviews.isEmpty {
                    dividerWithLabel("Other reviews")
                }
            }

            // ── Other reviews ────────────────────────────────────────
            ForEach(otherReviews) { review in
                ReviewCard(review: review, vm: vm)
                    .transition(.opacity)
            }

            // ── Load More ────────────────────────────────────────────
            if vm.canLoadMore {
                loadMoreButton
            }
        }
        .animation(.easeInOut(duration: 0.25), value: vm.reviews.count)
    }

    // MARK: Helpers

    /// The current user's own review from the list, if present.
    var ownReview: Review? {
        guard let userId = UserSession.shared.userId else { return nil }
        return vm.reviews.first { $0.userId == userId }
    }

    /// All reviews except the current user's own.
    var otherReviews: [Review] {
        guard let userId = UserSession.shared.userId else { return vm.reviews }
        return vm.reviews.filter { $0.userId != userId }
    }

    func dividerWithLabel(_ label: String) -> some View {
        HStack(spacing: 8) {
            Rectangle()
                .fill(Color.borderColor.opacity(0.5))
                .frame(height: 1)

            Text(label)
                .font(.caption)
                .foregroundColor(.textMuted)
                .fixedSize()

            Rectangle()
                .fill(Color.borderColor.opacity(0.5))
                .frame(height: 1)
        }
        .padding(.vertical, 4)
    }

    // MARK: Load More button

    var loadMoreButton: some View {
        Button {
            Task { await vm.loadMoreReviews() }
        } label: {
            HStack(spacing: 8) {
                if vm.isLoadingMore {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .scaleEffect(0.8)
                        .tint(.accentPrimary)
                } else {
                    Image(systemName: "arrow.down.circle")
                        .font(.system(size: 14, weight: .medium))
                }

                Text(vm.isLoadingMore ? "Loading…" : "Load more reviews")
                    .font(.subheadline.weight(.medium))
            }
            .foregroundColor(.accentPrimary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color.accentPrimary.opacity(0.08))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .strokeBorder(Color.accentPrimary.opacity(0.2), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
        .disabled(vm.isLoadingMore)
    }
}
