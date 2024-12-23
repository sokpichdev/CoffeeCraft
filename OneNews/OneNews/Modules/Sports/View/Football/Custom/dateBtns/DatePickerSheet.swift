//
//  DatePickerSheet.swift
//  OneNews
//
//  Created by Sok Pich on 12/20/24.
//

import SwiftUI

struct DatePickerSheet: View {
    @ObservedObject var sportDateVM: SportDatesViewModel

    var body: some View {
        VStack {
            DatePicker(
                "Date",
                selection: Binding<Date>(
                    get: { sportDateVM.selectedDate },
                    set: { newDate in
                        sportDateVM.selectedDate = newDate
                        sportDateVM.updateMatchType(for: newDate)
                        sportDateVM.isSelectedDate = true
                        print("Match Type: \(sportDateVM.matchType) - Selected Date: \(String(describing: sportDateVM.selectedDate))")
                    }
                ),
                in: dateRange(), // Dynamically set the date range
                displayedComponents: .date
            )
            .datePickerStyle(GraphicalDatePickerStyle())
            .padding()
        }
        .presentationDetents([.fraction(0.5)])
        .presentationDragIndicator(.visible)
    }
    
    private func dateRange() -> ClosedRange<Date> { /// Determine the date range based on the match type
        let today = Calendar.current.startOfDay(for: Date())
        if sportDateVM.matchType == .fixtures {
            return today...(Calendar.current.date(byAdding: .year, value: 1, to: today) ?? today) // Allow only today and future dates
        } else {
            return (Calendar.current.date(byAdding: .year, value: -1, to: today) ?? today)...today // Allow only today and past dates
        }
    }
}
