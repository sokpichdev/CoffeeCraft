//
//  GeneralDatePickerSheet.swift
//  OneNews
//
//  Created by Sok Pich on 1/14/25.
//
import SwiftUI

struct GeneralDatePickerSheet: View {
    @Binding var selectedDate: Date
    
    var body: some View {
        VStack {
            DatePicker(
                "Select Date",
                selection: $selectedDate,
                in: dateRange,
                displayedComponents: .date
            )
            .datePickerStyle(GraphicalDatePickerStyle())
            .padding()
        }
        .presentationDetents([.fraction(0.5)])
        .presentationDragIndicator(.visible)
    }
    
    // Past date range only
    private var dateRange: ClosedRange<Date> {
        let today = Calendar.current.startOfDay(for: Date())
        let pastDate = Calendar.current.date(byAdding: .year, value: -10, to: today) ?? Date.distantPast // Adjust past range as needed
        return pastDate...today
    }
}
