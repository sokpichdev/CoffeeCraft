//
//  StatusTimelineView.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 2/24/26.
//
import SwiftUI

struct StatusTimelineView: View {
    let status: String
    
    private let statuses = [
        ("Pending", "clock", "Order Received"),
        ("InProgress", "flame", "Preparing"),
        ("Ready", "cup.and.saucer.fill", "Ready for Pickup"),
        ("Completed", "checkmark.circle.fill", "Completed")
    ]
    
    var currentStatusIndex: Int {
        statuses.firstIndex { $0.0 == status } ?? 0
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Order Progress")
                .font(.title3).fontWeight(.bold)
                .foregroundColor(.primary)
            
            VStack(spacing: 0) {
                ForEach(Array(statuses.enumerated()), id: \.offset) { index, item in
                    TimelineRow(
                        icon: item.1,
                        title: item.2,
                        subtitle: statusSubtitle(for: item.0, index: index),
                        isCompleted: index <= currentStatusIndex,
                        isCurrent: index == currentStatusIndex,
                        isLast: index == statuses.count - 1
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
    
    func statusSubtitle(for statusCode: String, index: Int) -> String? {
        guard index == currentStatusIndex else { return nil }
        switch statusCode {
        case "Pending": return "Waiting to be prepared"
        case "InProgress": return "Barista is working on it"
        case "Ready": return "Come pick it up!"
        case "Completed": return "Enjoy your coffee!"
        default: return nil
        }
    }
}

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
                            .fill(isCompleted ? Color.coffeeOliveGreen : Color.gray.opacity(0.2))
                            .frame(width: indicatorSize, height: indicatorSize)

                        Circle()
                            .fill(Color(.secondarySystemGroupedBackground))
                            .frame(width: indicatorSize - 3, height: indicatorSize - 3)
                        
                        Circle()
                            .fill(isCompleted ? Color.coffeeOliveGreen : Color.gray.opacity(0.2))
                            .frame(width: indicatorSize - 6, height: indicatorSize - 6)
                    }
                } else {
                    Circle()
                        .fill(isCompleted ? Color.coffeeOliveGreen : Color.gray.opacity(0.2))
                        .frame(width: circleSize, height: circleSize)
                }

                Image(systemName: isCompleted && !isCurrent ? "checkmark" : icon)
                    .font(.system(size: 14, weight: isCompleted ? .bold : .regular))
                    .foregroundColor(isCompleted ? .white : .gray)
            }
            .frame(width: circleSize, height: circleSize)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: isCurrent ? .semibold : .regular))
                    .foregroundColor(isCompleted ? .primary : .secondary)

                if let subtitle {
                    Text(subtitle)
                        .font(.footnote).bold()
                        .foregroundColor(.coffeeOliveGreen)
                        .transition(.opacity)
                }
            }

            Spacer()
        }
        .padding(.bottom, isLast ? 0 : lineHeight)
        .background(alignment: .bottomLeading) {
            if !isLast {
                Rectangle()
                    .fill(isCompleted ? Color.coffeeOliveGreen.opacity(0.3) : Color.gray.opacity(0.2))
                    .frame(width: lineWidth, height: lineHeight)
                    .padding(.leading, (circleSize - lineWidth) / 2)
            }
        }
    }
}
