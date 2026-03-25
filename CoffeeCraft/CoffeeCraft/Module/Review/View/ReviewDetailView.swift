//
//  ReviewDetailView.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 3/25/26.
//

import SwiftUI

struct ReviewDetailView: View {

    let review: Review
    @ObservedObject var vm: ReviewViewModel
    var isOwn: Bool = false

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                authorHeader
                ratingSection
                contentSection
                helpfulSection
                Spacer(minLength: 40)
            }
            .padding(20)
        }
        .background(Color.bgSecondary)
        .customNavigationBar("Review") {
            ToolBarButton.back { dismiss() }
        }
    }
}

// MARK: - Author header
extension ReviewDetailView {

    var authorHeader: some View {
        HStack(spacing: 14) {
            // Avatar
            Text(review.avatarInitial)
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(.white)
                .frame(width: 50, height: 50)
                .background(Circle().fill(Color.accentPrimary.opacity(0.8)))

            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 6) {
                    Text(review.userName)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.textPrimary)

                    if isOwn {
                        Text("You")
                            .font(.caption.weight(.semibold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 7)
                            .padding(.vertical, 2)
                            .background(Capsule().fill(Color.accentPrimary))
                    }
                }

                Text(review.displayDate)
                    .font(.subheadline)
                    .foregroundColor(.textMuted)

                if review.sortTimestamp != review.createdAt {
                    Text("Edited \(review.relativeDate)")
                        .font(.caption)
                        .foregroundColor(.textMuted.opacity(0.7))
                }
            }

            Spacer()
        }
        .padding(16)
        .background(Color.surfacePrimary)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - Rating section

extension ReviewDetailView {

    var ratingSection: some View {
        HStack(spacing: 12) {
            StarRatingView(
                mode: .readOnly(average: Double(review.rating)),
                size: 22
            )

            Text("\(review.rating) out of 5")
                .font(.subheadline)
                .foregroundColor(.textMuted)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.surfacePrimary)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - Content section (title + body — full, no line limit)

extension ReviewDetailView {

    @ViewBuilder
    var contentSection: some View {
        if review.hasTitle || review.hasBody {
            VStack(alignment: .leading, spacing: 14) {
                if review.hasTitle, let title = review.title {
                    Text(title)
                        .font(.system(size: 17, weight: .semibold, design: .serif))
                        .foregroundColor(.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                if review.hasBody, let body = review.body {
                    Text(body)
                        .font(.body)
                        .foregroundColor(.textSecondary)
                        .lineSpacing(4)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.surfacePrimary)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }
}

// MARK: - Helpful section

extension ReviewDetailView {

    var helpfulSection: some View {
        let userId = UserSession.shared.userId ?? ""
        let isHelpful = review.isHelpful(for: userId)

        return VStack(spacing: 12) {
            if review.helpfulCount > 0 {
                Text("\(review.helpfulCount) \(review.helpfulCount == 1 ? "person" : "people") found this helpful")
                    .font(.subheadline)
                    .foregroundColor(.textMuted)
                    .frame(maxWidth: .infinity, alignment: .center)
            }

            Button {
                Task { await vm.toggleHelpful(review: review) }
            } label: {
                HStack(spacing: 7) {
                    Image(systemName: isHelpful ? "hand.thumbsup.fill" : "hand.thumbsup")
                        .font(.system(size: 14, weight: .medium))
                    Text(isHelpful ? "Marked as Helpful" : "Mark as Helpful")
                        .font(.system(size: 14, weight: .semibold))
                }
                .foregroundColor(isHelpful ? .white : .accentPrimary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 13)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(isHelpful
                              ? Color.accentPrimary
                              : Color.accentPrimary.opacity(0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .strokeBorder(
                                    isHelpful ? Color.clear : Color.accentPrimary.opacity(0.3),
                                    lineWidth: 1
                                )
                        )
                )
            }
            .buttonStyle(.plain)
            .animation(.easeInOut(duration: 0.2), value: isHelpful)
        }
        .padding(16)
        .background(Color.surfacePrimary)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}
