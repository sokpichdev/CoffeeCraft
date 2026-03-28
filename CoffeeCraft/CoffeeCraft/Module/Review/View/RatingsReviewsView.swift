//
//  RatingsReviewsView.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 3/10/26.
//

import SwiftUI

// MARK: - RatingsReviewsView

struct RatingsReviewsView: View {

    @ObservedObject var vm: ReviewViewModel
    let product: Product
    let onWriteReview: () -> Void   // bubbles back to ProductDetailView sheet

    @Environment(\.dismiss) private var dismiss

    @State private var selectedReview: Review?

    var body: some View {
        CustomRefreshScrollView({
            VStack(alignment: .leading, spacing: 0) {
                VStack(alignment: .leading, spacing: 20) {
                    ratingHeader
                    distributionBars
                    Divider().opacity(0.5)
                    sortAndWriteRow
                    reviewList
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 20)
            }
        })
        .background(Color.bgSecondary)
        .customNavigationBar("Ratings & Reviews") {
            ToolBarButton.back { dismiss() }
        }
        .navigationDestination(item: $selectedReview) { review in
            ReviewDetailView(review: review, vm: vm, isOwn: review.userId == UserSession.shared.userId)
        }
    }
}

// MARK: - Rating header (big number + stars)

private extension RatingsReviewsView {

    var ratingHeader: some View {
        HStack(alignment: .center, spacing: 20) {

            VStack(alignment: .leading, spacing: 2) {
                Text(product.hasRatings
                     ? String(format: "%.1f", product.displayRating)
                     : "–")
                    .font(.system(size: 64, weight: .bold, design: .rounded))
                    .foregroundColor(.textPrimary)
                    .monospacedDigit()

                Text("out of 5")
                    .font(.subheadline)
                    .foregroundColor(.textMuted)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 8) {
                StarRatingView(
                    mode: .readOnly(average: product.displayRating),
                    size: 22
                )

                if product.hasRatings {
                    Text("\(product.displayRatingCount.formatted()) Ratings")
                        .font(.subheadline)
                        .foregroundColor(.textMuted)
                }
            }
        }
    }
}

// MARK: - Distribution bars

private extension RatingsReviewsView {

    var distributionBars: some View {
        let maxCount = product.orderedDistribution.map(\.count).max() ?? 1

        return VStack(spacing: 7) {
            ForEach(Array(product.orderedDistribution.enumerated()), id: \.offset) { _, entry in
                HStack(spacing: 10) {
                    Text("\(entry.score)")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.textMuted)
                        .frame(width: 12, alignment: .trailing)

                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Capsule()
                                .fill(Color.surfaceSub)
                                .frame(height: 8)

                            if entry.count == 0 {
                                Capsule()
                                    .fill(Color.clear)
                                    .frame(width: 0, height: 8)
                                    .animation(
                                        .easeOut(duration: 0.5).delay(Double(5 - entry.score) * 0.06),
                                        value: entry.count
                                    )
                            } else {
                                Capsule()
                                    .fill(LinearGradient.brandPrimary)
                                    .frame(
                                        width: geo.size.width * CGFloat(entry.count) / CGFloat(max(1, maxCount)),
                                        height: 8)
                                    .animation(
                                        .easeOut(duration: 0.5).delay(Double(5 - entry.score) * 0.06),
                                        value: entry.count
                                    )
                            }
                        }
                    }
                    .frame(height: 8)
                }
            }
        }
    }
}

// MARK: - Sort picker + Write a Review

private extension RatingsReviewsView {

    var sortAndWriteRow: some View {
        HStack {
            // Sort menu
            Menu {
                ForEach(ReviewSortOrder.allCases) { order in
                    Button {
                        Task { await vm.changeSortOrder(to: order) }
                    } label: {
                        HStack {
                            Text(order.rawValue)
                            if vm.sortOrder == order {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
            } label: {
                HStack(spacing: 4) {
                    Text(vm.sortOrder.rawValue)
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(.accentPrimary)
                    Image(systemName: "chevron.down")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(.accentPrimary)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 7)
                .background(Capsule().fill(Color.accentPrimary.opacity(0.08)))
            }

            Spacer()

            // Write / Edit CTA
            if vm.canSubmitNewRating || vm.canEditRating {
                Button(action: onWriteReview) {
                    HStack(spacing: 5) {
                        Image(systemName: vm.canEditRating ? "pencil.circle.fill" : "square.and.pencil")
                            .font(.system(size: 12, weight: .semibold))
                        Text(vm.canEditRating ? "Edit review" : "Write a Review")
                            .font(.system(size: 13, weight: .semibold))
                    }
                    .foregroundColor(.accentPrimary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 7)
                    .background(
                        Capsule()
                            .fill(Color.accentPrimary.opacity(0.08))
                            .overlay(Capsule().strokeBorder(Color.accentPrimary.opacity(0.25), lineWidth: 1))
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }
}

// MARK: - Review list

private extension RatingsReviewsView {

    @ViewBuilder
    var reviewList: some View {
        if vm.isLoadingReviews {
            VStack(spacing: 12) {
                ForEach(0..<4, id: \.self) { _ in ReviewCardShimmer() }
            }
        } else if vm.reviews.isEmpty {
            emptyState
        } else {
            fullList
        }
    }

    var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "bubble.left.and.bubble.right")
                .font(.system(size: 40))
                .foregroundColor(.textMuted.opacity(0.4))
            Text("No reviews yet")
                .font(.subheadline.weight(.medium))
                .foregroundColor(.textSecondary)
            if vm.canSubmitNewRating {
                Text("Be the first to share your experience!")
                    .font(.caption)
                    .foregroundColor(.textMuted)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 48)
    }

    var fullList: some View {
        VStack(spacing: 12) {

            // Own review pinned at top
            if let own = ownReview {
                ReviewCard(review: own, vm: vm, isOwn: true, onTap: { selectedReview = own })
                .transition(.opacity.combined(with: .move(edge: .top)))

                if !otherReviews.isEmpty {
                    labelledDivider("Other reviews")
                }
            }

            ForEach(otherReviews) { review in
                ReviewCard(review: review, vm: vm, onTap: { selectedReview = review })
                .transition(.opacity)
            }

            if vm.canLoadMore {
                loadMoreButton
            }
        }
        .animation(.easeInOut(duration: 0.2), value: vm.reviews.count)
    }

    var ownReview: Review? {
        guard let userId = UserSession.shared.userId else { return nil }
        return vm.reviews.first { $0.userId == userId }
    }

    var otherReviews: [Review] {
        guard let userId = UserSession.shared.userId else { return vm.reviews }
        return vm.reviews.filter { $0.userId != userId }
    }

    func labelledDivider(_ label: String) -> some View {
        HStack(spacing: 8) {
            Rectangle().fill(Color.borderColor.opacity(0.5)).frame(height: 1)
            Text(label).font(.caption).foregroundColor(.textMuted).fixedSize()
            Rectangle().fill(Color.borderColor.opacity(0.5)).frame(height: 1)
        }
        .padding(.vertical, 4)
    }

    var loadMoreButton: some View {
        Button {
            Task { await vm.loadMoreReviews() }
        } label: {
            HStack(spacing: 8) {
                if vm.isLoadingMore {
                    ProgressView().progressViewStyle(.circular).scaleEffect(0.8).tint(.accentPrimary)
                } else {
                    Image(systemName: "arrow.down.circle").font(.system(size: 14, weight: .medium))
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
