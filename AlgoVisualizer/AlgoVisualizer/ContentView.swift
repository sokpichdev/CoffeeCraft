//
//  ContentView.swift
//  AlgoVisualizer
//
//  Created by Sok Pich on 5/2/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = SortViewModel()
    @StateObject private var searchViewModel = SearchViewModel()
    @State private var showSteps = false
    @State private var searchText = ""

    var body: some View {
        TabView {
            sortingScreen
                .tag(0)

            searchingScreen
                .tag(1)
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
    }
}

extension ContentView {
    var sortingScreen: some View {
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
        .scrollDismissesKeyboard(.immediately)
    }
    var searchingScreen: some View {
        ScrollView {
            VStack(spacing: 24) {
                
                headerView
                searchBarTextField
                showStepsView
                searchingBarView
                searchingMethodController
                speedControllerView
                controlPanel
            }
            .padding(.horizontal, 16)
        }
        .scrollDismissesKeyboard(.immediately)
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
                        .frame(height: CGFloat(viewModel.items[index].value) * 10)
                        .clipShape(RoundedCorner(radius: 5, corners: [.topLeft, .topRight]))
                        .shadow(radius: 2)

                    Text("\(viewModel.items[index].value)")
                        .font(.caption2)
                        .foregroundColor(.primary)
                }
            }
        }
        .frame(height: 300)
    }
    
    var searchingBarView: some View {
        HStack(alignment: .bottom, spacing: 4) {
            ForEach(searchViewModel.items.indices, id: \.self) { index in
                VStack(spacing: 2) {
                    Rectangle()
                        .fill(searchViewModel.items[index].color)
                        .frame(height: CGFloat(searchViewModel.items[index].value) * 10)
                        .clipShape(RoundedCorner(radius: 5, corners: [.topLeft, .topRight]))
                        .shadow(radius: 2)

                    Text("\(searchViewModel.items[index].value)")
                        .font(.caption2)
                        .foregroundColor(.primary)
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
                    
                    SortingButton(title: "Selection Sort", action: {
                        Task {await viewModel.selectionSort() }
                    })
                    
                    SortingButton(title: "Quick Sort", action: {
                        Task { await viewModel.quickSort() }
                    })
                    
                    SortingButton(title: "Merge Sort", action: {
                        Task { await viewModel.mergeSort() }
                    })
                    
                    SortingButton(title: "Heap Sort", action: {
                        Task {await viewModel.heapSort() }
                    })
                    
                    SortingButton(title: "Shell Sort", action: {
                        Task {await viewModel.shellSort() }
                    })
                    
                    SortingButton(title: "Counting Sort", action: {
                        Task {await viewModel.countingSort() }
                    })
                    
                    SortingButton(title: "Radix Sort", action: {
                        Task {await viewModel.radixSort() }
                    })
                    
                    SortingButton(title: "Bucket Sort", action: {
                        Task {await viewModel.bucketSort() }
                    })
                    
                    SortingButton(title: "Pancake Sort", action: {
                        Task {await viewModel.pancakeSort() }
                    })
                }
            }
        }
    }
    var searchingMethodController: some View {
        GroupBox(label: Text("Searching Methods").font(.headline)) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    SortingButton(title: "Linear Search", action: {
                        Task { await searchViewModel.linearSearch()}
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
                ScrollView {
                    VStack(spacing: 4) {
                        ForEach(viewModel.stepLogs, id: \.self) { log in
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

extension ContentView {
    var searchBarTextField: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            
            TextField("Enter number", value: $searchViewModel.searchTarget, formatter: NumberFormatter())
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.numberPad)

            
            if !searchText.isEmpty {
                Button(action: {
                    searchText = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
                .padding(.trailing)
            }
        }
        .frame(height: 40)
    }
}
