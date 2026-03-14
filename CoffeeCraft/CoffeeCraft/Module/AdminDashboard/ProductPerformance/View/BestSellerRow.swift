//
//  BestSellerRow.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 3/14/26.
//
import SwiftUI

struct BestSellerRow: View {
    let item: ProductStatItem
    let maxUnits: Int

    // Pre-compute ratio once — not recalculated on scroll
    private var ratio: Double {
        maxUnits > 0 ? min(Double(item.unitsSold) / Double(maxUnits), 1.0) : 0
    }

    var body: some View {
        VStack(spacing: 6) {
            HStack(spacing: 8) {
                rankBadge
                productInfo
                Text("\(item.unitsSold)")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.textPrimary)
                    .frame(width: 44, alignment: .trailing)
                Text(item.revenueFormatted)
                    .font(.caption.weight(.medium))
                    .foregroundStyle(Color.textMuted)
                    .frame(width: 72, alignment: .trailing)
                ratingView
            }

            progressBar
                .padding(.leading, 30)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 16)
    }

    private var rankBadge: some View {
        ZStack {
            Circle().fill(rankColor).frame(width: 22, height: 22)
            Text("\(item.rank)")
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(item.rank <= 3 ? .white : Color.textSecondary)
        }
    }

    private var productInfo: some View {
        VStack(alignment: .leading, spacing: 1) {
            Text(item.name)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(Color.textPrimary)
                .lineLimit(1)
            Text(item.category)
                .font(.caption2)
                .foregroundStyle(Color.textMuted)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var ratingView: some View {
        HStack(spacing: 2) {
            Image(systemName: "star.fill")
                .font(.system(size: 9))
                .foregroundStyle(.yellow)
            Text(item.hasRatings ? item.avgRatingFormatted : "—")
                .font(.caption)
                .foregroundStyle(Color.textSecondary)
        }
        .frame(width: 34, alignment: .trailing)
    }

    /// Canvas-based bar: one Metal draw call instead of two Views + HStack layout.
    private var progressBar: some View {
        Canvas { ctx, size in
            let filled = size.width * ratio
            // Background track
            ctx.fill(
                Path(roundedRect: CGRect(origin: .zero, size: size), cornerRadius: 2),
                with: .color(Color.surfaceSub)
            )
            // Filled portion (only draw if non-zero to skip GPU work)
            if filled > 0 {
                ctx.fill(
                    Path(roundedRect: CGRect(x: 0, y: 0, width: filled, height: size.height),
                         cornerRadius: 2),
                    with: .color(Color.accentPrimary.opacity(0.55))
                )
            }
        }
        .frame(height: 4)
    }

    private var rankColor: Color {
        switch item.rank {
        case 1: return .accentGold
        case 2: return Color(red: 0.72, green: 0.72, blue: 0.72)
        case 3: return Color(red: 0.78, green: 0.48, blue: 0.18)
        default: return Color.surfaceSub
        }
    }
}
