//
//  ContentView.swift
//  WeSplit
//
//  Created by Sok Pich on 11/27/24.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Text("Hello, World!").textCase(.uppercase).font(.subheadline)
                }
                Section {
                    Text("Hello, World!").font(.largeTitle)
                }
            }.navigationTitle("SwiftUI").navigationBarTitleDisplayMode(.inline).font(.headline)
                
        }
    }
}

#Preview {
    ContentView()
}
