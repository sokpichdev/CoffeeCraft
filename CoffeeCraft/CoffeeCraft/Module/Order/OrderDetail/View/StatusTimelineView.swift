//
//  StatusTimelineView.swift
//  CoffeeCraft
//
//  Updated: branched timeline for pickup vs delivery orders.
//  Pickup:  Pending → InProgress → Ready → Completed
//  Delivery: Pending → InProgress → Ready → OnDelivery → Completed
//

import SwiftUI

struct StatusTimelineView: View {
    let status: String
    let isDeliveryOrder: Bool

    // MARK: - Step definitions

    private static let pickupSteps: [(code: String, icon: String, title: String)] = [
        ("Pending",    "clock",                  "Order Received"),
        ("InProgress", "flame.fill",             "Preparing"),
        ("Ready",      "checkmark.circle.fill",  "Ready for Pickup"),
        ("Completed",  "bag.fill",               "Completed"),
    ]

    private static let deliverySteps: [(code: String, icon: String, title: String)] = [
        ("Pending",    "clock",                  "Order Received"),
        ("InProgress", "flame.fill",             "Preparing"),
        ("Ready",      "checkmark.circle.fill",  "Ready"),
        ("OnDelivery", "bicycle",                "On Delivery"),
        ("Completed",  "bag.fill",               "Delivered"),
    ]

    private var steps: [(code: String, icon: String, title: String)] {
        isDeliveryOrder ? Self.deliverySteps : Self.pickupSteps
    }

    var currentStatusIndex: Int {
        steps.firstIndex { $0.code == status } ?? 0
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Order Progress")
                .font(.title3).fontWeight(.bold)
                .foregroundColor(.textPrimary)

            VStack(spacing: 0) {
                ForEach(Array(steps.enumerated()), id: \.offset) { index, step in
                    TimelineRow(
                        icon: step.icon,
                        title: step.title,
                        subtitle: subtitle(for: step.code, index: index),
                        isCompleted: index <= currentStatusIndex,
                        isCurrent: index == currentStatusIndex,
                        isLast: index == steps.count - 1
                    )
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

    // MARK: - Subtitles

    private func subtitle(for code: String, index: Int) -> String? {
        guard index == currentStatusIndex else { return nil }
        switch code {
        case "Pending":    return "Waiting to be prepared"
        case "InProgress": return "Barista is working on it"
        case "Ready":      return isDeliveryOrder ? "Handing off to rider" : "Come pick it up!"
        case "OnDelivery": return "Your order is on the way 🛵"
        case "Completed":  return isDeliveryOrder ? "Delivered — enjoy!" : "Enjoy your coffee!"
        default:           return nil
        }
    }
}

// MARK: - TimelineRow (unchanged)

struct TimelineRow: View {
    let icon: String
    let title: String
    let subtitle: String?
    let isCompleted: Bool
    let isCurrent: Bool
    let isLast: Bool

    private let indicatorSize: CGFloat = 42
    private let circleSize: CGFloat = 36
    private let lineWidth: CGFloat = 2
    private let lineHeight: CGFloat = 40

    var body: some View {
        HStack(alignment: .center, spacing: 16) {

            ZStack {
                if isCurrent {
                    ZStack {
                        Circle()
                            .fill(isCompleted ? Color.semanticSuccess : Color.textMuted.opacity(0.2))
                            .frame(width: indicatorSize, height: indicatorSize)

                        Circle()
                            .fill(Color.bgSecondary)
                            .frame(width: indicatorSize - 3, height: indicatorSize - 3)

                        Circle()
                            .fill(isCompleted ? Color.semanticSuccess : Color.textMuted.opacity(0.2))
                            .frame(width: indicatorSize - 6, height: indicatorSize - 6)
                    }
                } else {
                    Circle()
                        .fill(isCompleted ? Color.semanticSuccess : Color.bgSecondary)
                        .frame(width: circleSize, height: circleSize)
                }

                Image(systemName: isCompleted && !isCurrent ? "checkmark" : icon)
                    .font(.system(size: 14, weight: isCompleted ? .bold : .regular))
                    .foregroundColor(isCompleted ? .textPrimary : .textMuted).colorScheme(.dark)
            }
            .frame(width: circleSize, height: circleSize)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: isCurrent ? .semibold : .regular))
                    .foregroundColor(isCompleted ? .textPrimary : .textMuted)

                if let subtitle {
                    Text(subtitle)
                        .font(.footnote).bold()
                        .foregroundColor(.semanticSuccess)
                        .transition(.opacity)
                }
            }

            Spacer()
        }
        .padding(.bottom, isLast ? 0 : lineHeight)
        .background(alignment: .bottomLeading) {
            if !isLast {
                Rectangle()
                    .fill(isCompleted ? Color.semanticSuccess.opacity(0.3) : Color.bgSecondary)
                    .frame(width: lineWidth, height: lineHeight)
                    .padding(.leading, (circleSize - lineWidth) / 2)
            }
        }
    }
}
