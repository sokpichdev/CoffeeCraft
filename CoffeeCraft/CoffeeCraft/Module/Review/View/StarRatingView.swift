//
//  StarRatingView.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 3/10/26.
//

import SwiftUI

// MARK: - StarRatingMode

enum StarRatingMode {
    /// Interactive star picker — drives a @Binding<Int> (1–5).
    case interactive(rating: Binding<Int>)

    /// Read-only display of a Double average — supports partial (half) star fill.
    case readOnly(average: Double)
}

// MARK: - StarRatingView

struct StarRatingView: View {

    // MARK: Config

    let mode: StarRatingMode
    var starCount: Int = 5
    var size: CGFloat = 20
    /// When true, appends a text label: "4.3  (42)" next to the stars.
    var showLabel: Bool = false
    /// Number of ratings — shown in the label when showLabel is true.
    var count: Int = 0
    /// Color of filled stars. Defaults to accentGold.
    var filledColor: Color = .accentGold
    /// Color of empty stars.
    var emptyColor: Color = .textMuted

    // MARK: Body

    var body: some View {
        switch mode {
        case .interactive(let rating):
            interactiveStars(rating: rating)
        case .readOnly(let average):
            readOnlyStars(average: average)
        }
    }
}

// MARK: - Interactive Mode

private extension StarRatingView {

    func interactiveStars(rating: Binding<Int>) -> some View {
        HStack(spacing: size * 0.18) {
            ForEach(1...starCount, id: \.self) { index in
                starShape(filled: index <= rating.wrappedValue)
                    .frame(width: size, height: size)
                    .scaleEffect(index == rating.wrappedValue ? 1.15 : 1.0)
                    .animation(.spring(response: 0.25, dampingFraction: 0.55), value: rating.wrappedValue)
                    .onTapGesture {
                        let haptic = UIImpactFeedbackGenerator(style: .light)
                        haptic.impactOccurred()
                        rating.wrappedValue = index
                    }
            }
        }
        // Drag gesture — lets the user slide across stars smoothly
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { value in
                    // Each star occupies (size + spacing) points.
                    let spacing = size * 0.18
                    let starWidth = size + spacing
                    let rawIndex = Int(value.location.x / starWidth) + 1
                    let clamped = max(1, min(starCount, rawIndex))
                    if clamped != rating.wrappedValue {
                        let haptic = UIImpactFeedbackGenerator(style: .light)
                        haptic.impactOccurred()
                        rating.wrappedValue = clamped
                    }
                }
        )
    }
}

// MARK: - Read-Only Mode

private extension StarRatingView {

    func readOnlyStars(average: Double) -> some View {
        HStack(spacing: size * 0.12) {
            ForEach(1...starCount, id: \.self) { index in
                starLayer(index: index, average: average)
                    .frame(width: size, height: size)
            }

            if showLabel {
                ratingLabel(average: average)
            }
        }
    }

    /// Renders one star position using a clipped overlay for partial fill.
    /// Supports full (1.0), half (0.5), and empty (0.0) fill states.
    @ViewBuilder
    func starLayer(index: Int, average: Double) -> some View {
        let fill = fillFraction(for: index, average: average)

        ZStack {
            // Empty star (base layer — always visible)
            starShape(filled: false)

            // Filled overlay clipped to the fill fraction
            if fill > 0 {
                starShape(filled: true)
                    .clipShape(
                        Rectangle()
                            .size(width: size * fill, height: size)
                            .offset(x: 0, y: 0)
                    )
            }
        }
    }

    /// Returns the fill fraction (0.0 – 1.0) for a star at `index` given an `average`.
    /// Example: average = 3.7, index 4 → 0.7 (partial fill)
    func fillFraction(for index: Int, average: Double) -> Double {
        let diff = average - Double(index - 1)
        return max(0.0, min(1.0, diff))
    }

    func ratingLabel(average: Double) -> some View {
        HStack(spacing: 4) {
            Text(average > 0 ? String(format: "%.1f", average) : "–")
                .font(.system(size: size * 0.85, weight: .semibold))
                .foregroundColor(.textPrimary)

            if count > 0 {
                Text("(\(count.formatted()))")
                    .font(.system(size: size * 0.75))
                    .foregroundColor(.textSecondary)
            }
        }
    }
}

// MARK: - Shared Star Shape

private extension StarRatingView {

    /// Renders either a filled or outlined star SF Symbol at the component's size.
    func starShape(filled: Bool) -> some View {
        Image(systemName: filled ? "star.fill" : "star")
            .resizable()
            .scaledToFit()
            .foregroundColor(filled ? filledColor : emptyColor)
    }
}

// MARK: - Convenience Initialisers

extension StarRatingView {

    /// Compact read-only badge — just stars, no label.
    /// e.g. StarRatingView.badge(average: 4.3, size: 12)
    static func badge(average: Double, size: CGFloat = 12) -> StarRatingView {
        StarRatingView(mode: .readOnly(average: average), size: size)
    }

    /// Full summary line: stars + "4.3  (42 reviews)".
    /// e.g. StarRatingView.summary(average: 4.3, count: 42, size: 16)
    static func summary(average: Double, count: Int, size: CGFloat = 16) -> StarRatingView {
        StarRatingView(
            mode: .readOnly(average: average),
            size: size,
            showLabel: true,
            count: count
        )
    }
}

// MARK: - Preview

#Preview("Interactive") {
    struct PreviewWrapper: View {
        @State var score = 3
        var body: some View {
            VStack(spacing: 24) {
                Text("Tap or drag to rate")
                    .font(.subheadline)
                    .foregroundColor(.textSecondary)

                StarRatingView(mode: .interactive(rating: $score), size: 40)

                Text("Selected: \(score) star\(score == 1 ? "" : "s")")
                    .font(.headline)
                    .foregroundColor(.accentPrimary)
            }
            .padding(32)
        }
    }
    return PreviewWrapper()
}

#Preview("Read-Only sizes") {
    VStack(alignment: .leading, spacing: 20) {
        ForEach([4.0, 3.7, 2.5, 1.0, 0.0], id: \.self) { avg in
            HStack(spacing: 16) {
                StarRatingView.badge(average: avg, size: 12)
                StarRatingView.summary(average: avg, count: 128, size: 16)
            }
        }
    }
    .padding(24)
}
