//
//  ContentView.swift
//  Swift Chart
//
//  Created by Sok Pich on 6/5/25.
//

import SwiftUI
import Charts

struct ContentView: View {
    var body: some View {
        ScrollView {
            VStack {
                Chart(cheeseburgerCostByItem) { cost in
                    AreaMark(
                        x: .value("Date", cost.date),
                        y: .value("Price", cost.price)
                    )
                    .foregroundStyle(by: .value("Food Item", cost.name))
                }
                
                Chart(sampleWeatherData) { day in
                    AreaMark(
                        x: .value("Date", day.date),
                        yStart: .value("Minimum Temperature", day.minimumTemperature),
                        yEnd: .value("Maximum Temperature", day.maximumTemperature)
                    )
                }
            }
            .padding()
        }
    }
}

#Preview {
    ContentView()
}
