//
//  OrderCardShimmerView.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 2/24/26.
//
import SwiftUI

struct OrderCardShimmerView: View {
    var showAdminActions: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            headerSectionShimmer
            itemsPreviewSectionShimmer
            Divider().padding(.horizontal)
            footerSectionShimmer

            if showAdminActions {
                Divider()
                HStack(spacing: 8) {
                    ForEach(0..<3, id: \.self) { i in
                        ShimmerView()
                            .frame(width: CGFloat(65 + (10 * i)), height: 40)
                            .clipShape(Capsule())
                    }
                }
                .padding()
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color(uiColor: .tertiarySystemBackground))
        )
        .shadow(color: Color.textPrimary.opacity(0.05), radius: 4, x: 0, y: 2)
        .contentShape(Rectangle())
    }

    private var headerSectionShimmer: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                ShimmerView().frame(width: 60, height: 16)
                ShimmerView().frame(width: 100, height: 12)
            }

            Spacer()

            HStack(spacing: 6) {
                Circle()
                    .fill(Color.accentPrimary.opacity(0.2))
                    .frame(width: 8, height: 8)
                ShimmerView().frame(width: 50, height: 15)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(Color.accentPrimary.opacity(0.15))
            .cornerRadius(20)
            .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.accentPrimary.opacity(0.2), lineWidth: 1))
        }
        .padding()
        .background(
            LinearGradient(
                colors: [Color.accentPrimary.opacity(0.05), Color.clear],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(24, corners: [.topLeft, .topRight])
    }

    private var itemsPreviewSectionShimmer: some View {
        HStack(spacing: 12) {
            // FlyingThumbnail stack
            ZStack(alignment: .leading) {
                ForEach(0..<4, id: \.self) { index in
                    ShimmerView()
                        .frame(width: 32, height: 32)
                        .clipShape(Circle())
                        .offset(x: CGFloat(index * 20))
                }
            }
            .frame(height: 32)

            Spacer()

            // Details/Less pill button
            ShimmerView()
                .frame(width: 72, height: 28)
                .clipShape(Capsule())
        }
        .padding()
    }

    private var footerSectionShimmer: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                ShimmerView().frame(width: 70, height: 12)
                ShimmerView().frame(width: 90, height: 20)
            }

            Spacer()

            ShimmerView()
                .frame(width: 17, height: 17)
                .clipShape(RoundedRectangle(cornerRadius: 2))
        }
        .frame(height: 32)
        .padding()
    }
}

struct OrderListShimmerView: View {
    var showAdminActions: Bool = false
    var count: Int = 5

    var body: some View {
        LazyVStack(spacing: 8) {
            ForEach(0..<count, id: \.self) { _ in
                OrderCardShimmerView(showAdminActions: showAdminActions)
            }
        }
        .padding(.bottom)
        .disabled(true)
        .allowsHitTesting(false)
    }
}
