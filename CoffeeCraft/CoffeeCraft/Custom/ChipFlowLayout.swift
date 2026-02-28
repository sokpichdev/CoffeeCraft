//
//  ChipFlowLayout.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 2/28/26.
//
//  A wrapping layout that flows chips left-to-right, wrapping to
//  the next line when there is no more horizontal space.
//  Requires iOS 16+ (Layout protocol).
//
import SwiftUI

// MARK: - ChipFlowLayout
//
// SwiftUI's built-in stacks (HStack/VStack) can't wrap content to a new line.
// The `Layout` protocol (iOS 16+) lets us build custom layout logic.
//
// This layout works in two passes — the same way SwiftUI's engine works:
//   1. sizeThatFits  → "how tall/wide do you need to be?"
//   2. placeSubviews → "ok, now position every child"
//
// Both passes share the same `computeRows` helper so the math is consistent.

struct ChipFlowLayout: Layout {

    /// Gap between chips on the same row
    var horizontalSpacing: CGFloat = 8

    /// Gap between rows
    var verticalSpacing: CGFloat = 10

    // MARK: Pass 1 — Size

    /// SwiftUI calls this to ask: "given the available width, how much
    /// height do you need?". We compute all rows, sum their heights,
    /// and add vertical spacing between them.
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let rows = computeRows(proposal: proposal, subviews: subviews)

        // For each row, find the tallest chip → that is the row's height.
        // Then add all row heights together, plus spacing between rows.
        let height = rows
            .map { row in row.map { $0.size.height }.max() ?? 0 }  // tallest chip per row
            .reduce(0, +)                                            // total height of all rows
            + CGFloat(max(rows.count - 1, 0)) * verticalSpacing     // gaps between rows (not after last)

        // Width stays exactly what was proposed — we don't shrink or grow horizontally
        return CGSize(width: proposal.width ?? 0, height: height)
    }

    // MARK: Pass 2 — Placement

    /// SwiftUI calls this to say: "here is your rect, place every child in it."
    /// We walk the same rows and advance x/y cursors as we go.
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let rows = computeRows(proposal: proposal, subviews: subviews)

        var y = bounds.minY  // vertical cursor — starts at the top edge

        for row in rows {
            let rowHeight = row.map { $0.size.height }.max() ?? 0  // tallest chip in this row
            var x = bounds.minX  // horizontal cursor — resets to left edge for each row

            for item in row {
                // Place this chip at the current (x, y) position
                item.view.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(item.size))
                // Move the horizontal cursor right by chip width + spacing
                x += item.size.width + horizontalSpacing
            }

            // Move the vertical cursor down by row height + spacing, ready for the next row
            y += rowHeight + verticalSpacing
        }
    }

    // MARK: - Private Helpers

    /// Represents a single measured chip — its SwiftUI subview and its measured size.
    /// We measure once in `computeRows` and reuse the result in both passes.
    private struct Item {
        let view: LayoutSubview
        let size: CGSize
    }

    /// The core logic: measure every chip and pack them into rows.
    ///
    /// Algorithm:
    ///   - Walk chips left to right.
    ///   - If a chip fits on the current row, append it.
    ///   - If it doesn't fit (and the row isn't empty), start a new row.
    ///
    /// Returns an array of rows, where each row is an array of measured chips.
    private func computeRows(proposal: ProposedViewSize, subviews: Subviews) -> [[Item]] {
        let maxWidth = proposal.width ?? 0

        var rows: [[Item]] = []       // all finished rows
        var currentRow: [Item] = []   // chips being packed into the current row
        var currentWidth: CGFloat = 0 // running width of the current row

        for view in subviews {
            // Ask the chip how large it wants to be given the full available width
            let size = view.sizeThatFits(ProposedViewSize(width: maxWidth, height: nil))

            // Would adding this chip overflow the row?
            if currentWidth + size.width > maxWidth, !currentRow.isEmpty {
                // Yes — save the current row and start a fresh one
                rows.append(currentRow)
                currentRow = []
                currentWidth = 0
            }

            // Add chip to the current row and advance the width cursor
            currentRow.append(Item(view: view, size: size))
            currentWidth += size.width + horizontalSpacing
        }

        // Don't forget the last row (it never triggered the overflow condition)
        if !currentRow.isEmpty { rows.append(currentRow) }

        return rows
    }
}
