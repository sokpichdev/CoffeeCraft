//
//  ReviewCard.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 3/10/26.
//

import SwiftUI

// MARK: - ReviewCard

struct ReviewCard: View {

    let review: Review
    @ObservedObject var vm: ReviewViewModel
    var isOwn: Bool = false
    /// Called when the card is tapped — parent pushes ReviewDetailView.
    var onTap: (() -> Void)? = nil

    // Fixed two-line height for 13pt font (lineHeight ≈ 18pt × 2 lines)
    private let textBlockHeight: CGFloat = 36

    var body: some View {
        Button {
            onTap?()
        } label: {
            cardContent
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Card layout

private extension ReviewCard {

    var cardContent: some View {
        VStack(alignment: .leading, spacing: 10) {
            headerRow
            starRow

            // Title 2 lines of space
            VStack(alignment: .leading, spacing: 10) {
                if review.hasTitle, let title = review.title {
                    Text(title)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.textPrimary)
                        .lineLimit(2)
                        .truncationMode(.tail)
                }

                // Body 2 lines of space
                if review.hasBody, let body = review.body {
                    Text(body)
                        .font(.system(size: 13))
                        .foregroundColor(.textSecondary)
                        .lineLimit(2)
                        .truncationMode(.tail)
                }
                Spacer(minLength: 0)
            }
            .frame(height: textBlockHeight * 2)

            Spacer()
            footerRow
        }
        .padding(14)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.surfacePrimary)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .strokeBorder(
                    isOwn
                        ? Color.accentPrimary.opacity(0.35)
                        : Color.borderColor.opacity(0.5),
                    lineWidth: isOwn ? 1.5 : 1
                )
        )
        .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 2)
    }
}

// MARK: - Sub-views

private extension ReviewCard {

    // Avatar + name + date
    var headerRow: some View {
        HStack(spacing: 10) {
            avatarCircle
            VStack(alignment: .leading, spacing: 1) {
                HStack(spacing: 4) {
                    Text(review.userName)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.textPrimary)
                        .lineLimit(1)
                    if isOwn {
                        Text("(You)")
                            .font(.caption2.weight(.medium))
                            .foregroundColor(.accentPrimary)
                    }
                }
                Text(review.displayDate)
                    .font(.caption)
                    .foregroundColor(.textMuted)
            }
            Spacer(minLength: 0)

            // Chevron hint — only when tappable
            if onTap != nil {
                Image(systemName: "chevron.right")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.textMuted.opacity(0.5))
            }
        }
    }

    var avatarCircle: some View {
        Text(review.avatarInitial)
            .font(.system(size: 14, weight: .bold))
            .foregroundColor(.white)
            .frame(width: 32, height: 32)
            .background(Circle().fill(Color.accentPrimary.opacity(0.75)))
    }

    var starRow: some View {
        StarRatingView(
            mode: .readOnly(average: Double(review.rating)),
            size: 14
        )
    }

    var footerRow: some View {
        HStack {
            if review.helpfulCount > 0 {
                Text("\(review.helpfulCount) found helpful")
                    .font(.caption)
                    .foregroundColor(.textMuted)
            }
            Spacer()
            helpfulButton
        }
    }

    var helpfulButton: some View {
        let userId = UserSession.shared.userId ?? ""
        let isHelpful = review.isHelpful(for: userId)

        return Button {
            Task { await vm.toggleHelpful(review: review) }
        } label: {
            HStack(spacing: 4) {
                Image(systemName: isHelpful ? "hand.thumbsup.fill" : "hand.thumbsup")
                    .font(.system(size: 11, weight: .medium))
                Text("Helpful")
                    .font(.caption.weight(.medium))
            }
            .foregroundColor(isHelpful ? .accentPrimary : .textMuted)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(
                Capsule()
                    .fill(isHelpful
                          ? Color.accentPrimary.opacity(0.1)
                          : Color.surfaceSub)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Shimmer placeholder

struct ReviewCardShimmer: View {
    @State private var shimmerOn = false

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                Circle().frame(width: 32, height: 32)
                VStack(alignment: .leading, spacing: 4) {
                    RoundedRectangle(cornerRadius: 4).frame(width: 100, height: 11)
                    RoundedRectangle(cornerRadius: 4).frame(width: 60, height: 9)
                }
                Spacer()
            }
            RoundedRectangle(cornerRadius: 4).frame(height: 11)
            VStack(alignment: .leading, spacing: 5) {
                RoundedRectangle(cornerRadius: 4).frame(height: 11)
                RoundedRectangle(cornerRadius: 4).frame(width: 160, height: 11)
            }
            .frame(height: 36, alignment: .top)
            VStack(alignment: .leading, spacing: 5) {
                RoundedRectangle(cornerRadius: 4).frame(height: 9)
                RoundedRectangle(cornerRadius: 4).frame(width: 180, height: 9)
            }
            .frame(height: 36, alignment: .top)
            Spacer(minLength: 0)
            RoundedRectangle(cornerRadius: 12).frame(width: 72, height: 26).frame(maxWidth: .infinity, alignment: .trailing)
        }
        .padding(14)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .foregroundColor(Color.surfaceSub)
        .background(Color.surfacePrimary)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(RoundedRectangle(cornerRadius: 20).strokeBorder(Color.borderColor.opacity(0.4), lineWidth: 1))
        .opacity(shimmerOn ? 0.5 : 1.0)
        .animation(.easeInOut(duration: 0.85).repeatForever(autoreverses: true), value: shimmerOn)
        .onAppear { shimmerOn = true }
    }
}
