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

    /// When true — renders the "Your review" highlighted variant.
    var isOwn: Bool = false

    // MARK: Body

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            headerRow
                .padding(.bottom, 10)

            starRow
                .padding(.bottom, review.hasBody ? 10 : 0)

            if review.hasBody, let body = review.body {
                bodyText(body)
                    .padding(.bottom, 12)
            }

            helpfulRow
        }
        .padding(16)
        .background(cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(cardBorder)
        .shadow(color: Color.textPrimary.opacity(isOwn ? 0.06 : 0.04), radius: 6, x: 0, y: 2)
    }
}

// MARK: - Header Row

private extension ReviewCard {

    var headerRow: some View {
        HStack(alignment: .top, spacing: 10) {
            avatarCircle

            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    Text(review.userName)
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(.textPrimary)

                    if isOwn {
                        ownBadge
                    }
                }

                Text(review.displayDate)
                    .font(.caption)
                    .foregroundColor(.textMuted)
            }

            Spacer()

            // Edited indicator
            if review.updatedAt != nil {
                Text("Edited")
                    .font(.caption2)
                    .foregroundColor(.textMuted)
                    .padding(.horizontal, 7)
                    .padding(.vertical, 3)
                    .background(Capsule().fill(Color.surfaceSub))
            }
        }
    }

    var avatarCircle: some View {
        Text(review.avatarInitial)
            .font(.system(size: 16, weight: .bold))
            .foregroundColor(.white)
            .frame(width: 36, height: 36)
            .background(
                // Deterministic color from the first character — consistent across sessions
                Circle().fill(avatarColor(for: review.userName))
            )
    }

    /// Maps a name string to one of several accent-adjacent colors deterministically.
    /// Same name always produces the same color — no randomness.
    func avatarColor(for name: String) -> Color {
        let colors: [Color] = [
            .accentPrimary,
            .accentGold,
            Color(hex: "#5B8DB8"),   // muted blue
            Color(hex: "#7B9E6B"),   // sage green
            Color(hex: "#B87B5B")   // warm sienna
        ]
        let index = abs(name.hashValue) % colors.count
        return colors[index]
    }

    var ownBadge: some View {
        Text("Your review")
            .font(.caption2.weight(.semibold))
            .foregroundColor(.accentPrimary)
            .padding(.horizontal, 7)
            .padding(.vertical, 3)
            .background(
                Capsule()
                    .fill(Color.accentPrimary.opacity(0.12))
                    .overlay(Capsule().strokeBorder(Color.accentPrimary.opacity(0.25), lineWidth: 1))
            )
    }
}

// MARK: - Star Row

private extension ReviewCard {

    var starRow: some View {
        StarRatingView(
            mode: .readOnly(average: Double(review.rating)),
            size: 14,
            emptyColor: Color.textMuted.opacity(0.3)
        )
    }
}

// MARK: - Body Text

private extension ReviewCard {

    func bodyText(_ body: String) -> some View {
        Text(body)
            .font(.subheadline)
            .foregroundColor(.textSecondary)
            .fixedSize(horizontal: false, vertical: true)   // allow multi-line
            .lineSpacing(3)
    }
}

// MARK: - Helpful Row

private extension ReviewCard {

    var helpfulRow: some View {
        HStack {
            Spacer()
            helpfulButton
        }
    }

    var helpfulButton: some View {
        let userId    = UserSession.shared.userId ?? ""
        let isHelpful = review.isHelpful(for: userId)
        let isOwner   = review.userId == userId

        return Button {
            Task { await vm.toggleHelpful(review: review) }
        } label: {
            HStack(spacing: 5) {
                Image(systemName: isHelpful ? "hand.thumbsup.fill" : "hand.thumbsup")
                    .font(.system(size: 12, weight: .medium))
                    .symbolEffect(.bounce, value: isHelpful)

                Text(helpfulLabel(count: review.helpfulCount, isHelpful: isHelpful))
                    .font(.caption.weight(.medium))
            }
            .foregroundColor(isHelpful ? .accentPrimary : .textMuted)
            .padding(.horizontal, 12)
            .padding(.vertical, 7)
            .background(
                Capsule()
                    .fill(isHelpful
                          ? Color.accentPrimary.opacity(0.10)
                          : Color.surfaceSub)
                    .overlay(
                        Capsule().strokeBorder(
                            isHelpful
                                ? Color.accentPrimary.opacity(0.3)
                                : Color.borderColor.opacity(0.5),
                            lineWidth: 1
                        )
                    )
            )
            .animation(.spring(response: 0.25, dampingFraction: 0.6), value: isHelpful)
        }
        .buttonStyle(.plain)
        // Owners can't mark their own review as helpful
        .disabled(isOwner)
        .opacity(isOwner ? 0.4 : 1.0)
    }

    func helpfulLabel(count: Int, isHelpful: Bool) -> String {
        if count == 0 { return "Helpful" }
        return isHelpful ? "Helpful (\(count))" : "\(count) found this helpful"
    }
}

// MARK: - Card Styling

private extension ReviewCard {

    @ViewBuilder
    var cardBackground: some View {
        if isOwn {
            Color.accentPrimary.opacity(0.04)
        } else {
            Color.surfacePrimary
        }
    }

    var cardBorder: some View {
        RoundedRectangle(cornerRadius: 20)
            .strokeBorder(
                isOwn
                    ? Color.accentPrimary.opacity(0.2)
                    : Color.borderColor.opacity(0.4),
                lineWidth: isOwn ? 1.5 : 1
            )
    }
}

// MARK: - Shimmer Placeholder

/// Shown while the first page of reviews is loading.
struct ReviewCardShimmer: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                ShimmerView(cornerRadius: 18).frame(width: 36, height: 36)
                VStack(alignment: .leading, spacing: 5) {
                    ShimmerView(cornerRadius: 4).frame(width: 100, height: 12)
                    ShimmerView(cornerRadius: 4).frame(width: 60, height: 10)
                }
            }
            ShimmerView(cornerRadius: 4).frame(width: 80, height: 12)
            ShimmerView(cornerRadius: 4).frame(maxWidth: .infinity).frame(height: 12)
            ShimmerView(cornerRadius: 4).frame(width: 180, height: 12)
        }
        .padding(16)
        .background(Color.surfacePrimary)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}
