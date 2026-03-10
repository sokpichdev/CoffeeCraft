//
//  OrderItemsCard.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 2/24/26.
//
import SwiftUI

struct OrderItemsCard: View {
    let items: [CartItemData]

    var orderStatus: String?
    var ratedProductIds: Set<String> = [] // productIds already rated by this user
    var onRateItem: ((CartItemData) -> Void)? // triggers RatingInputSheet

    private var isCompleted: Bool {
        let s = orderStatus?.lowercased() ?? ""
        return s == "completed" || s == "done"
    }

    var body: some View {
        let totalQty = items.reduce(0) { $0 + ($1.quantity ?? 1) }

        VStack(alignment: .leading, spacing: 16) {

            HStack {
                Text("Items")
                    .font(.title3).fontWeight(.bold)
                    .foregroundColor(.textPrimary)

                Spacer()

                Text("\(totalQty) item\(items.count == 1 ? "" : "s")")
                    .font(.subheadline).fontWeight(.medium)
                    .foregroundColor(.textSecondary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.secondary.opacity(0.1))
                    .cornerRadius(12)
            }

            VStack(spacing: 16) {
                ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                    VStack(alignment: .leading, spacing: 10) {

                        // Original row — unchanged
                        OrderItemRow(item: item, isLast: index == items.count - 1)

                        // rating prompt, Completed orders only
                        if isCompleted, let productId = item.productId {
                            ItemRatingPrompt(
                                item: item,
                                isRated: ratedProductIds.contains(productId),
                                onTapRate: { onRateItem?(item) }
                            )
                            .padding(.leading, 72) // aligns under item name (past thumbnail)
                        }
                    }
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color(.secondarySystemGroupedBackground))
                .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 4)
        )
    }
}

struct OrderItemRow: View {
    let item: CartItemData
    let isLast: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                AsyncImageCard(imageURL: item.imageURL, height: 56, width: 56, corner: 12)
                
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 4) {
                        if let qty = item.quantity, qty > 1 {
                            Text("×\(qty)")
                                .font(.body).fontWeight(.semibold)
                                .foregroundColor(.accentPrimary)
                        }
                        Text(item.name ?? "")
                            .font(.body).fontWeight(.semibold)
                            .foregroundColor(.textPrimary)
                    }
                    
                    // Selections
                    if let selections = item.selections, !selections.isEmpty {
                        VStack(alignment: .leading, spacing: 4) {
                            ForEach(selections.sorted(by: { $0.key < $1.key }), id: \.key) { key, value in
                                HStack(spacing: 4) {
                                    Text("•")
                                        .foregroundColor(.textSecondary)
                                    Text(key)
                                        .font(.system(size: 13))
                                        .foregroundColor(.textSecondary)
                                    Text("·")
                                        .foregroundColor(.secondary.opacity(0.5))
                                    Text(value)
                                        .font(.system(size: 13, weight: .medium))
                                        .foregroundColor(.textPrimary.opacity(0.8))
                                }
                            }
                        }
                    }
                    
                    // Extras
                    if let extras = item.extras, !extras.isEmpty {
                        HStack(alignment: .top, spacing: 4) {
                            Text("• Extras:")
                                .font(.footnote)
                                .foregroundColor(.textSecondary)
                            Text(extras.joined(separator: ", "))
                                .font(.footnote).fontWeight(.medium)
                                .foregroundColor(.textPrimary.opacity(0.8))
                        }
                    }
                }
                
                Spacer()
                
                Text("$\(item.price ?? 0.0, specifier: "%.2f")")
                    .font(.body).fontWeight(.bold)
                    .foregroundColor(.textPrimary)
            }
            
            if !isLast {
                Divider()
                    .background(Color.secondary.opacity(0.15))
                    .padding(.leading, 72)
            }
        }
    }
}

/// The prompt deliberately uses a small footprint so it doesn't crowd the
/// existing item layout — 5 small stars + a one-line label.
private struct ItemRatingPrompt: View {
    let item: CartItemData
    let isRated: Bool
    let onTapRate: () -> Void

    // Local hover state for press animation
    @State private var isPressed = false

    var body: some View {
        if isRated {
            ratedState
        } else {
            unratedState
        }
    }

    private var unratedState: some View {
        Button(action: onTapRate) {
            HStack(spacing: 8) {
                // 5 empty stars — communicates interactivity
                StarRatingView(
                    mode: .readOnly(average: 0),
                    size: 16,
                    emptyColor: Color.accentGold.opacity(0.4)
                )

                Text("Rate this item")
                    .font(.caption.weight(.medium))
                    .foregroundColor(.accentPrimary)

                Image(systemName: "chevron.right")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(.accentPrimary.opacity(0.6))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 7)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.accentPrimary.opacity(isPressed ? 0.12 : 0.07))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .strokeBorder(Color.accentPrimary.opacity(0.2), lineWidth: 1)
                    )
            )
            .scaleEffect(isPressed ? 0.97 : 1.0)
            .animation(.spring(response: 0.2, dampingFraction: 0.6), value: isPressed)
        }
        .buttonStyle(.plain)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
    }

    private var ratedState: some View {
        HStack(spacing: 6) {
            // Read-only filled stars at the user's actual score.
            // We show 5 filled stars here as a "rated" indicator — the
            // exact score is visible on the product detail review card.
            StarRatingView(
                mode: .readOnly(average: 5),
                size: 14
            )

            Text("Rated")
                .font(.caption.weight(.medium))
                .foregroundColor(.textMuted)

            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 12))
                .foregroundColor(.accentGold)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 7)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.accentGold.opacity(0.07))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .strokeBorder(Color.accentGold.opacity(0.2), lineWidth: 1)
                )
        )
    }
}
