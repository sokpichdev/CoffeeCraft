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
    let onSeeAll: () -> Void
    let onWriteReview: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            seeAllHeader
            ratingRow
            previewScroll
            tapToRateBlock
        }
    }
}

// MARK: - "Ratings & Reviews >" header

private extension ReviewSectionView {

    var seeAllHeader: some View {
        Button(action: onSeeAll) {
            HStack(spacing: 4) {
                Text("Ratings & Reviews")
                    .font(.system(size: 17, weight: .semibold, design: .serif))
                    .foregroundColor(.textPrimary)

                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.textSecondary)

                Spacer()
            }
            .padding(.horizontal)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Avg score row

private extension ReviewSectionView {

    var ratingRow: some View {
        HStack(alignment: .center, spacing: 20) {

            // Left — large numeric score
            VStack(alignment: .leading, spacing: 2) {
                Text(product.hasRatings
                     ? String(format: "%.1f", product.displayRating)
                     : "–")
                    .font(.system(size: 52, weight: .bold, design: .rounded))
                    .foregroundColor(.textPrimary)
                    .monospacedDigit()

                Text("out of 5")
                    .font(.caption)
                    .foregroundColor(.textMuted)
            }

            Spacer()

            // Right — stars + count
            VStack(alignment: .trailing, spacing: 6) {
                StarRatingView(
                    mode: .readOnly(average: product.displayRating),
                    size: 20
                )

                if product.hasRatings {
                    Text("\(product.displayRatingCount.formatted()) Ratings")
                        .font(.caption)
                        .foregroundColor(.textMuted)
                }
            }
        }
        .padding(.horizontal)
    }
}

// MARK: - Horizontal preview scroll

private extension ReviewSectionView {

    @ViewBuilder
    var previewScroll: some View {
        if vm.isLoadingReviews {
            shimmerRow
        } else if vm.reviews.isEmpty {
            noReviewsLabel
        } else {
            reviewCardsScroll
        }
    }

    var shimmerRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(0..<2, id: \.self) { _ in
                    ReviewCardShimmer()
                        .frame(width: 280)
                }
            }
            .padding(.horizontal, 1)
        }
    }

    var noReviewsLabel: some View {
        Text("No reviews yet — be the first!")
            .font(.subheadline)
            .foregroundColor(.textMuted)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    var reviewCardsScroll: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(alignment: .top, spacing: 12) {
                ForEach(vm.reviews.prefix(3)) { review in
                    ReviewCard(review: review, vm: vm)
                        .frame(width: 280)
                }

                if vm.reviews.count >= 3 {
                    seeAllCard
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 4)
        }
    }

    var seeAllCard: some View {
        Button(action: onSeeAll) {
            VStack(spacing: 8) {
                Image(systemName: "arrow.right.circle.fill")
                    .font(.system(size: 28))
                    .foregroundColor(.accentPrimary)

                Text("See All\nReviews")
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.accentPrimary)
                    .multilineTextAlignment(.center)
            }
            .frame(width: 100, height: 120)
            .background(Color.surfacePrimary)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .strokeBorder(Color.accentPrimary.opacity(0.2), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Tap to Rate block

private extension ReviewSectionView {

    var tapToRateBlock: some View {
        VStack(spacing: 12) {
            Divider().opacity(0.5)

            Text("Tap to Rate")
                .font(.subheadline.weight(.medium))
                .foregroundColor(.textSecondary)

            QuickRateStars(vm: vm, onTap: onWriteReview)

            if vm.canSubmitNewRating || vm.canEditRating {
                writeReviewButton
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal)
    }

    var writeReviewButton: some View {
        Button(action: onWriteReview) {
            HStack(spacing: 6) {
                Image(systemName: vm.canEditRating ? "pencil.circle.fill" : "square.and.pencil")
                    .font(.system(size: 13, weight: .semibold))
                Text(vm.canEditRating ? "Edit your review" : "Write a Review")
                    .font(.system(size: 13, weight: .semibold))
            }
            .foregroundColor(.accentPrimary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 11)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.accentPrimary.opacity(0.08))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .strokeBorder(Color.accentPrimary.opacity(0.25), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - QuickRateStars

private struct QuickRateStars: View {
    @ObservedObject var vm: ReviewViewModel
    let onTap: () -> Void

    var body: some View {
        HStack(spacing: 10) {
            ForEach(1...5, id: \.self) { score in
                Image(systemName: score <= (vm.existingRating?.score ?? 0) ? "star.fill" : "star")
                    .font(.system(size: 30))
                    .foregroundColor(.accentGold)
                    .onTapGesture {
                        vm.draftScore = score
                        onTap()
                    }
            }
        }
    }
}
