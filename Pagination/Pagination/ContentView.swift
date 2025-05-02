//
//  ContentView.swift
//  Pagination
//
//  Created by Sok Pich on 4/28/25.
//
import SwiftUI

struct ContentView: View {
    @State private var allItems = Array(0..<100)  // Total available items
    @State private var displayedItems: [Int] = [] // Items currently shown
    @State private var selectedItem: Int? = nil
    private let pageSize = 10

    var body: some View {
        NavigationStack {
            ScrollViewReader { proxy in
                ScrollView(.vertical) {
                    LazyVStack(spacing: 20) {
                        ForEach(displayedItems, id: \.self) { item in
                            NavigationLink(destination: DetailView(item: item)) {
                                Text("Item \(item)")
                                    .font(.title2)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 80)
                                    .background(Color.blue.opacity(0.3))
                                    .cornerRadius(12)
                                    .padding(.horizontal)
                            }
                            .simultaneousGesture(TapGesture().onEnded {
                                selectedItem = item
                            })
                            .onAppear {
                                loadMoreIfNeeded(currentItem: item)
                            }
                        }
                    }
                    .padding(.vertical)
                }
                .onAppear {
                    if displayedItems.isEmpty {
                        loadNextPage()
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                        if let item = selectedItem {
                            withAnimation {
                                proxy.scrollTo(item, anchor: .center)
                            }
                        }
                    }
                }
                .onChange(of: selectedItem) { newItem in
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                        if let item = newItem {
                            withAnimation {
                                proxy.scrollTo(item, anchor: .center)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Items")
        }
    }
    
    private func loadMoreIfNeeded(currentItem item: Int) {
        // When the last displayed item appears, load more
        if item == displayedItems.last {
            loadNextPage()
        }
    }
    
    private func loadNextPage() {
        let currentCount = displayedItems.count
        guard currentCount < allItems.count else { return }
        
        let nextItems = allItems[currentCount..<min(currentCount + pageSize, allItems.count)]
        displayedItems.append(contentsOf: nextItems)
    }
}

struct DetailView: View {
    let item: Int

    var body: some View {
        VStack {
            Text("Detail for Item \(item)")
                .font(.largeTitle)
            Spacer()
        }
        .padding()
        .navigationTitle("Item \(item)")
    }
}

#Preview {
    ContentView()
}
