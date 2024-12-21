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
            DatePicker("Date", selection: Binding<Date>(
                get: { sportDateVM.selectedDate},
                set: { newDate in
                    sportDateVM.selectedDate = newDate
                    sportDateVM.updateMatchType(for: newDate)
                    sportDateVM.isSelectedDate = true
                    print("Match Type: \(sportDateVM.matchType) - Selected Date: \(String(describing: sportDateVM.selectedDate))")
                    
                }
            ), displayedComponents: .date)
            .datePickerStyle(GraphicalDatePickerStyle())
            .padding()
        }
        .presentationDetents([.fraction(0.5)])
        .presentationDragIndicator(.visible)
    }
}

