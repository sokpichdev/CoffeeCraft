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
    @Published var midIndex: Int? = nil
    
    private var i = 0
    private var j = 0
    let itemCount = 20
    
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
                midIndex = nil
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
    
    // MARK: - Merge Sort
    func mergeSort() async {
        currentAlgorithm = "Merge Sort"
        stepCount = 0
        controlState = .running
        await mergeSortHelper(start: 0, end: items.count - 1)
        controlState = .idle
    }
    
    private func mergeSortHelper(start: Int, end: Int) async {
        if start >= end { return }
        
        let mid = (start + end) / 2
        await MainActor.run {
            midIndex = mid
            highlightMidpoint(mid)
        }
        
        await mergeSortHelper(start: start, end: mid)
        await mergeSortHelper(start: mid + 1, end: end)
        await merge(start: start, mid: mid, end: end)
        
        await MainActor.run {
            midIndex = nil
            if mid < items.count {
                items[mid].color = .blue
            }
        }
    }
    
    private func merge(start: Int, mid: Int, end: Int) async {
        var temp: [ArrayItem] = []
        var i = start
        var j = mid + 1
        
        while i <= mid && j <= end {
            highlightComparison(i: i, j)
            log("Comparing: \(items[i].value) and \(items[j].value)")
            await waitForStepOrSleep()
            
            let a = i
            let b = j
            
            if items[i].value <= items[j].value {
                temp.append(items[i])
                i += 1
            } else {
                temp.append(items[j])
                j += 1
            }
            clearHighlights(i: a, b)
            
            if controlState == .idle { return }
        }
        
        while i <= mid {
            temp.append(items[i])
            i += 1
            if controlState == .idle { return }
        }
        
        while j <= end {
            temp.append(items[j])
            j += 1
            if controlState == .idle { return }
        }
        
        for idx in 0..<temp.count {
            items[start + idx] = temp[idx]
            highlightSwap(i: start + idx, start + idx)
            log("Placing: \(temp[idx].value) at position \(start + idx)")
            await waitForStepOrSleep()
            clearHighlights(i: start + idx, start + idx)
        }
    }
    
    private func highlightMidpoint(_ mid: Int) {
        if mid < items.count {
            items[mid].color = .purple
        }
    }
    
    //MARK: - Heap Sort
    func heapSort() async {
        currentAlgorithm = "Heap Sort"
        stepCount = 0
        controlState = .running
        let n = items.count
        
        // Build max heap
        for i in stride(from: n / 2 - 1, through: 0, by: -1) {
            await heapify(n, i)
            if controlState == .idle { return }
        }
        
        // One by one extract elements from heap
        for i in stride(from: n - 1, through: 1, by: -1) {
            log("Swapping: \(items[0].value) and \(items[i].value)")
            highlightSwap(i: 0, i)
            items.swapAt(0, i)
            await waitForStepOrSleep()
            clearHighlights(i: 0, i)
            
            await heapify(i, 0)
            if controlState == .idle { return }
        }
        
        controlState = .idle
    }
    
    private func heapify(_ n: Int, _ i: Int) async {
        var largest = i
        let left = 2 * i + 1
        let right = 2 * i + 2
        
        if left < n {
            highlightComparison(i: i, left)
            log("Comparing: \(items[i].value) and \(items[left].value)")
            await waitForStepOrSleep()
            clearHighlights(i: i, left)
            
            if items[left].value > items[largest].value {
                largest = left
            }
        }
        
        if right < n {
            highlightComparison(i: largest, right)
            log("Comparing: \(items[largest].value) and \(items[right].value)")
            await waitForStepOrSleep()
            clearHighlights(i: largest, right)
            
            if items[right].value > items[largest].value {
                largest = right
            }
        }
        
        if largest != i {
            log("Swapping: \(items[i].value) and \(items[largest].value)")
            highlightSwap(i: i, largest)
            items.swapAt(i, largest)
            await waitForStepOrSleep()
            clearHighlights(i: i, largest)
            
            await heapify(n, largest)
        }
    }
    
    // MARK: - Selection Sort
    func selectionSort() async {
        currentAlgorithm = "Selection Sort"
        stepCount = 0
        controlState = .running
        for i in 0..<items.count - 1 {
            var minIndex = i
            for j in i + 1..<items.count {
                log("Comparing: \(items[j].value) and \(items[minIndex].value)") // Log comparison
                
                highlightComparison(i: j, minIndex)
                await waitForStepOrSleep()
                
                if items[j].value < items[minIndex].value {
                    minIndex = j
                }
                clearHighlights(i: j, minIndex)
                
                if controlState == .idle { return }
            }
            
            // Swap the minimum element with the current element
            if minIndex != i {
                log("Swapping: \(items[i].value) and \(items[minIndex].value)") // Log swap
                items.swapAt(i, minIndex)
                highlightSwap(i: i, minIndex)
                await waitForStepOrSleep()
                clearHighlights(i: i, minIndex)
            }
            
            if controlState == .idle { return }
        }
        controlState = .idle
    }
    // MARK: - Shell Sort
    func shellSort() async {
        currentAlgorithm = "Shell Sort"
        stepCount = 0
        controlState = .running
        
        var gap = items.count / 2
        while gap > 0 {
            for i in gap..<items.count {
                var j = i
                while j >= gap && items[j - gap].value > items[j].value {
                    highlightComparison(i: j, j - gap)
                    log("Comparing: \(items[j].value) and \(items[j - gap].value)")
                    await waitForStepOrSleep()
                    
                    items.swapAt(j, j - gap)
                    highlightSwap(i: j, j - gap)
                    log("Swapping: \(items[j].value) and \(items[j - gap].value)")
                    await waitForStepOrSleep()
                    clearHighlights(i: j, j - gap)
                    
                    j -= gap
                    
                    if controlState == .idle { return }
                }
            }
            gap /= 2
        }
        controlState = .idle
    }
    
    // MARK: - Counting Sort
    func countingSort() async {
        currentAlgorithm = "Counting Sort"
        stepCount = 0
        controlState = .running

        guard let maxValue = items.map({ $0.value }).max() else { return }

        var count = [Int](repeating: 0, count: maxValue + 1)

        // Count occurrences
        for i in 0..<items.count {
            let val = items[i].value
            count[val] += 1
            log("Counting: \(val)")
            highlightComparison(i: i, i)
            await waitForStepOrSleep()
            clearHighlights(i: i, i)

            if controlState == .idle { return }
        }

        // Build sorted array
        var index = 0
        for val in 0...maxValue {
            while count[val] > 0 {
                items[index].value = val
                log("Placing: \(val) at index \(index)")
                highlightSwap(i: index, index)
                await waitForStepOrSleep()
                clearHighlights(i: index, index)
                index += 1
                count[val] -= 1

                if controlState == .idle { return }
            }
        }

        controlState = .idle
    }
    
    // MARK: - Bucket Sort
    func bucketSort() async {
        currentAlgorithm = "Bucket Sort"
        stepCount = 0
        controlState = .running

        guard items.count > 0 else { return }

        let minValue = items.map { $0.value }.min() ?? 0
        let maxValue = items.map { $0.value }.max() ?? 0
        let bucketCount = items.count
        let bucketRange = Double(maxValue - minValue + 1) / Double(bucketCount)

        var buckets = Array(repeating: [ArrayItem](), count: bucketCount)

        // 1. Distribute into buckets
        for item in items {
            let index = Int(Double(item.value - minValue) / bucketRange)
            let bucketIndex = min(index, bucketCount - 1) // Prevent overflow
            buckets[bucketIndex].append(item)

            log("Placing \(item.value) into bucket \(bucketIndex)")
            await waitForStepOrSleep()

            if controlState == .idle { return }
        }

        // 2. Sort each bucket using Insertion Sort
        for i in 0..<bucketCount {
            log("Sorting bucket \(i)")
            await insertionSortBucket(&buckets[i])
            if controlState == .idle { return }
        }

        // 3. Concatenate buckets
        var index = 0
        for bucket in buckets {
            for item in bucket {
                items[index] = item
                highlightComparison(i: index, index)
                await waitForStepOrSleep()
                clearHighlights(i: index, index)
                index += 1

                if controlState == .idle { return }
            }
        }

        controlState = .idle
    }

    // MARK: - Insertion Sort for a Bucket
    private func insertionSortBucket(_ bucket: inout [ArrayItem]) async {
        for i in 1..<bucket.count {
            var j = i
            while j > 0 && bucket[j].value < bucket[j - 1].value {
                bucket.swapAt(j, j - 1)
                log("Swapping \(bucket[j].value) and \(bucket[j-1].value) in bucket")
                await waitForStepOrSleep()
                j -= 1

                if controlState == .idle { return }
            }
        }
    }

    // MARK: - Radix Sort
    func radixSort() async {
        currentAlgorithm = "Radix Sort"
        stepCount = 0
        controlState = .running

        guard let maxValue = items.map({ $0.value }).max() else { return }

        var place = 1
        while maxValue / place > 0 {
            await countingSortByDigit(place: place)
            place *= 10

            if controlState == .idle { return }
        }

        controlState = .idle
    }

    // MARK: - Counting Sort by Digit (Stable sort for Radix)
    private func countingSortByDigit(place: Int) async {
        var count = [Int](repeating: 0, count: 10)
        var output = items

        // Count digits
        for i in 0..<items.count {
            let digit = (items[i].value / place) % 10
            count[digit] += 1
            log("Counting digit \(digit) at place \(place) for value \(items[i].value)")
            highlightComparison(i: i, i)
            await waitForStepOrSleep()
            clearHighlights(i: i, i)

            if controlState == .idle { return }
        }

        // Compute cumulative count
        for i in 1..<10 {
            count[i] += count[i - 1]
        }

        // Build output array in reverse (stable)
        for i in stride(from: items.count - 1, through: 0, by: -1) {
            let digit = (items[i].value / place) % 10
            let pos = count[digit] - 1
            output[pos] = items[i]
            count[digit] -= 1

            log("Placing value \(items[i].value) at index \(pos) based on digit \(digit)")
            highlightSwap(i: i, pos)
            await waitForStepOrSleep()
            clearHighlights(i: i, pos)

            if controlState == .idle { return }
        }

        // Copy to original array
        for i in 0..<items.count {
            items[i] = output[i]
            highlightComparison(i: i, i)
            await waitForStepOrSleep()
            clearHighlights(i: i, i)

            if controlState == .idle { return }
        }
    }

    // MARK: - Pancake Sort
    func pancakeSort() async {
        currentAlgorithm = "Pancake Sort"
        stepCount = 0
        controlState = .running

        guard items.count > 1 else { return }

        for size in stride(from: items.count, to: 1, by: -1) {
            // 1. Find the index of the max value in the unsorted portion
            var maxIndex = 0
            for i in 1..<size {
                highlightComparison(i: i, maxIndex)
                await waitForStepOrSleep()
                if items[i].value > items[maxIndex].value {
                    maxIndex = i
                }
                clearHighlights(i: i, maxIndex)

                if controlState == .idle { return }
            }

            if maxIndex != size - 1 {
                // 2. Flip max to front
                if maxIndex != 0 {
                    log("Flipping first \(maxIndex + 1) items to bring max to front")
                    await flip(end: maxIndex)
                    if controlState == .idle { return }
                }

                // 3. Flip to move max to its correct position
                log("Flipping first \(size) items to move max to position \(size - 1)")
                await flip(end: size - 1)
                if controlState == .idle { return }
            }
        }

        controlState = .idle
    }

    // MARK: - Flip Function
    private func flip(end: Int) async {
        var start = 0
        var end = end

        while start < end {
            highlightComparison(i: start, end)
            items.swapAt(start, end)
            log("Swapping \(items[start].value) and \(items[end].value)")
            await waitForStepOrSleep()
            clearHighlights(i: start, end)
            start += 1
            end -= 1
        }
    }
}
