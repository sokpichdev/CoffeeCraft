//
//  ContentView.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 10/20/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .padding()
    }
}
struct ComingSoonView: View {
    var featureName: String = "This feature" // optional, can customize per view
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "hourglass")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .foregroundColor(.gray)
            
            Text("\(featureName) is coming soon!")
                .font(.title2)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
                .foregroundColor(.gray)
            
            Text("Stay tuned for updates ☕️")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }
}
