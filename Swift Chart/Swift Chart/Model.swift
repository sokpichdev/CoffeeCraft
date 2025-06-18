//
//  Model.swift
//  Swift Chart
//
//  Created by Sok Pich on 6/5/25.
//

import SwiftUI

struct Food: Identifiable {
    let name: String
    let price: Double
    let date: Date
    let id = UUID()
    
    init(name: String, price: Double, year: Int) {
        self.name = name
        self.price = price
        let calendar = Calendar.autoupdatingCurrent
        self.date = calendar.date(from: DateComponents(year: year))!
    }
}

struct Weather: Identifiable {
    let date: Date
    let maximumTemperature: Double
    let minimumTemperature: Double
    let id: Int
}
