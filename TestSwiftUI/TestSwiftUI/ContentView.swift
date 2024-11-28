//
//  ContentView.swift
//  TestSwiftUI
//
//  Created by Sok Pich on 11/27/24.
//


import SwiftUI

struct ContentView: View {
    @State var tapCount: Int = 0 // @State property wrapper lets us modify our view structs freely
    
    @State var name = ""
    
    let players = ["Aliz", "Bun", "Feb", "Nomercy", "Feb"]
    @State private var selectedPlayer = "Nomercy"
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Text("Hello, World!").textCase(.uppercase).font(.subheadline)
                }
                Section {
                    Text("Hello, World!").font(.largeTitle)
                    Text("Hi, this is \(name).").fontDesign(.monospaced)
                }
                Section {
                    Button("Tap Count: \(tapCount)") {
                        tapCount += 1
                    }
                }
                Section {
                    TextField("Enter your name: ", text: $name) // two-way binidng: we bind the text field so that it shows the value of our property, but also bind it so that nay changes to the text field also upate the property.
                }
                
                Section {
                    // Creating Views in a loop
                    ForEach(0..<4) {
                        Text("\($0)")
                    
                    }
                }
                
                Section {
                    Picker("Select your player", selection: $selectedPlayer) {
                        ForEach(players, id: \.self){
                            Text($0)
                        }
                    }
                }
            }.navigationTitle("SwiftUI").navigationBarTitleDisplayMode(.inline).font(.headline)
        }
        
    }
}

#Preview {
    ContentView()
}
