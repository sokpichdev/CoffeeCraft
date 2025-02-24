//
//  ScrollingView.swift
//  MyLearningApp
//
//  Created by Sok Pich on 2/24/25.
//

import SwiftUI
import SwiftUIIntrospect

struct ScrollingView: View {
    @State private var isOuterScrollFullyVisible = false
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView(showsIndicators: false) { // Outer ScrollView (Scrollable, No Bounce)
                VStack(spacing: 20) {
                    ForEach(1..<5, id: \.self) { index in
                        Text("Fixed Header")
                            .font(.title)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.red)
                    }
                    
                    BouncableScrollView(isOuterScrollFullyVisible: $isOuterScrollFullyVisible)
                        .frame(height: UIScreen.main.bounds.height)
                }
                .frame(maxWidth: .infinity)
                .background(
                    GeometryReader { proxy in
                        Color.clear
                            .onAppear {
                                let contentHeight = proxy.frame(in: .global).height
                                // Check if the outer scroll view's content fully fits within the screen
                                isOuterScrollFullyVisible = contentHeight <= geometry.size.height
                            }
                    }
                )
            }
            .background(Color.gray.opacity(0.5))
            .introspect(.scrollView, on: .iOS(.v13, .v14, .v15, .v16, .v17, .v18)) { scrollView in
                scrollView.bounces = false // Disable bounce on the outer scroll
            }
        }
    }
}

// Inner ScrollView with Pull-to-Refresh
struct BouncableScrollView: View {
    @Binding var isOuterScrollFullyVisible: Bool
    @State private var isRefreshing = false

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 10) {
                ForEach(1..<100, id: \.self) { index in
                    Text("\(index)")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 50) // Simulate space for pull-to-refresh
        }
        .introspect(.scrollView, on: .iOS(.v13, .v14, .v15, .v16, .v17, .v18)) { scrollView in
            // Enable bounce for the inner scroll view (green) even when at the top
            scrollView.bounces = true
            scrollView.alwaysBounceVertical = true
            scrollView.contentInsetAdjustmentBehavior = .never // Ensure it scrolls immediately, no padding
        }
        .refreshable {
            await refreshData()
        }
        .background(Color.green.opacity(0.6))
    }

    func refreshData() async {
        isRefreshing = true
        try? await Task.sleep(nanoseconds: 1_000_000_000) // Simulate loading
        isRefreshing = false
    }
}
