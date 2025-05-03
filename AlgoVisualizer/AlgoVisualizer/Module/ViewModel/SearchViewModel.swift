//
//  SearchViewModel.swift
//  AlgoVisualizer
//
//  Created by Sok Pich on 5/3/25.
//

import SwiftUI

@MainActor
class SearchViewModel: ObservableObject {

    @Published var items: [ArrayItem] = []
    @Published var searchTarget: Int = 0
    @Published var currentIndex: Int?
    @Published var isFound: Bool? = nil
    @Published var stepLogs: [String] = []
    @Published var speed: Double = 0.5

    init() {
        reset()
    }

    func reset() {
        items = (1...20).map { ArrayItem(value: $0) }.shuffled()
        searchTarget = items.randomElement()?.value ?? 0
        currentIndex = nil
        isFound = nil
        stepLogs = []
    }

    func linearSearch() async {
        reset()
        stepLogs.append("Searching for \(searchTarget) using Linear Search...")

        for (index, item) in items.enumerated() {
            await updateUIForCurrentIndex(index: index, item: item)
            
            stepLogs.append("Checking index \(index): \(item.value)")

            try? await Task.sleep(nanoseconds: UInt64((1.0 - speed) * 500_000_000))

            if item.value == searchTarget {
                await onTargetFound(index: index)
                return
            }
        }
        await onTargetNotFound()
    }

    private func updateUIForCurrentIndex(index: Int, item: ArrayItem) async {
        await MainActor.run {
            currentIndex = index
            items = items.enumerated().map { i, it in
                var copy = it
                copy.color = (i == index) ? .orange : .blue
                return copy
            }
        }
    }

    private func onTargetFound(index: Int) async {
        await MainActor.run {
            isFound = true
            items[index].color = .green
        }
        stepLogs.append("✅ Found at index \(index)!")
    }

    private func onTargetNotFound() async {
        await MainActor.run {
            isFound = false
        }
        stepLogs.append("❌ Not found in the array.")
    }
}
