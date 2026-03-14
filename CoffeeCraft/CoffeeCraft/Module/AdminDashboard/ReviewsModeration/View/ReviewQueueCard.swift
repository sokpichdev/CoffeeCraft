//
//  ReviewQueueCard.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 3/14/26.
//
import SwiftUI

struct ReviewQueueCard: View {
    let review: ReviewItem
    let isToggling: Bool
    let onToggle: () async -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {

            // Product + customer header
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(review.productName)
                        .font(.caption.weight(.bold))
                        .foregroundStyle(Color.accentPrimary)
                    Text(review.customerName)
                        .font(.caption)
                        .foregroundStyle(Color.textMuted)
                }
                Spacer()
                if review.isHidden {
                    Label("Hidden", systemImage: "eye.slash.fill")
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(.orange)
                        .padding(.horizontal, 9)
                        .padding(.vertical, 4)
                        .background(Color.orange.opacity(0.10), in: Capsule())
                        .overlay(Capsule().stroke(Color.orange.opacity(0.25), lineWidth: 1))
                }
            }

            // Stars + date
            HStack(spacing: 6) {
                HStack(spacing: 2) {
                    ForEach(1...5, id: \.self) { idx in
                        Image(systemName: idx <= review.rating ? "star.fill" : "star")
                            .font(.system(size: 11))
                            .foregroundStyle(idx <= review.rating ? Color.accentGold : Color.borderColor)
                    }
                }
                Text("·").foregroundStyle(Color.borderColor)
                Text(review.timestampFormatted)
                    .font(.caption2)
                    .foregroundStyle(Color.textMuted)
            }

            // Review body
            Text(review.excerpt)
                .font(.subheadline)
                .foregroundStyle(Color.textPrimary)
                .lineLimit(3)
                .fixedSize(horizontal: false, vertical: true)

            Divider().background(Color.borderColor)

            // Action
            HStack {
                Spacer()
                Button {
                    Task { await onToggle() }
                } label: {
                    if isToggling {
                        ProgressView().scaleEffect(0.8).frame(width: 80, height: 28)
                    } else {
                        Label(
                            review.isHidden ? "Unhide" : "Hide",
                            systemImage: review.isHidden ? "eye.fill" : "eye.slash.fill"
                        )
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(review.isHidden ? Color.semanticSuccess : .orange)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 7)
                        .background(
                            (review.isHidden ? Color.semanticSuccess : Color.orange).opacity(0.10),
                            in: Capsule()
                        )
                        .overlay(
                            Capsule().stroke(
                                (review.isHidden ? Color.semanticSuccess : Color.orange).opacity(0.25),
                                lineWidth: 1
                            )
                        )
                    }
                }
                .buttonStyle(.plain)
                .disabled(isToggling)
            }
        }
        .padding(16)
        .background(
            review.isHidden ? Color.surfaceSub : Color.surfacePrimary,
            in: RoundedRectangle(cornerRadius: 16)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(review.isHidden ? Color.orange.opacity(0.22) : Color.borderColor, lineWidth: 1)
        )
        .opacity(review.isHidden ? 0.78 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: review.isHidden)
        .shadow(color: Color.black.opacity(0.03), radius: 6, x: 0, y: 2)
    }
}
