//
//  ContentView.swift
//  WeSplit
//
//  Created by Sok Pich on 11/27/24.
//

import SwiftUI

struct ContentView: View {
    // modifying program state
    @State private var checkAmount = 0.0
    @State private var numberOfPeople = 2
    @State private var tipPercentage = 20
    
    
    @FocusState private var amountIsFocused: Bool
    
    var totalAmount : Double {
        let amount = Double(checkAmount)
        let tipSelection = Double(tipPercentage)
        
        return amount + amount / 100 * tipSelection
    }
    
    let tipPercentanges = [5, 10, 15, 20, 25, 0]
    
    var totalPerPerson: Double {
            let peopleCount = Double(numberOfPeople + 2) // picker start from 2, so + 2 to make it count correctly
            let tipSelection = Double(tipPercentage)
            
            let tipValue = checkAmount / 100 * tipSelection
            let grandTotal = checkAmount + tipValue
            let amountPerPerson = grandTotal / peopleCount
            
            return amountPerPerson
        }
    var body: some View {
        NavigationStack{
            Form {
                Section {
                    //Binding state to user user interface controls
                    
                    //Reading text form the user with TextField
                    TextField("Amount", value: $checkAmount, format: .currency(code: Locale.current.currency?.identifier ?? "USD"))
                        .keyboardType(.numberPad)
                        .focused($amountIsFocused)
                    
                    // Creating Pickers in a form
                    Picker("Number of people", selection: $numberOfPeople) {
                        ForEach(2..<100) {
                            Text("\($0) people")
                        }
                    }
                    //.pickerStyle(.navigationLink)
                }
                // Adding a segmented control for tip percentages
                Section("How much do you want to tip?") {
                    //Text("How much do you want to tip?")
                    Picker("Tip percentage", selection: $tipPercentage) {
                        //Creating views in a loop
                        ForEach(tipPercentanges, id:\.self) {
                            //Text("\($0)%")'
                            Text($0, format: .percent)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                
                Section("Total Amount") {
                    Text(totalAmount, format: .currency(code: Locale.current.currency?.identifier ?? "USD"))
                }
                
                Section("Amount per person") {
                    Text(totalPerPerson, format: .currency(code: Locale.current.currency?.identifier ?? "USD"))
                }
            }
            .navigationTitle("WeSplit")
            .toolbar {
                if amountIsFocused {
                    Button("Done") {
                        amountIsFocused = false
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
