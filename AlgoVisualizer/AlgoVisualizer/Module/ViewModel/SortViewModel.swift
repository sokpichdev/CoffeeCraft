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
}
