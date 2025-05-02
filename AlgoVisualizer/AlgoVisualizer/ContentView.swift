//
//  ContentView.swift
//  AlgoVisualizer
//
//  Created by Sok Pich on 5/2/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = SortViewModel()
    @State private var showSteps = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                headerView
                showStepsView
                sortingBarView
                sortingMethodController
                speedControllerView
                controlPanel
            }
            .padding(.horizontal, 16)
        }
    }
}

extension ContentView {
    var headerView: some View {
        VStack(spacing: 4) {
            Text("Algorithm: \(viewModel.currentAlgorithm)")
                .font(.title2)
                .bold()
                .foregroundColor(.primary)
            Text("Steps: \(viewModel.stepCount)")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(.top)
    }
    
    var sortingBarView: some View {
        HStack(alignment: .bottom, spacing: 4) {
            ForEach(viewModel.items.indices, id: \.self) { index in
                VStack(spacing: 2) {
                    if viewModel.currentAlgorithm == "Quick Sort" && viewModel.pivotIndex == index {
                        Text("⬇️")
                            .font(.caption2)
                            .foregroundColor(.orange)
                    }
                    
                    Rectangle()
                        .fill(viewModel.items[index].color)
                        .frame(height: CGFloat(viewModel.items[index].value) * 5)
                        .clipShape(RoundedCorner(radius: 5, corners: [.topLeft, .topRight]))
                        .shadow(radius: 2)
                }
            }
        }
        .frame(height: 300)
    }
    
    var speedControllerView: some View {
        GroupBox(label: Text("Speed Control").font(.headline)) {
            HStack(spacing: 12) {
                Text("Speed:")
                Slider(value: $viewModel.speed, in: 0...1)
                Text(String(format: "%.2f", viewModel.speed))
                    .font(.body)
                    .bold()
            }
        }
    }
    
    var sortingMethodController: some View {
        GroupBox(label: Text("Sorting Methods").font(.headline)) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    SortingButton(title: "Bubble Sort", action: {
                        Task { await viewModel.bubbleSort() }
                    })
                    
                    SortingButton(title: "Insertion Sort", action: {
                        Task { await viewModel.insertionSort() }
                    })
                    
                    SortingButton(title: "Quick Sort", action: {
                        Task { await viewModel.quickSort() }
                    })
                }
            }
        }
    }

    var controlPanel: some View {
        GroupBox(label: Text("Controls").font(.headline)) {
            VStack(spacing: 16) {
                HStack(spacing: 16) {
                    ColoredControlButton(
                        title: viewModel.controlState == .paused ? "Resume" : "Pause",
                        action: {
                            if viewModel.controlState == .paused {
                                viewModel.resume()
                            } else {
                                viewModel.pause()
                            }
                        },
                        isDisabled: viewModel.controlState == .idle,
                        enabledColor: .orange,
                        disabledColor: .gray
                    )
                    
                }

                HStack(spacing: 16) {
                    ColoredControlButton(
                        title: "Reset",
                        action: { viewModel.reset() },
                        isDisabled: viewModel.controlState == .running,
                        enabledColor: .blue,
                        disabledColor: .gray
                    )

                    ColoredControlButton(
                        title: viewModel.controlState == .stepping ? "Auto Mode" : "Step Mode",
                        action: {
                            if viewModel.controlState == .stepping {
                                viewModel.resume()
                            } else {
                                viewModel.step()
                            }
                        },
                        isDisabled: viewModel.controlState == .running,
                        enabledColor: .purple,
                        disabledColor: .gray
                    )
                }
            }
            .padding(.horizontal)
        }
    }

    var showStepsView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Button(showSteps ? "Hide Steps" : "Show Steps") {
                withAnimation {
                    showSteps.toggle()
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(Color.green)
            .foregroundColor(.white)
            .cornerRadius(8)
            .shadow(radius: 3)
            .frame(maxWidth: .infinity, alignment: .leading) // ← ensures leading alignment
            if showSteps {
                VStack(alignment: .leading, spacing: 8) {
                    ScrollView {
                        VStack(spacing: 4) {
                            ForEach(viewModel.stepLogs.prefix(5), id: \.self) { log in
                                Text(log)
                            }
                        }
                    }
                    .frame(height: 120)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.systemBackground))
                    .cornerRadius(8)
                    .shadow(radius: 2)
                }
            }
        }
    }
}


// Custom button for sorting algorithms with improved styling
struct SortingButton: View {
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
                .shadow(radius: 3)
        }
    }
}

struct ColoredControlButton: View {
    let title: String
    let action: () -> Void
    let isDisabled: Bool
    let enabledColor: Color
    let disabledColor: Color

    var body: some View {
        Button(action: {
            if !isDisabled {
                action()
            }
        }) {
            Text(title)
                .frame(maxWidth: .infinity)
                .padding()
                .background(isDisabled ? disabledColor : enabledColor)
                .foregroundColor(.white)
                .cornerRadius(8)
                .shadow(radius: isDisabled ? 0 : 3)
        }
        .disabled(isDisabled)
    }
}
