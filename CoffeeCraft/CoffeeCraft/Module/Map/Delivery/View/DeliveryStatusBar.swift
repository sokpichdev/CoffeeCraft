//
//  DeliveryStatusBar.swift
//  CoffeeCraft
//
//  Map Module — Phase 4 (Delivery)
//
//  Animated step-progress strip rendered below the live map.
//  Shows all 6 DeliveryStatus steps as dots connected by a fill line.
//  Each dot fills left-to-right as status advances.
//

import SwiftUI

// MARK: - DeliveryStatusBar

struct DeliveryStatusBar: View {

    let status: DeliveryStatus
    let orderId: String
    let estimatedArrival: Date?

    var body: some View {
        VStack(spacing: 0) {
            // ── Status label + ETA ──────────────────────────────────
            HStack(alignment: .firstTextBaseline) {
                HStack(spacing: 7) {
                    Image(systemName: status.icon)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(Color.accentPrimary)
                        .symbolEffect(.bounce, value: status)

                    Text(status.label)
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(Color.textPrimary)
                }
                .animation(.spring(response: 0.35), value: status)

                Spacer()

                VStack(alignment: .trailing, spacing: 1) {
                    if let eta = estimatedArrival, status != .delivered {
                        Text(etaLabel(eta))
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                            .foregroundColor(Color.accentPrimary)
                            .contentTransition(.numericText())
                    }
                    Text("Order \(orderId)")
                        .font(.system(size: 11, weight: .regular))
                        .foregroundColor(Color.textMuted)
                }
            }
            .padding(.horizontal, 18)
            .padding(.top, 16)
            .padding(.bottom, 10)

            // ── Progress dots + line ────────────────────────────────
            progressTrack
                .padding(.horizontal, 18)
                .padding(.bottom, 16)
        }
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.surfacePrimary)
                .shadow(color: .black.opacity(0.10), radius: 14, x: 0, y: -4)
        )
    }

    // MARK: - Progress Track

    private var progressTrack: some View {
        let steps  = DeliveryStatus.allCases
        let doneIndex = status.stepIndex

        return GeometryReader { geo in
            let dotSize:  CGFloat = 10
            let spacing = (geo.size.width - dotSize * CGFloat(steps.count))
                          / CGFloat(steps.count - 1)

            ZStack(alignment: .leading) {
                // Background line
                Capsule()
                    .fill(Color.borderColor)
                    .frame(height: 3)
                    .padding(.horizontal, dotSize / 2)

                // Filled progress line
                Capsule()
                    .fill(Color.accentPrimary)
                    .frame(
                        width: progressLineWidth(geo: geo,
                                                 dotSize: dotSize,
                                                 spacing: spacing,
                                                 doneIndex: doneIndex),
                        height: 3
                    )
                    .padding(.leading, dotSize / 2)
                    .animation(.spring(response: 0.55, dampingFraction: 0.72), value: doneIndex)

                // Dots
                HStack(spacing: spacing) {
                    ForEach(Array(steps.enumerated()), id: \.offset) { idx, step in
                        StepDot(
                            icon:   step.icon,
                            filled: idx <= doneIndex,
                            size:   dotSize
                        )
                    }
                }
            }
        }
        .frame(height: 22)
    }

    private func progressLineWidth(geo: GeometryProxy,
                                   dotSize: CGFloat,
                                   spacing: CGFloat,
                                   doneIndex: Int) -> CGFloat {
        guard doneIndex > 0 else { return 0 }
        let steps     = DeliveryStatus.allCases.count
        let maxIndex  = steps - 1
        let clampedIdx = min(doneIndex, maxIndex)
        let totalWidth = geo.size.width - dotSize
        return totalWidth * CGFloat(clampedIdx) / CGFloat(maxIndex)
    }

    // MARK: - ETA Formatting

    private func etaLabel(_ date: Date) -> String {
        let secs = date.timeIntervalSinceNow
        guard secs > 0 else { return "Arriving now" }
        let mins = Int(ceil(secs / 60))
        return mins == 1 ? "~1 min" : "~\(mins) min"
    }
}

// MARK: - StepDot

private struct StepDot: View {

    let icon:   String
    let filled: Bool
    let size:   CGFloat

    var body: some View {
        ZStack {
            Circle()
                .fill(filled ? Color.accentPrimary : Color.surfaceSub)
                .frame(width: size, height: size)
                .overlay {
                    if !filled {
                        Circle().strokeBorder(Color.borderColor, lineWidth: 1)
                    }
                }
                .shadow(
                    color: filled ? Color.accentPrimary.opacity(0.4) : .clear,
                    radius: 4, x: 0, y: 2
                )
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.65), value: filled)
    }
}
