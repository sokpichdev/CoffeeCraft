//
//  AnnouncementCardView.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 12/16/25.
//
import SwiftUI

struct AnnouncementCardView: View {
    let announcement: Announcement

    private let cardWidth: CGFloat = UIScreen.main.bounds.width - 32
    private var cardImageHeight: CGFloat { cardWidth * 9 / 16 }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            AsyncImageCard(
                imageURL: announcement.imageName ?? "",
                height: cardImageHeight,
                width: cardWidth,
                corner: 0
            )

            VStack(alignment: .leading, spacing: 5) {
                Text(announcement.title ?? "")
                    .font(.headline)
                    .foregroundColor(.primary)

                Text(announcement.description ?? "")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
            }
            .padding(.horizontal, 5)
            .padding(.bottom, 10)
        }
        .background(.ultraThinMaterial)
        .cornerRadius(15)
        .shadow(color: Color.textPrimary.opacity(0.2), radius: 5, x: 0, y: 3)
    }
}

struct AnnouncementCardShimmerView: View {

    private let cardWidth: CGFloat = UIScreen.main.bounds.width - 32
    private var cardImageHeight: CGFloat { cardWidth * 9 / 16 }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ShimmerView(cornerRadius: 0)
                .frame(width: cardWidth, height: cardImageHeight)

            VStack(alignment: .leading, spacing: 5) {
                ShimmerView().frame(width: cardWidth * 0.4, height: 17)
                ShimmerView().frame(height: 15)
            }
            .padding(.horizontal, 5)
            .padding(.bottom, 10)
        }
        .background(.ultraThinMaterial)
        .cornerRadius(15)
        .shadow(color: Color.textPrimary.opacity(0.2), radius: 5, x: 0, y: 3)
    }
}
