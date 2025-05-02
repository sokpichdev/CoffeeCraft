//
//  ScrollingViewWithSliderView.swift
//  MyLearningApp
//
//  Created by Sok Pich on 3/31/25.
//
import SwiftUI

struct ScrollingViewWithSliderView: View {
    @State private var isScrollDisabled: Bool = false
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Volume")
                        .font(.caption2)
                        .foregroundStyle(.gray)
                    Text(isScrollDisabled ? "Scroll Disabled" : "Scroll Enabled")
                    VolumeSlider(isScrollDisabled: $isScrollDisabled)
                }
                .padding()
            }
            .scrollDisabled(isScrollDisabled)
            .navigationTitle("Gesture - iOS 18")
        }
    }
}

struct VolumeSlider: View {
    @Binding var isScrollDisabled: Bool
    @State private var progress: CGFloat = 0
    @State private var lastProgress: CGFloat = 0
    @State private var velocity: CGSize = .zero
    @State private var lastUpdated: Date = Date()
    
    var body: some View {
        GeometryReader { geometry in
            let size = geometry.size
            
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(.ultraThinMaterial)
                    .cornerRadius(10)
                
                Rectangle()
                    .fill(.black)
                    .frame(width: progress * size.width)
                    .cornerRadius(10)
            }
            .simultaneousGesture(customGesture)
            .frame(height: 40)
        }
    }
    
    var customGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                // Throttling state updates to prevent constant updates
                let currentTime = Date()
                let timeDifference = currentTime.timeIntervalSince(lastUpdated)
                if timeDifference > 0.02 {  // Only update every 20ms, for example
                    lastUpdated = currentTime
                    
                    if velocity == .zero {
                        velocity = value.velocity
                    }
                    
                    guard velocity.height == 0 else { return }  // Ensure it's horizontal drag
                    
                    isScrollDisabled = true
                    let newProgress = (value.translation.width / 200) + lastProgress  // Modify here for scaling
                    progress = max(min(newProgress, 1), 0)  // Ensure progress is between 0 and 1
                }
            }
            .onEnded { _ in
                lastProgress = progress
                if #available(iOS 18, *) {
                    velocity = .zero
                    isScrollDisabled = false  // Reset scroll disable after gesture ends
                }
            }
    }
}
