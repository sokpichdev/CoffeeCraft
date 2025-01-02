//
//  SportDatesViewModel.swift
//  OneNews
//
//  Created by Sok Pich on 12/20/24.
//

import SwiftUI

import SwiftUI

class SportDatesViewModel: ObservableObject {
    @Published var chosenDay: Int = 0
    @Published var isSelectedFootball: Bool = true
    @Published var isDatePickerPresented: Bool = false
    @Published var selectedDate: Date = Date() // Tracks the selected date
    @Published var matchType: MatchType = .live
    @Published var isSelectedDate: Bool = false
    var calendar = Calendar.current
    var today = Date()
    
    
    var leagueName: String = ""
    var leagueCountry: String = ""
    var leagueID: Int = 0
    var matchID: Int = 0
    
    func getDateArray() -> [Date]{
        var dateArray: [Date] = []
        if matchType == .fixtures {
            /// today is 21 then -> 21 22 23 24 25 26 27
            ///               0    1   2   3   4   5  6
            for offset in 0..<7 {
                if let date = calendar.date(byAdding: .day, value: offset, to: today) {
                    dateArray.append(date)
                }
            }
        } else if matchType == .results {
            /// today is 21 then -> 16  17  18  19  20  21 22 23
            ///               -5   -4   -3   -2  -1   0    1   2
            for offset in -5..<2 {
                if let date = calendar.date(byAdding: .day, value: offset, to: today) {
                    dateArray.append(date)
                }
            }
        } else {
            dateArray = [today]
        }
        return dateArray
    }
    
    func adjustDate(by days: Int) {
        withAnimation {
//            guard let date = selectedDate else { return }
//            selectedDate = calendar.date(byAdding: .day, value: days, to: date)
            selectedDate = calendar.date(byAdding: .day, value: days, to: selectedDate) ?? today

            updateMatchType(for: selectedDate)
        }
    }
    func updateMatchType(for date: Date?) {
        guard let date = date else {
            // If no date is selected, use `chosenDay` to determine matchType
            if chosenDay == 1 {
                matchType = .live
            } else if chosenDay < 1 {
                matchType = .results
            } else {
                matchType = .fixtures
            }
            return
        }
        
        if calendar.isDate(date, inSameDayAs: today) {
            if matchType == .live {
                matchType = MatchType.live
            }
        } else if date < today {
            matchType = .results
        } else if date > today {
            matchType = .fixtures
        } else {
            matchType = .live
        }
    }
}
