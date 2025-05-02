//
//  SortViewModel.swift
//  AlgoVisualizer
//
//  Created by Sok Pich on 5/2/25.
//

import Foundation
import SwiftUI

@MainActor
class SortViewModel: ObservableObject {
    @Published var items: [ArrayItem] = []
    @Published var isSorting = false
    @Published var isPaused = false
    @Published var speed: Double = 0.5
    @Published var stepMode = false
    @Published var waitingForStep = false

    private var i = 0
    private var j = 0
    let itemCount = 30

    init() {
        reset()
    }

    func reset() {
        items = (1...itemCount).map { ArrayItem(value: $0) }.shuffled()
        isSorting = false
        isPaused = false
        stepMode = false
        waitingForStep = false
        i = 0
        j = 0
    }

    func togglePause() {
        isPaused.toggle()
    }

    func toggleStepMode() {
        stepMode.toggle()
        isPaused = false
        waitingForStep = false
    }

    func step() {
        waitingForStep = false
    }

    // MARK: - Bubble Sort
    func bubbleSort() async {
        isSorting = true
        for i in 0..<items.count {
            self.i = i
            for j in 0..<items.count - i - 1 {
                self.j = j

                highlightComparison(i: j, j + 1)
                await waitForStepOrSleep()

                if items[j].value > items[j + 1].value {
                    items.swapAt(j, j + 1)
                    highlightSwap(i: j, j + 1)
                    await waitForStepOrSleep()
                }

                clearHighlights(i: j, j + 1)
            }
        }
        isSorting = false
    }

    private func waitForStepOrSleep() async {
        if stepMode {
            waitingForStep = true
            while waitingForStep { try? await Task.sleep(nanoseconds: 100_000_000) }
        } else {
            await waitIfPaused()
            await sleepAnimation()
        }
    }

    private func sleepAnimation() async {
        let speedScale = 1.0 - speed
        let delay = UInt64((speedScale * 900_000_000) + 100_000_000)
        try? await Task.sleep(nanoseconds: delay)
    }

    private func waitIfPaused() async {
        while isPaused {
            try? await Task.sleep(nanoseconds: 100_000_000)
        }
    }

    private func highlightComparison(i: Int, _ j: Int) {
        items[i].color = .red
        items[j].color = .red
    }

    private func highlightSwap(i: Int, _ j: Int) {
        items[i].color = .green
        items[j].color = .green
    }

    private func clearHighlights(i: Int, _ j: Int) {
        items[i].color = .blue
        items[j].color = .blue
    }
    // MARK: - Insertion Sort
    func insertionSort() async {
        isSorting = true
        for i in 1..<items.count {
            var j = i
            while j > 0 && items[j].value < items[j - 1].value {
                highlightComparison(i: j, j - 1)
                await waitForStepOrSleep()

                items.swapAt(j, j - 1)
                highlightSwap(i: j, j - 1)
                await waitForStepOrSleep()

                clearHighlights(i: j, j - 1)
                j -= 1
            }
        }
        isSorting = false
    }

    // MARK: - Quick Sort
    func quickSort() async {
        isSorting = true
        await quickSortHelper(low: 0, high: items.count - 1)
        isSorting = false
    }

    private func quickSortHelper(low: Int, high: Int) async {
        if low < high {
            let pivotIndex = await partition(low: low, high: high)
            await quickSortHelper(low: low, high: pivotIndex - 1)
            await quickSortHelper(low: pivotIndex + 1, high: high)
        }
    }

    private func partition(low: Int, high: Int) async -> Int {
        let pivotValue = items[high].value
        var i = low

        for j in low..<high {
            highlightComparison(i: j, high)
            await waitForStepOrSleep()

            if items[j].value < pivotValue {
                items.swapAt(i, j)
                highlightSwap(i: i, j)
                await waitForStepOrSleep()
                clearHighlights(i: i, j)
                i += 1
            } else {
                clearHighlights(i: j, high)
            }
        }

        items.swapAt(i, high)
        highlightSwap(i: i, high)
        await waitForStepOrSleep()
        clearHighlights(i: i, high)

        return i
    }

}
