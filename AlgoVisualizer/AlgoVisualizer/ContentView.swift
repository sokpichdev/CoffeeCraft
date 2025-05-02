//
//  ContentView.swift
//  AlgoVisualizer
//
//  Created by Sok Pich on 5/2/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = SortViewModel()

    var body: some View {
        VStack {
            // Bar Chart
            HStack(alignment: .bottom, spacing: 2) {
                ForEach(viewModel.items) { item in
                    Rectangle()
                        .fill(item.color)
                        .frame(width: 10, height: CGFloat(item.value) * 5)
                        .animation(.easeInOut(duration: 0.2), value: item.value)
                }
            }
            .frame(height: 300)
            .padding()

            // Controls
            VStack(spacing: 16) {
                // Speed slider
                HStack {
                    Text("Speed:")
                    Slider(value: $viewModel.speed, in: 0...1)
                    Text(String(format: "%.2f", viewModel.speed))
                }

                HStack(spacing: 12) {
                    Button("Reset") {
                        viewModel.reset()
                    }
                    .disabled(viewModel.isSorting)

                    Button("Bubble Sort") {
                        Task { await viewModel.bubbleSort() }
                    }
                    .disabled(viewModel.isSorting)

                    Button("Insertion Sort") {
                        Task { await viewModel.insertionSort() }
                    }
                    .disabled(viewModel.isSorting)

                    Button("Quick Sort") {
                        Task { await viewModel.quickSort() }
                    }
                    .disabled(viewModel.isSorting)

                    Button(viewModel.isPaused ? "Resume" : "Pause") {
                        viewModel.togglePause()
                    }
                    .disabled(!viewModel.isSorting || viewModel.stepMode)

                    Button(viewModel.stepMode ? "Step Mode: ON" : "Step Mode: OFF") {
                        viewModel.toggleStepMode()
                    }
                    .disabled(viewModel.isSorting)

                    Button("Next Step") {
                        viewModel.step()
                    }
                    .disabled(!viewModel.stepMode || !viewModel.waitingForStep)
                }
            }
            .padding()
        }
    }
}
