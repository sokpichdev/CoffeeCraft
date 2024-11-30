//
//  ContentView.swift
//  BetterRest
//
//  Created by Sok Pich on 11/30/24.
//
//
//  ContentView.swift
//  BetterRest
//
//  Created by Sok Pich on 11/30/24.
//
import CoreML
import SwiftUI

struct ContentView: View {
    @State private var wakeUp = defaultWakeTime
    @State private var sleepAmount = 8.0
    @State private var coffeeAmount = 1
    
    static var defaultWakeTime: Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? .now
    }
    
    var calculatedBedtime: String {
        do {
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)
            
            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
            let hour = (components.hour ?? 0) * 60 * 60
            let minute = (components.minute ?? 0) * 60
            
            let prediction = try model.prediction(wake: Double(hour + minute), estimatedSleep: sleepAmount, coffee: Double(coffeeAmount))
            
            let sleepTime = wakeUp - prediction.actualSleep
            return sleepTime.formatted(date: .omitted, time: .shortened)
        } catch {
            return "Error calculating bedtime"
        }
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    VStack(alignment: .leading, spacing: 0) {
                        Text("When do you want to wake up?")
                            .font(.headline)
                        
                        DatePicker("Please enter a time", selection: $wakeUp, displayedComponents: .hourAndMinute)
                            .labelsHidden()
                    }
                }
                
                Section {
                    VStack(alignment: .leading, spacing: 0) {
                        Text("Desired amount of sleep")
                            .font(.headline)
                        
                        Stepper("\(sleepAmount.formatted()) hours", value: $sleepAmount, in: 4...12, step: 0.25)
                    }
                }
                
                Section {
                    VStack(alignment: .leading, spacing: 0) {
                        Text("Daily coffee intake")
                            .font(.headline)
                        
                        Stepper("^[\(coffeeAmount) cup](inflect: true)", value: $coffeeAmount, in: 1...20)
                    }
                }
                
                Section {
                    VStack(alignment: .center) {
                        Text("Your ideal bedtime is")
                            .font(.headline)
                        
                        Text(calculatedBedtime)
                            .font(.largeTitle)
                            .bold()
                            .foregroundColor(.blue)
                            .padding(.top, 10)
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                }
            }
            .navigationTitle("BetterRest")
        }
    }
}

struct Dates: View {
    // bind to a steper so that it shows the curent value
    @State private var sleepAmount = 8.0
    
    // a Dedicated type for working with dates. it's called Date
    @State private var wakeUp = Date.now
    
    var body: some View {
//        Text(Date.now, format: .dateTime)
//        Text(Date.now, format: .dateTime.hour().minute())
//        Text(Date.now, format: .dateTime.day().month().year())
//        Text(Date.now.formatted(date: .long, time: .shortened))
        
        
        // Entering numbers wiht Stepper
        Stepper("\(sleepAmount) hours, ", value: $sleepAmount, in: 4...12, step: 0.25)
        /*Stepper: a simple - and + button that can be tapped to seelect a precise number. Steppers works with any kinds of numbers types.
            - 1st param: display,
            - 2rd param: bind value,
            - 3rd param: in range
            - 4th param: step: how far to move the value each time.
         */
        
        // bind to a date picker:
//        DatePicker("Please enter a date", selection: $wakeUp)
//        DatePicker("Please enter a date", selection: $wakeUp).labelsHidden()
//        DatePicker("Please enter a date", selection: $wakeUp, displayedComponents: .date)
//        DatePicker("Please enter a time", selection: $wakeUp, displayedComponents: .hourAndMinute)
//        DatePicker("Please enter a date", selection: $wakeUp, in: Date.now...)// allow all dated in the future, but none in the past.
        
    }
    
    func exampleDates() {
        // Create a second Date instance set to one day in seconds from now.
        let tomorrow = Date.now.addingTimeInterval(86400)
        
        // create a range from those two
        let range = Date.now...tomorrow
    }
}

#Preview {
    ContentView()
}
