//
//  SampleData.swift
//  Swift Chart
//
//  Created by Sok Pich on 6/5/25.
//

import Foundation

let cheeseburgerCostByItem: [Food] = [
    .init(name: "Burger", price: 0.07, year: 1960),
    .init(name: "Cheese", price: 0.03, year: 1960),
    .init(name: "Bun", price: 0.05, year: 1960),
    .init(name: "Burger", price: 0.10, year: 1970),
    .init(name: "Cheese", price: 0.04, year: 1970),
    .init(name: "Bun", price: 0.06, year: 1970),
    .init(name: "Burger", price: 0.60, year: 2020),
    .init(name: "Cheese", price: 0.26, year: 2020),
    .init(name: "Bun", price: 0.24, year: 2020)
]

let sampleWeatherData: [Weather] = [
    Weather(date: Calendar.current.date(from: DateComponents(year: 2025, month: 6, day: 1))!, maximumTemperature: 32.5, minimumTemperature: 25.1, id: 1),
    Weather(date: Calendar.current.date(from: DateComponents(year: 2025, month: 6, day: 2))!, maximumTemperature: 33.0, minimumTemperature: 26.0, id: 2),
    Weather(date: Calendar.current.date(from: DateComponents(year: 2025, month: 6, day: 3))!, maximumTemperature: 31.8, minimumTemperature: 24.5, id: 3),
    Weather(date: Calendar.current.date(from: DateComponents(year: 2025, month: 6, day: 4))!, maximumTemperature: 30.2, minimumTemperature: 23.9, id: 4),
    Weather(date: Calendar.current.date(from: DateComponents(year: 2025, month: 6, day: 5))!, maximumTemperature: 31.5, minimumTemperature: 24.8, id: 5)
]
