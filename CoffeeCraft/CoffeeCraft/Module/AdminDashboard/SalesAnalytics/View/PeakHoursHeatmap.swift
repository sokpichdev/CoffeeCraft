//
//  PeakHoursHeatmap.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 3/14/26.
//
import SwiftUI

struct PeakHoursHeatmap: View {

    let matrix: [[Int]]
    let maxCount: Int

    private let hours = stride(from: 6, through: 22, by: 2).map { $0 }
    private let weekdays = ["S", "M", "T", "W", "T", "F", "S"]

    private let rowHeight: CGFloat = 24
    private let labelWidth: CGFloat = 28
    private let cellSpacing: CGFloat = 2

    // Shared cell width calculation - ensures labels align with columns
    private var cellWidth: CGFloat { rowHeight * 1.5 }

    var body: some View {
        VStack(spacing: 8) {

            // MARK: - Hour Labels (Top)
            HStack(spacing: cellSpacing) {
                Spacer()
                    .frame(width: labelWidth)

                ForEach(hours, id: \.self) { hour in
                    Text(hourLabel(hour))
                        .font(.system(size: 9, weight: .medium))
                        .foregroundStyle(Color.textMuted)
                        .frame(width: cellWidth)
                }
            }

            // MARK: - Heatmap Grid
            HStack(spacing: 6) {

                // Weekday labels
                VStack(spacing: cellSpacing) {
                    ForEach(weekdays.indices, id: \.self) { i in
                        Text(weekdays[i])
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundStyle(Color.textMuted)
                            .frame(width: labelWidth, height: rowHeight, alignment: .trailing)
                    }
                }

                // Canvas - uses exact same dimensions as labels above
                PeakHoursCanvas(
                    matrix: matrix,
                    maxCount: maxCount,
                    cellWidth: cellWidth,
                    cellHeight: rowHeight,
                    cellSpacing: cellSpacing
                )
            }

            legend
        }
    }

    private var legend: some View {
        HStack(spacing: 6) {
            Text("Low")
                .font(.caption2)
                .foregroundStyle(Color.textMuted)

            LinearGradient(
                colors: [Color.accentPrimary.opacity(0.15), Color.accentPrimary],
                startPoint: .leading,
                endPoint: .trailing
            )
            .frame(width: 60, height: 8)
            .clipShape(Capsule())

            Text("High")
                .font(.caption2)
                .foregroundStyle(Color.textMuted)
        }
        .frame(maxWidth: .infinity, alignment: .trailing)
    }

    private func hourLabel(_ hour: Int) -> String {
        switch hour {
        case 12: return "12p"
        case let hr where hr < 12: return "\(hr)a"
        default: return "\(hour - 12)p"
        }
    }
}

// MARK: - Canvas Core
struct PeakHoursCanvas: View {

    let matrix: [[Int]]
    let maxCount: Int
    let cellWidth: CGFloat
    let cellHeight: CGFloat
    let cellSpacing: CGFloat

    var body: some View {
        let cols = CGFloat(matrix.first?.count ?? 0)
        let rows = CGFloat(matrix.count)

        let totalWidth = (cellWidth * cols) + (cellSpacing * (cols - 1))
        let totalHeight = (cellHeight * rows) + (cellSpacing * (rows - 1))

        Canvas { context, _ in
            let rows = matrix.count
            let cols = matrix.first?.count ?? 0
            guard rows > 0 && cols > 0 else { return }

            // Pre-calculate color values for efficiency
            let colorCache: [Color] = (0...maxCount).map { count in
                cellColor(for: count)
            }

            for row in 0..<rows {
                for col in 0..<cols {
                    let count = matrix[row][col]

                    let x = CGFloat(col) * (cellWidth + cellSpacing)
                    let y = CGFloat(row) * (cellHeight + cellSpacing)

                    let rect = CGRect(
                        x: x,
                        y: y,
                        width: cellWidth,
                        height: cellHeight
                    )

                    // Draw cell background
                    context.fill(
                        Path(roundedRect: rect, cornerRadius: 4),
                        with: .color(colorCache[min(count, maxCount)])
                    )

                    // Draw count text (only if > 0)
                    if count > 0 {
                        let text = Text("\(count)")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundColor(count > maxCount / 2 ? .white : Color.textPrimary)

                        context.draw(
                            text,
                            at: CGPoint(x: rect.midX, y: rect.midY),
                            anchor: .center
                        )
                    }
                }
            }
        }
        .frame(width: totalWidth, height: totalHeight)
    }

    private func cellColor(for count: Int) -> Color {
        guard maxCount > 0 else { return Color.accentPrimary.opacity(0.05) }

        let normalized = Double(count) / Double(maxCount)
        let boosted = pow(normalized, 0.5)

        return Color.accentPrimary.opacity(max(0.05, boosted))
    }
}
