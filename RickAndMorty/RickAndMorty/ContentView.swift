//
//  ContentView.swift
//  RickAndMorty
//
//  Created by Sok Pich on 5/21/25.
//

import SwiftUI

struct ContentView: View {
    @State private var scrollOffset: CGFloat = 0
    @State private var lastScrollOffset: CGFloat = 0
    @State private var scrollDirection: String = "Idle"
    @State private var isDragging: Bool = false

    // Threshold to consider direction change meaningful
    let directionChangeThreshold: CGFloat = 10

    var body: some View {
        VStack {
            Text("Scroll Direction: \(scrollDirection)")
                .font(.headline)
                .padding()

            ScrollView {
                GeometryReader { geo in
                    let offset = geo.frame(in: .global).minY

                    Color.clear
                        .onAppear {
                            lastScrollOffset = offset
                        }
                        .onChange(of: offset) { newOffset in
                            guard isDragging else { return } // only detect while dragging

                            let delta = newOffset - lastScrollOffset

                            if delta > directionChangeThreshold && scrollDirection != "Scrolling Up" {
                                scrollDirection = "Scrolling Up"
                                lastScrollOffset = newOffset
                            } else if delta < -directionChangeThreshold && scrollDirection != "Scrolling Down" {
                                scrollDirection = "Scrolling Down"
                                lastScrollOffset = newOffset
                            }
                        }
                }
                .frame(height: 0)

                // Scrollable content
                ForEach(1..<51) { i in
                    Text("Row \(i)")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(8)
                        .padding(.horizontal)
                }
            }
            .simultaneousGesture(
                DragGesture()
                    .onChanged { _ in
                        isDragging = true
                    }
                    .onEnded { _ in
                        isDragging = false
                        scrollDirection = "Idle"
                    }
            )
        }
    }
}
