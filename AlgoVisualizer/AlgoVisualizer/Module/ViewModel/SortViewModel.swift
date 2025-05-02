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
    @Published var controlState: SortControlState = .idle
    @Published var speed: Double = 0.5
    @Published var currentAlgorithm: String = ""
    @Published var stepCount: Int = 0
    @Published var stepLogs: [String] = []
    @Published var pivotIndex: Int? = nil

    private var i = 0
    private var j = 0
    let itemCount = 30

    init() {
        reset()
    }

    func reset() {
        Task {
            controlState = .idle
            await MainActor.run {
                items = (1...itemCount).map { ArrayItem(value: $0) }.shuffled()
                stepLogs.removeAll()
                stepCount = 0
                currentAlgorithm = ""
                pivotIndex = nil
                i = 0
                j = 0
            }
        }
    }

    func pause() {
        if controlState == .running {
            controlState = .paused
        }
    }

    func step() {
        if controlState == .paused {
            controlState = .stepping
        }
    }

    func resume() {
        if controlState == .paused || controlState == .stepping {
            controlState = .running
        }
    }

    // MARK: - Bubble Sort
    func bubbleSort() async {
        currentAlgorithm = "Bubble Sort"
        stepCount = 0
        controlState = .running
        for i in 0..<items.count {
            self.i = i
            for j in 0..<items.count - i - 1 {
                self.j = j
                log("Comparing: \(items[j].value) and \(items[j + 1].value)") // Log comparison

                highlightComparison(i: j, j + 1)
                await waitForStepOrSleep()

                if items[j].value > items[j + 1].value {
                    items.swapAt(j, j + 1)
                    log("Swapping: \(items[j].value) and \(items[j + 1].value)") // Log swap
                    highlightSwap(i: j, j + 1)
                    await waitForStepOrSleep()
                }

                clearHighlights(i: j, j + 1)

                if controlState == .idle { return } // early exit on reset
            }
        }
        controlState = .idle
    }

    // MARK: - Insertion Sort
    func insertionSort() async {
        currentAlgorithm = "Insertion Sort"
        stepCount = 0
        controlState = .running
        for i in 1..<items.count {
            var j = i
            while j > 0 && items[j].value < items[j - 1].value {
                log("Comparing: \(items[j].value) and \(items[j - 1].value)") // Log comparison

                highlightComparison(i: j, j - 1)
                await waitForStepOrSleep()

                items.swapAt(j, j - 1)
                log("Swapping: \(items[j].value) and \(items[j - 1].value)") // Log swap
                highlightSwap(i: j, j - 1)
                await waitForStepOrSleep()

                clearHighlights(i: j, j - 1)
                j -= 1

                if controlState == .idle { return }
            }
        }
        controlState = .idle
    }

    // MARK: - Quick Sort
    func quickSort() async {
        currentAlgorithm = "Quick Sort"
        stepCount = 0
        controlState = .running
        await quickSortHelper(low: 0, high: items.count - 1)
        controlState = .idle
    }

    private func quickSortHelper(low: Int, high: Int) async {
        guard low < high else { return }

        let pi = await partition(low: low, high: high)

        pivotIndex = nil  // Clear the pivot marker here

        await quickSortHelper(low: low, high: pi - 1)
        await quickSortHelper(low: pi + 1, high: high)
    }

    private func partition(low: Int, high: Int) async -> Int {
        let pivotValue = items[high].value
        var i = low

        for j in low..<high {
            log("Comparing: \(items[j].value) and pivot \(pivotValue)") // Log comparison with pivot
            highlightComparison(i: j, high)
            await waitForStepOrSleep()

            if items[j].value < pivotValue {
                items.swapAt(i, j)
                log("Swapping: \(items[i].value) and \(items[j].value)") // Log swap
                highlightSwap(i: i, j)
                await waitForStepOrSleep()
                clearHighlights(i: i, j)
                i += 1
            } else {
                clearHighlights(i: j, high)
            }

            if controlState == .idle { return i }
        }

        items.swapAt(i, high)
        log("Swapping: \(items[i].value) and pivot \(pivotValue)") // Log final swap with pivot
        highlightSwap(i: i, high)
        await waitForStepOrSleep()
        clearHighlights(i: i, high)

        return i
    }

    // MARK: - Control Helpers

    private func waitForStepOrSleep() async {
        while true {
            switch controlState {
            case .running:
                stepCount += 1
                await sleepAnimation()
                return
            case .paused:
                try? await Task.sleep(nanoseconds: 100_000_000)
            case .stepping:
                stepCount += 1
                controlState = .paused
                return
            case .idle:
                return
            }
        }
    }

    private func sleepAnimation() async {
        let speedScale = 1.0 - speed
        let delay = UInt64((speedScale * 900_000_000) + 100_000_000)
        try? await Task.sleep(nanoseconds: delay)
    }

    // MARK: - Highlight Helpers

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

    // MARK: - Step Log

    private func log(_ message: String) {
        DispatchQueue.main.async {
            // Insert the new log at the top
            self.stepLogs.insert(message, at: 0)
        }
    }
}
